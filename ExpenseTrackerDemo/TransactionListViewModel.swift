//
//  TransactionListViewModel.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation
import Combine
import Collections

typealias TransactionGroup = OrderedDictionary<String, [Transaction]> // [String: [Transaction]] is a dictionary type
typealias TransactionPrefixSum = [(String, Double)] // a record of accumulated sum

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []  // initialized empty object
    
    private var cancellables = Set<AnyCancellable>() // empty object
    
    // init method
    init(){
        getTransactions()
    }
    
    func getTransactions() {
        guard let url = URL(string: "https://designcode.io/data/transactions.json") else {
            print("Invalid URL is being used.")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.allNumericUS)
        
        
                URLSession.shared.dataTaskPublisher(for:url)
                    .tryMap { (data, response) -> Data in
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            dump(response)
                            throw URLError(.badServerResponse)
                        }
//                        let dataString = String(data: data, encoding: .utf8) ?? "Invalid data encoding"
//                            print("Received data: \(dataString)")
                        return data
                    }
                    .decode(type: [Transaction].self, decoder: decoder)
                    .receive(on : DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            print("Error fetching transactions:", error.localizedDescription)
                        case .finished:
                            print("Finished fetching transactions")
                        }
                    }, receiveValue: { [weak self] result in
                        self?.transactions = result
                        print("Transactions: \(result)")
                    })
                    .store(in: &cancellables)
            }

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
    
    func groupTransactionByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] }
        
        let groupTransactions = TransactionGroup(grouping: transactions) { $0.month }
        
        return groupTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        print("accumulateTransactions")
        
        guard !transactions.isEmpty else {return [] }
        
        // MARK: update the actual date when publishing the application
        let today = "02/17/2022".dateParsed() // Date()
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
}
