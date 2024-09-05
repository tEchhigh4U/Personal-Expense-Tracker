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

    func createTransaction(completion: @escaping (Bool, String?) -> Void) {
        guard let parsedAmount = Double(amount), let categoryId = categoryId else {
            // handle the error
            completion(false, "Invalid amount or missing category.")
            return
        }

        let transactionDict: [String: Any] = [
            "date": date,
            "institution": institution,
            "account": account,
            "merchant": merchant,
            "amount": parsedAmount,
            "type": type.rawValue,
            "categoryId": categoryId,
            "category": category,
            "isPending": false,
            "isTransfer": false,
            "isExpense": true,
            "isEdited": false
        ]
        
        // generate a unique ID for each transaction
        let transactionId = dbRef.child("transaction").childByAutoId().key ?? "default_id"
        
        // save the transaction to the Firebase
        dbRef.child("transactions/\(transactionId)").setValue(transactionDict) { error, _ in
            if let error = error {
                completion(false, "Failed to save transaction: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
}
