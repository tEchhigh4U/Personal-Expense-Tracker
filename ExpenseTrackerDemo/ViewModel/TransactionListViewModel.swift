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
import UIKit

typealias TransactionGroup = OrderedDictionary<String, [Transaction]> // [String: [Transaction]] is a dictionary type
typealias TransactionPrefixSum = [(String, Double)] // a record of accumulated sum

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []  // initialized empty object
    @Published var searchText = ""
    @Published var isLoading = false
    
    private var ref: DatabaseReference = Database.database().reference()
    private var cancellables = Set<AnyCancellable>() // empty object
    
    // MARK: used in search bar
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return transactions
        } else {
            return transactions.filter { transaction in
                // Date handling
                let date = transaction.createdAt.dateParsed()
                let formattedDate = DateFormatter.allNumericUS.string(from: date)
                
                // Check for matches in text fields
                let textMatches = transaction.merchant.lowercased().contains(searchText.lowercased()) ||
                transaction.category.lowercased().contains(searchText.lowercased()) ||
                transaction.institution.lowercased().contains(searchText.lowercased()) ||
                transaction.account.lowercased().contains(searchText.lowercased()) ||
                formattedDate.contains(searchText.lowercased()) ||
                formattedDate.contains(searchText.uppercased())
                    
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
                    id: transactionId.uuidString,
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
    
    func groupTransactionsByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] }
        
        let groupedTransactions = TransactionGroup(grouping: filteredTransactions) { $0.month }
     
        return groupedTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        guard !transactions.isEmpty else {return [] }
        
        // Get today's date as a formatted string in the extension file
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
            id: transactionId.uuidString,
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
    
    func exportTransactionsInCSV(transactions: [Transaction]) {
        let fileName = "Transactions_export.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = "Created At,Institution,Account,Merchant,Amount,Type,Category,Is Transfer,Is Expense,Is Edited\n"

        for transaction in transactions {
            let newLine = """
            \(transaction.createdAt),\(transaction.institution),\(transaction.account),\(transaction.merchant),\(transaction.amount),\(transaction.type),\(transaction.category),\(transaction.isTransfer),\(transaction.isExpense),\(transaction.isEdited)\n
            """
            csvText.append(contentsOf: newLine)
        }

        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            // Ensure that we are able to get the current window scene
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("Unable to find a window scene")
                return
            }
            
            let activityVC = UIActivityViewController(activityItems: [path!], applicationActivities: nil)
            rootViewController.present(activityVC, animated: true, completion: nil)
        } catch {
            print("Failed to write CSV file: \(error.localizedDescription)")
        }
    }
}
