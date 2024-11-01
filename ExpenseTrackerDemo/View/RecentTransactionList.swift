//
//  RecentTransactionList.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 15/8/2024.
//

import SwiftUI

struct RecentTransactionList: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        VStack{
            HStack{
                // Mark: Header Title
                Text("Recent Transactions")
                    .bold()
                
                Spacer()
                
                // Mark: Header Link
                NavigationLink{
                    TransactionList()
                } label: {
                    HStack(spacing:4){
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(Color.text)
                }
            }
            .padding()
            
            // Mark: Recent Transaction List
            ForEach(Array(transactionListVM.transactions.prefix(5).enumerated()), id:\.element){index, transaction in
                TransactionRow(transaction: transaction, onDoubleClick: {
                    print("Transaction clicked in the recent transaction list")
                })
                
                // Seperate each row clearly for better readibilty
                Divider()
                    .opacity(index == 4 ? 0 : 1)
            }
        }
        .padding()
        .background(Color.customSystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.primary.opacity(0.2), radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: 0, y: 5)
    }
}

struct RecentTransactionList_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactioinListVM  = TransactionListViewModel()
        transactioinListVM.transactions = transactionListPreviewData
        return transactioinListVM
    }()
    
    static var previews: some View {
        Group{
            RecentTransactionList()
            RecentTransactionList()
                .preferredColorScheme(.dark)
        }
        .environmentObject(transactionListVM)
    }
}
