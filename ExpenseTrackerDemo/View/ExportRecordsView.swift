//
//  ExportRecordsView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 16/9/2024.
//

import SwiftUI

struct ExportRecordsView: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Text("Tap the button below to export all transactions into a CSV file. \nThe file can then be shared or saved as needed.")
                    .padding(.vertical, 5)
                
                Section {
                    Button(action: {
                        transactionListVM.exportTransactionsInCSV(transactions: transactionListVM.transactions)
                    }) {
                        Text("Export to CSV")
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.customIcon)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationBarTitle("Export Transaction", displayMode: .inline)
        }
    }
}

#Preview {
    ExportRecordsView()
}
