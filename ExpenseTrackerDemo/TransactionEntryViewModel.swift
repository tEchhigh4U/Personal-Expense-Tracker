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
    @Published var date: String = ""
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
    
    private func isExpense(categoryId: Int) -> Bool {
        // Transfer (id: 9), Income (id: 7), and Paycheque (id: 701) are not expenses
        return ![9, 7, 701].contains(categoryId)
    }

    private func isTransfer(categoryId: Int) -> Bool {
        return categoryId == 9 // Transfer category id
    }

    func createTransaction(completion: @escaping (Bool, String?) -> Void) {
        guard let parsedAmount = Double(amount), let categoryId = categoryId else {
            // handle the error
            completion(false, "Invalid amount or missing category.")
            return
        }
        
        let isExpense = self.isExpense(categoryId: categoryId)
        let isTransfer = self.isTransfer(categoryId: categoryId)
        let transactionId = UUID().uuidString

        let transactionDict: [String: Any] = [
            "id": transactionId,
            "date": date,
            "institution": institution,
            "account": account,
            "merchant": merchant,
            "amount": parsedAmount,
            "type": type.rawValue,
            "categoryId": categoryId,
            "category": category,
            "isPending": false,
            "isTransfer": isTransfer,
            "isExpense": isExpense,
            "isEdited": false
        ]
        
        // save the transaction to the Firebase using the UUID
        dbRef.child("transactions/\(transactionId)").setValue(transactionDict) { error, _ in
            if let error = error {
                completion(false, "Failed to save transaction: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
}
