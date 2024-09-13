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
            ZStack{
                ScrollView{
                    VStack(alignment: .leading, spacing: 24) {
                        //MARK: Title
                        Text("Welcome Back 👋")
                            .font(.largeTitle) // Larger text
                            .fontWeight(.heavy)
                            .foregroundColor(Color.primary)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                        
                        Text("Expense Overview  - \(todayString.dateParsed().formatted())")
                            .font(.title2) // Slightly smaller than title but larger than title3
                            .fontWeight(.bold)
                            .foregroundColor(Color.secondary)
                            .cornerRadius(10)
                        
                        // MARK: Expense Chart
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
                            .frame(height: 300)
                            
                        }
                        
                        // MARK: Transaction List
                        RecentTransactionList()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .background(Color.customBackground)
                .navigationBarTitleDisplayMode(.inline)
                
                if transactionListVM.isLoading {
                    ProgressView()
                        .scaleEffect(3)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .zIndex(1) // Ensure the spinner is above other content
                }
            }
            .toolbar {
                // MARK: Refresh button
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        transactionListVM.refreshTransactions()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                // MARK: Create a new transaction record
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isShowingNewRecordView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.customIcon)
                            .background(Circle().fill(Color.white).shadow(radius: 3))
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingNewRecordView) {
                NewTransactionView(transactionView: TransactionEntryViewModel())
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

