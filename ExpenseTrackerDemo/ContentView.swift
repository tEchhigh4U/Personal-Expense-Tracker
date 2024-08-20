//
//  ContentView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    var demoData: [Double] = [8, 2, 4, 6, 19, 22]
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment: .leading, spacing: 24) {
                   //MARK: Title
                    Text("Overview")
                        .font(.title2)
                        .bold()
                    
                    // MARK: Chart
                    CardView {
                        VStack{
                            ChartLabel("1000", type: .title)
                            
                            LineChart()
                        }
                    }
                    .data(demoData)
                    .chartStyle(ChartStyle(backgroundColor: Color.customSystemBackground, foregroundColor: ColorGradient(Color.icon.opacity(0.4), Color.icon)))
                    .frame(height: 300)
                    
                    // MARK: Transaction List
                    RecentTransactionList()
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .background(Color.customBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: Notification Icon
                ToolbarItem {
                    Image(systemName: "bell.badge")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.customIcon, .primary)
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactioinListVM  = TransactionListViewModel()
        transactioinListVM.transactions = transactionListPreviewData
        return transactioinListVM
    }()
    
    static var previews: some View {
        Group{
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(transactionListVM)
        
    }
}
