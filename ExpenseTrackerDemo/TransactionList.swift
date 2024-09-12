//
//  TransactionList.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 20/8/2024.
//

import SwiftUI

struct TransactionList: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var searchText = ""
    @State private var activeTransaction: Transaction?
    @State private var isNavigationActive = false
    
    var body: some View {
        NavigationView {
                    VStack {
                        // MARK: Search bar
                        TextField("Search transactions...", text: $transactionListVM.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 10)
                            .padding(.top, 12)
                            .focused($isTextFieldFocused) // Bind the focus state to the text field
                            .onAppear {
                                // Optionally set the focus when the view appears
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.isTextFieldFocused = true
                                }
                            }
                        
                        Spacer()
                        
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
                    .background(
                        NavigationLink(destination: activeTransaction.map { EditTransactionView(transactionView: TransactionEntryViewModel(transaction: $0)) }, isActive: $isNavigationActive) {
                                            EmptyView()
                                        }
                                        .hidden()
                    )
                    .navigationTitle("Transactions")
                    .navigationBarTitleDisplayMode(.inline)
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


