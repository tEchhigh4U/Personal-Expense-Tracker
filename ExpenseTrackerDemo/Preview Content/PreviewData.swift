//
//  PreviewData.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation

var transactionPreviewData = Transaction(id: 1, date: "13/08/2024", institution: "HSBC HONG KONG", account: "Visa HSBC HONG KONG", merchant: "Apple", amount: 1500.50, type: "debit", categroyId: 801, category: "Software", isPending: false, isTransfer: false, isExpense: true, isEdited: false)

var transactionListPreviewData = [Transaction](repeating: transactionPreviewData, count: 10)
