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
            self.transactionId = transaction.id
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
    
    func loadTransactionData(for transactionId: String, completion: @escaping (String) -> Void) {
        let lowerCaseTransactionId = transactionId.lowercased()
        dbRef.child("transactions").child(lowerCaseTransactionId).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }

            if snapshot.exists() {
                self.updateData(from: snapshot)
                completion(transactionId)
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data found for the specified transaction ID."
                    print(self.errorMessage ?? "Error without message")
                }
            }
        }) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("Firebase error: \(self.errorMessage ?? "unknown error")")
            }
        }
    }

    private func updateData(from snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String: Any] else {
            self.errorMessage = "Data fetched is not in the expected format"
            return
        }

        DispatchQueue.main.async {
            self.merchant = data["merchant"] as? String ?? ""
            if let amount = data["amount"] as? Double {
                self.amount = String(amount)
            }
            self.createdAt = data["date"] as? String ?? ""
            self.categoryId = data["categoryId"] as? Int
        }
    }
    
    func saveTransaction(completion: @escaping (Bool, String?) -> Void) {
        guard let parsedAmount = Double(amount), let categoryId = categoryId, let transactionId = transactionId?.lowercased() else {
            completion(false, "Invalid amount, category, or missing transaction ID.")
            return
        }
        
        let transactionDict: [String: Any] = [
            "id": transactionId,
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
        
        dbRef.child("transactions").child(transactionId).updateChildValues(transactionDict) { error, _ in
            if let error = error {
                completion(false, "Failed to update transaction: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
    
    func saveNewTransaction(completion: @escaping (Bool, String?) -> Void) {
        print("Received amount: \(amount), category ID: \(String(describing: categoryId))")  // Verify what is received exactly
        guard let parsedAmount = Double(amount), let categoryId = categoryId else {
            completion(false, "Invalid amount or missing category ID.")
            return
        }
        
        // Generate a new transaction ID or handle it outside this function
        let newTransactionId = UUID().uuidString.lowercased()
        
        let newTransactionDict: [String: Any] = [
            "id": newTransactionId,
            "date": createdAt,
            "institution": institution,
            "account": account,
            "merchant": merchant,
            "amount": parsedAmount,
            "type": type.rawValue,
            "categoryId": categoryId,
            "category": category,
            "isPending": true,  // Assuming new transactions might be pending initially
            "isTransfer": categoryId == 9,
            "isExpense": ![9, 7, 701].contains(categoryId),
            "isEdited": false  // Assuming new transactions are not edited at the time of creation
        ]
        
        dbRef.child("transactions").child(newTransactionId).setValue(newTransactionDict) { error, _ in
            if let error = error {
                completion(false, "Failed to save new transaction: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
    
    func deleteTransaction(completion: @escaping (Bool, String?) -> Void) {
        guard let transactionId = transactionId?.lowercased() else {
            completion(false, "Missing transaction ID.")
            return
        }

        dbRef.child("transactions").child(transactionId).removeValue { error, _ in
            if let error = error {
                completion(false, "Failed to delete transaction: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
}
