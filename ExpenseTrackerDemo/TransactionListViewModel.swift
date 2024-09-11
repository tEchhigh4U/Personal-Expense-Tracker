//
//  TransactionListViewModel.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation
import Combine
import Firebase
import Collections

typealias TransactionGroup = OrderedDictionary<String, [Transaction]> // [String: [Transaction]] is a dictionary type
typealias TransactionPrefixSum = [(String, Double)] // a record of accumulated sum

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []  // initialized empty object
    @Published var searchText = ""
    @Published var isLoading = false
    
    private var ref: DatabaseReference = Database.database().reference()
    private var cancellables = Set<AnyCancellable>() // empty object
    
    var filteredTransactions: [Transaction] {
            if searchText.isEmpty {
                return transactions
            } else {
                return transactions.filter { transaction in
                    // Check for matches in text fields
                    let textMatches = transaction.merchant.lowercased().contains(searchText.lowercased()) ||
                                      transaction.category.lowercased().contains(searchText.lowercased()) ||
                                      transaction.institution.lowercased().contains(searchText.lowercased()) ||
                                      transaction.account.lowercased().contains(searchText.lowercased()) ||
                                      transaction.createdAt.contains(searchText)  // Direct string comparison for dates

                    // Check for matches in numeric fields (amount)
                    let amountString = String(format: "%.2f", transaction.amount)  // Convert to string with two decimal places
                    let amountMatches = amountString.contains(searchText)

                    return textMatches || amountMatches
                }
            }
        }
    
    var currentTransaction: Transaction?
    
    // init method
    init(){
        observeTransactions()
    }
    
    func refreshTransactions() {
        print("Page is refreshing now...")
        isLoading = true
        
        // call related function globally
        observeTransactions()

        // Delay the completion of loading by 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            print("Refreshing page is completed. Fetched \(self.transactions.count) transactions")
        }
    }
    
    private func observeTransactions() {
        print("Start getting data from DB")
        ref.child("transactions").observe(.value) { [weak self] (snapshot, _) in
            guard let self = self else { return }
            
            var newTransactions = [Transaction]()
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                guard let value = child.value as? [String: Any] else {
                    continue
                }
                
                // Assuming ID is stored as a string in Firebase
                let transactionId = UUID(uuidString: value["id"] as? String ?? "") ?? UUID()
                
                let transaction = Transaction(
                    id: transactionId,
                    createdAt: value["date"] as? String ?? "",
                    institution: value["institution"] as? String ?? "",
                    account: value["account"] as? String ?? "",
                    merchant: value["merchant"] as? String ?? "",
                    amount: value["amount"] as? Double ?? 0.0,
                    type: value["type"] as? String ?? "",
                    categoryId: value["categoryId"] as? Int ?? 0,
                    category: value["category"] as? String ?? "",
                    isPending: value["isPending"] as? Bool ?? false,
                    isTransfer: value["isTransfer"] as? Bool ?? false,
                    isExpense: value["isExpense"] as? Bool ?? false,
                    isEdited: value["isEdited"] as? Bool ?? false
                )

                newTransactions.append(transaction)
            }
            
            // Sort transactions by date, most recent first
            let sortedTransactions = newTransactions.sorted { (trans1: Transaction, trans2: Transaction) -> Bool in
                let date1 = DateFormatter.allNumericUS.date(from: trans1.createdAt) ?? Date.distantPast
                let date2 = DateFormatter.allNumericUS.date(from: trans2.createdAt) ?? Date.distantPast
                return date1 > date2
            }
            
            DispatchQueue.main.async {
                self.transactions = sortedTransactions
                print("Fetched and sorted \(self.transactions.count) transactions")
                if let mostRecent = self.transactions.first {
                    print("Most recent transaction: \(mostRecent.createdAt), Merchant: \(mostRecent.merchant)")
                }
            }
        }
        print("Data retrieval observation set up completed.")
    }
    
    // get transactions record from the url
//    func getTransactions() {
//        guard let url = URL(string: "https://designcode.io/data/transactions.json") else {
//            print("Invalid URL is being used.")
//            return
//        }
//        
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .formatted(DateFormatter.allNumericUS)
//        
//        
//                URLSession.shared.dataTaskPublisher(for:url)
//                    .tryMap { (data, response) -> Data in
//                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                            dump(response)
//                            throw URLError(.badServerResponse)
//                        }
//                        let dataString = String(data: data, encoding: .utf8) ?? "Invalid data encoding"
//                            print("Received data: \(dataString)")
//                        return data
//                    }
//                    .decode(type: [Transaction].self, decoder: decoder)
//                    .receive(on : DispatchQueue.main)
//                    .sink(receiveCompletion: { completion in
//                        switch completion {
//                        case .failure(let error):
//                            print("Error fetching transactions:", error.localizedDescription)
//                        case .finished:
//                            print("Finished fetching transactions")
//                        }
//                    }, receiveValue: { [weak self] result in
//                        self?.transactions = result
//                        print("Transactions: \(result)")
//                    })
//                    .store(in: &cancellables)
//            }

