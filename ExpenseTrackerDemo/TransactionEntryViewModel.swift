//
//  TransactionEntryViewModel.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 2/9/2024.
//

import Foundation
import SwiftUI

class TransactionEntryViewModel: ObservableObject {
    @Published var date: String = ""
    @Published var institution: String = ""
    @Published var account: String = ""
    @Published var merchant: String = ""
    @Published var amount: String = ""
    @Published var type: TransactionType = .debit
    @Published var categoryId: Int? = nil
    @Published var category: String = ""
    

    var categories = Category.all
    
    private var nextTransactionId: Int = 1 // simplified id generation logic

    func createTransaction() -> Transaction? {
        guard let parsedAmount = Double(amount), let categoryId = categoryId else {
            return nil
        }

        let newTransaction = Transaction(
            id: nextTransactionId,
            date: date,
            institution: institution,
            account: account,
            merchant: merchant,
            amount: parsedAmount,
            type: type.rawValue,
            categoryId: categoryId,
            category: category,
            isPending: false,
            isTransfer: false,
            isExpense: true,
            isEdited: false
        )
        nextTransactionId += 1
        return newTransaction
    }
}
