//
//  PreviewData.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation

// Example UUID string
let uuidString = "9215cb5f12bd4a17a812c59b0e6d1985"

let transactionId = UUID(uuidString: uuidString) ?? UUID() // Provide a random UUID as default

var transactionPreviewData = Transaction(id: transactionId, date: "13/08/2024", institution: "HSBC HONG KONG", account: "Visa HSBC HONG KONG", merchant: "Apple", amount: 1500.50, type: "debit", categoryId:801, category: "Software", isPending: false, isTransfer: false, isExpense: true, isEdited: false)

var transactionListPreviewData = [Transaction](repeating: transactionPreviewData, count: 10)
