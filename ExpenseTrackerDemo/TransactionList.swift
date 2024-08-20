//
//  TransactionList.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 20/8/2024.
//

import SwiftUI

struct TransactionList: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        VStack {
            List{
                // Mark: transaction Groups
                ForEach(Array(transactionListVM.groupTransactionByMonth()), id:\.key){ month,
                    transactions in
                    Section{
                        // Mark: Transaction List
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    } header: {
                        Text(month)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TransactionList_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactioinListVM  = TransactionListViewModel()
        transactioinListVM.transactions = transactionListPreviewData
        return transactioinListVM
    }()
    
    static var previews: some View {
        Group {
            NavigationView{
                TransactionList()
            }
            NavigationView{
                TransactionList()
                    .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
            }
        }
        .environmentObject(transactionListVM)
    }
}
