//
//  NewTransactionView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 2/9/2024.
//

import SwiftUI

struct NewTransactionView: View {
    @ObservedObject var transactionView = TransactionEntryViewModel()
    @State private var showConfirmation = false
    
    @State private var transactionDate: Date = Date()
    @State private var showDatePicker = false // State to toggle visibility of the DatePicker
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    Button(action: {
                        self.showDatePicker.toggle()
                    }){
                        HStack{
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("Date: \(transactionDate, formatter: DateFormatter.allNumericUS)")
                                .foregroundColor(.black)
                        }
                    }
                    
                    // Conditionally display the DatePicker
                    if showDatePicker {
                        DatePicker(
                            "Select Date",
                            selection: $transactionDate,
                            displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                        
                    HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.gray)
                            TextField("Institution", text: $transactionView.institution)
                    }
                        
                    HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(.gray)
                            TextField("Account", text: $transactionView.account)
                        }
                        
                    HStack {
                            Image(systemName: "cart")
                                .foregroundColor(.gray)
                            TextField("Merchant", text: $transactionView.merchant)
                        }
                        
                    HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.gray)
                            TextField("Amount(HKD)", text: $transactionView.amount)
                        }
                        
                    Picker("Type", selection: $transactionView.type) {
                        Text("Select a category").tag(Int?.none) // Ensure there's an option for nil
                        ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        
                    Picker("Category", selection: $transactionView.categoryId) {
                            ForEach(transactionView.categories, id: \.id) { category in
                                Text(category.name).tag(category.id as Optional<Int>)
                            }
                        }
                    }
                    
                    Button(action: {
                        if let _ = transactionView.createTransaction() {
                            // Handle your transaction logic here
                            showConfirmation = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Submit")
                                .fontWeight(.bold)
                        }
                    }
                    .alert(isPresented: $showConfirmation) {
                        Alert(title: Text("Success"), message: Text("Transaction created successfully."), dismissButton: .default(Text("OK")))
                    }
                }
                .navigationBarTitle("New Transaction")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear{
                    customizeNavigationBar()
                }
                .onDisappear{
                    resetNavigationBar()
                }
            }
        }
    }

    private func customizeNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 14)]
        
        // Apply the appearance to all navigation bar states
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func resetNavigationBar() {
        UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance()
        UINavigationBar.appearance().compactAppearance = UINavigationBarAppearance()
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
    }
    
    // Preview provider for SwiftUI Canvas
    struct NewTransactionView_Previews: PreviewProvider {
        static var previews: some View {
            Group{
                NewTransactionView()
                NewTransactionView()
                    .preferredColorScheme(.dark)
            }
        }
    }