//    Below are the code for debugging
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else {
//                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            do {
//                let transactions = try JSONDecoder().decode([Transaction].self, from: data)
//                print("Decoded transactions:", transactions)
//            } catch DecodingError.keyNotFound(let key, let context) {
//                print("Could not find key \(key) in JSON: \(context.debugDescription)")
//            } catch DecodingError.typeMismatch(let type, let context) {
//                print("Type mismatch for type \(type) in JSON: \(context.debugDescription)")
//            } catch DecodingError.valueNotFound(let type, let context) {
//                print("Missing expected value of type \(type) in JSON: \(context.debugDescription)")
//            } catch DecodingError.dataCorrupted(let context) {
//                print("Corrupted data: \(context.debugDescription)")
//            } catch {
//                print("Error decoding JSON: \(error.localizedDescription)")
//            }
//        }.resume()
    
//    func groupTransactionsByMonth() -> TransactionGroup {
//        guard !transactions.isEmpty else { return [:] }
//
//        let inputFormatter = DateFormatter.allNumericUS
//        let monthYearFormatter = DateFormatter()
//        monthYearFormatter.dateFormat = "MMMM yyyy"
//
//        var dateCache = [String: Date]()
//        let groupedTransactions = transactions.reduce(into: [String: [Transaction]]()) { (acc, transaction) in
//            let transactionDate = dateCache[transaction.date] ?? inputFormatter.date(from: transaction.date)
//            dateCache[transaction.date] = transactionDate // Cache it for later use
//
//            if let transactionDate = transactionDate {
//                let monthYearKey = monthYearFormatter.string(from: transactionDate)
//                acc[monthYearKey, default: []].append(transaction)
//            }
//        }
//
//        return groupedTransactions.mapValues { transactions in
//            transactions.sorted { $0.date > $1.date }
//        }.sorted(by: { monthYearFormatter.date(from: $0.key) ?? Date.distantPast > monthYearFormatter.date(from: $1.key) ?? Date.distantPast })
//          .reduce(into: OrderedDictionary<String, [Transaction]>()) { (result, tuple) in
//            result[tuple.key] = tuple.value
//        }
//    }
    
    func groupTransactionsByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] }
        
        let groupedTransactions = TransactionGroup(grouping: filteredTransactions) { $0.month }
     
        return groupedTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        print("accumulateTransactions")
        
        guard !transactions.isEmpty else {return [] }
        
        // MARK: update the actual date when publishing the application
//        let today = "02/17/2022".dateParsed() // Date()
        let today = todayString.dateParsed()
        print("today's date is", today)
        let dateInterval = Calendar.current.dateInterval(of: .month, for: today)!
        print("dateInterval", dateInterval)
        
        var sum: Double = .zero
        var cumulativeSum = TransactionPrefixSum()
        
        for date in stride(from: dateInterval.start, to: today, by: 60 * 60 * 24) {
            let dailyExpenses = transactions.filter{ $0.dateParsed == date && $0.isExpense }
            let dailyTotal = dailyExpenses.reduce(0) { $0 - $1.signedAmount } // subtraction will turn the negative amount into the positive total amount
            
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            cumulativeSum.append((date.formatted(), sum))
            print(date.formatted(), "dailyTotal:", dailyTotal, "sum:", sum)
        }
        
        return cumulativeSum
    }
    
    private func fetchTransaction(withId id: UUID) {
        print("Fetching transaction with ID: \(id)")
        ref.child("transactions").queryOrdered(byChild: "id").queryEqual(toValue: id.uuidString).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            guard let snapshot = snapshot.children.allObjects.first as? DataSnapshot,
                  let value = snapshot.value as? [String: Any] else {
                print("Transaction not found")
                return
            }

            let transaction = self.createTransactionFromDictionary(value)
            DispatchQueue.main.async {
                self.currentTransaction = transaction
                print("Fetched transaction: \(transaction)")
            }
        }
    }
    
    private func createTransactionFromDictionary(_ value: [String: Any]) -> Transaction {
        let transactionId = UUID(uuidString: value["id"] as? String ?? "") ?? UUID()
        return Transaction(
            id: transactionId,
            createdAt: value["date"] as? String ?? "",
            institution: value["institution"] as? String ?? "",
            account: value["account"] as? String ?? "",
            merchant: value["merchant"] as? String ?? "",
            amount: value["amount"] as? Double ?? 0.0,
            type: value["type"] as? String ?? "",
            categoryId: value["categoryId"] as? Int ?? 0,
            category: value["category"] as? String ?? "",
            isPending: value["isPending"] as? Bool ?? false,
            isTransfer: value["isTransfer"] as? Bool ?? false,
            isExpense: value["isExpense"] as? Bool ?? false,
            isEdited: value["isEdited"] as? Bool ?? false
        )
    }
}
