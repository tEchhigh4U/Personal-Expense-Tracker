//
//  TransactionRow.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import SwiftUI
import SwiftUIFontIcon

struct TransactionRow: View {
    var transaction: Transaction
    
    var body: some View {
        HStack(spacing: 20){
            // Mark: Transaction Category Icon
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.icon.opacity(0.3))
                .frame(width: 44,height: 44)
                .overlay{
                    FontIcon.text(.awesome5Solid(code: .icons), fontsize: 24, color: Color.icon)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                // Mark: Transaction Merchant
                Text(transaction.merchant)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)
                
                // Mark: Transaction Category
                Text(transaction.category)
                    .font(.footnote)
                    .opacity(0.7)
                    .lineLimit(1)
                
                // Mark: Transaction Date
                Text(transaction.dateParsed, format: .dateTime.year().month().day())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
            }
            Spacer()
            
            // Mark: Transaction Amount
            Text(transaction.signedAmount, format: .currency(code: "HKD"))
                .bold()
                .foregroundStyle(transaction.type == TransactionType.credit.rawValue ? Color.text : .primary)
        }
        .padding([.top, .bottom],8)

    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview in light mode (default)
            TransactionRow(transaction: transactionPreviewData)

            // Preview in dark mode
            TransactionRow(transaction: transactionPreviewData)
                .preferredColorScheme(.dark)
        }
    }
}
