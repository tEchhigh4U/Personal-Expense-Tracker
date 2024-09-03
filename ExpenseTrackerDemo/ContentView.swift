//
//  ContentView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel // Type
    //    var demoData: [Double] = [8, 2, 4, 6, 19, 22]
    @State private var isShowingNewRecordView = false
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 24) {
                    //MARK: Title
                    Text("Overview - \(todayString.dateParsed().formatted())" )
                        .font(.title2)
                        .bold()
                    
                    // MARK: Chart
                    let data = transactionListVM.accumulateTransactions()
                    
                    if !data.isEmpty {
                        let totalExpense = data.last?.1 ?? 0
                        CardView {
                            VStack(alignment: .leading){
                                ChartLabel(totalExpense.formatted(.currency(code: "HKD")), type: .title, format: "HK$%.02f")
                                
                                LineChart()
                            }
                            .background(Color.customSystemBackground)
                        }
                        .data(data)
                        .chartStyle(ChartStyle(backgroundColor: Color.customSystemBackground, foregroundColor: ColorGradient(Color.icon.opacity(0.4), Color.icon)))
                        .frame(height: 250)
                        
                    }
                    
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
                    Menu {
                        Button("Create a new record", action: {
                            self.isShowingNewRecordView = true
                        })
                    } label: {
                        // Image(systemName: "bell.badge")
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.customIcon, .primary)
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingNewRecordView) {
                NewTransactionView()
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
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
}
