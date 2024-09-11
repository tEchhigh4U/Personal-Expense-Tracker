//
//  TransactionEntryViewModel.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 2/9/2024.
//

import Foundation
import SwiftUI
import Firebase

class TransactionEntryViewModel: ObservableObject {
    @Published var transactionId: String?  // Handles existing transactions
    @Published var createdAt: String = ""
    @Published var institution: String = ""
    @Published var account: String = ""
    @Published var merchant: String = ""
    @Published var amount: String = ""
    @Published var type: TransactionType = .debit
    @Published var categoryId: Int? = nil
    @Published var category: String = ""
    
    @Published var errorMessage: String?     // To display error messages
    @Published var transactionStatus: Bool?  // To indicate success or failure

    var categories = Category.all
    
    private var dbRef: DatabaseReference = Database.database().reference()

    init(transaction: Transaction? = nil) {
        if let transaction = transaction {
            self.transactionId = transaction.id.uuidString  // Assuming `transaction.id` is a String already
            self.createdAt = transaction.createdAt
            self.institution = transaction.institution
            self.account = transaction.account
            self.merchant = transaction.merchant
            self.amount = String(transaction.amount)
            self.type = .debit
            self.categoryId = transaction.categoryId
            self.category = transaction.category
        }
    }
    
    func loadTransactionData() {
        guard let transactionId = transactionId else {
            print("No transaction ID provided.")
            self.errorMessage = "No transaction ID provided."
            return
        }
        
        dbRef.child("transactions").child(transactionId).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("Snapshot data: \(snapshot)")
                DispatchQueue.main.async {
                    self.updateData(from: snapshot)
                }
            } else {
                print("No data found for transaction ID \(transactionId)")
                DispatchQueue.main.async {
                    self.errorMessage = "No data found for the specified transaction ID."
                }
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func updateData(from snapshot: DataSnapshot) {
        if let data = snapshot.value as? [String: Any] {
            print("Data dictionary: \(data)")
            self.merchant = data["merchant"] as? String ?? ""
            self.amount = data["amount"] as? String ?? ""
            self.createdAt = data["createdAt"] as? String ?? ""
            self.categoryId = data["categoryId"] as? Int
        } else {
            print("Error: Data fetched is not in the expected format")
            self.errorMessage = "Data fetched is not in the expected format"
        }
    }
    
    func saveTransaction(completion: @escaping (Bool, String?) -> Void) {
        guard let parsedAmount = Double(amount), let categoryId = categoryId else {
            completion(false, "Invalid amount or missing category.")
            return
        }
        
        let transactionDict: [String: Any] = [
            "date": createdAt,
            "institution": institution,
            "account": account,
            "merchant": merchant,
            "amount": parsedAmount,
            "type": type.rawValue,
            "categoryId": categoryId,
            "category": category,
            "isPending": false,
            "isTransfer": categoryId == 9,
            "isExpense": ![9, 7, 701].contains(categoryId),
            "isEdited": true
        ]
        
        let transactionPath = transactionId ?? UUID().uuidString  // Use existing ID or generate a new one
        
        dbRef.child("transactions").child(transactionPath).setValue(transactionDict) { error, _ in
            if let error = error {
                completion(false, "Failed to save transaction: \(error.localizedDescription)")
            } else {
                self.transactionId = transactionPath  // Ensure the ID is updated/assigned
                completion(true, nil)
            }
        }
    }
}
