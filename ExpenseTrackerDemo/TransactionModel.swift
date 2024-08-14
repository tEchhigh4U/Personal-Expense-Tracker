//
//  TransactionModel.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: Int
    let date: String
    let institution: String
    let account: String
    var merchant: String
    let amount: Double
    let type: TransactionType.RawValue
    var categoryId: Int
    var category: String
    let isPending: Bool
    var isTransfer: Bool
    var isExpense: Bool
    var isEdited: Bool
    
    // Computed property to parse date string to Date    
    var dateParsed: Date {
        return date.dateParsed()
    }
    
    var signedAmount: Double {
        return type == TransactionType.credit.rawValue ? amount : -amount
    }
}

enum TransactionType: String {
    case debit = "debit"
    case credit = "credit"
}
