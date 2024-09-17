//
//  ExportRecordsView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 16/9/2024.
//

import SwiftUI

struct ExportRecordsView: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Text("Tap the button below to export all transactions into a CSV file. \n\nThe file can then be saved as a backup.")
                    .padding(.vertical, 5)
                
                // MARK: Export Button
                Section {
                    Button(action: {
                        showAlert = true
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
            .alert("Secure Your Data", isPresented: $showAlert) {
                Button("OK", role: .cancel) { 
                    transactionListVM.exportTransactionsInCSV(transactions: transactionListVM.transactions)
                }
            }
            message: {
                Text("Please keep your data safe and secure. \n\n Do NOT share your CSV with others.")
            }
        }
    }
}

#Preview {
    ExportRecordsView()
}
