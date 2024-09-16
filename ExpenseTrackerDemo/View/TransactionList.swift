//
//  TransactionList.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 20/8/2024.
//

import SwiftUI

struct TransactionList: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    @State private var searchText = ""
    @State private var activeTransaction: Transaction?
    @State private var isNavigationActive = false
    @State private var isExportOptionsVisible = false
    
    var body: some View {
        NavigationView {
                    VStack {
                        // MARK: Search bar
                        SearchBar(searchText: $transactionListVM.searchText)
                        
                        Spacer()
                        
                        if transactionListVM.groupTransactionsByMonth().isEmpty {
                            EmptyStateView()
                        } else {
                            List {
                                // MARK: Transaction list
                                ForEach(Array(transactionListVM.groupTransactionsByMonth()), id: \.key) { month, transactions in
                                    Section {
                                        ForEach(transactions) { transaction in
                                            TransactionRow(transaction: transaction) {
                                                self.activeTransaction = transaction
                                                self.isNavigationActive = true
                                            }
                                        }
                                    } header: {
                                        Text(month)
                                    }
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    .background(
                        NavigationLink(destination: activeTransaction.map { EditTransactionView(transactionView: TransactionEntryViewModel(transaction: $0)) }, isActive: $isNavigationActive) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    .navigationTitle("Transactions")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: ExportRecordsView(), isActive: $isExportOptionsVisible) {
                                Button(action: {
                                    self.isExportOptionsVisible = true
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                }
            }
}

struct TransactionList_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData // Ensure this data is properly formatted and populated
        return transactionListVM
    }()
    
    static var previews: some View {
        Group {
            NavigationView {
                TransactionList()
            }
            NavigationView {
                TransactionList()
                    .preferredColorScheme(.dark)
            }
        }
        .environmentObject(transactionListVM)
    }
}


