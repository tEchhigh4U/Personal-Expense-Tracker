//
//  EditTransactionView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 11/9/2024.
//

import SwiftUI

struct EditTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var transactionView: TransactionEntryViewModel
    
    @State private var alertType: AlertType?
    @State private var amount: Double
    @State private var selectedDate: Date
    @State private var selectedCategoryId: Int
    @State private var showingCategoryGrid = false
    
    init(transactionView: TransactionEntryViewModel) {
        self.transactionView = transactionView
        _amount = State(initialValue: Double(transactionView.amount) ?? 0)
        _selectedDate = State(initialValue: transactionView.createdAt.dateParsed())
        _selectedCategoryId = State(initialValue: transactionView.categoryId ?? 0)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    TextField("Enter merchant name", text: $transactionView.merchant)
                        .keyboardType(.default)
                    
                    TextField("Amount (HKD)", value: $amount, format: .currency(code: "HKD"))
                        .keyboardType(.decimalPad)
                        .onChange(of: amount) { newValue in
                            transactionView.amount = String(format: "%.2f", newValue)
                        }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .onChange(of: selectedDate) { newDate in
                            transactionView.createdAt = DateFormatter.allNumericUS.string(from: newDate)
                        }
                }
                
                Section(header: Text("Category")) {
                    Button(action: {
                        showingCategoryGrid = true
                    }) {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(Category.all.first { $0.id == selectedCategoryId }?.name ?? "Select")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showingCategoryGrid) {
                        CategoryGridView(selectedCategoryId: $selectedCategoryId)
                    }
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        transactionView.saveTransaction { success, errorMessage in
                            if success {
                                alertType = .success
                            } else {
                                alertType = .error(errorMessage ?? "An unknown error occurred.")
                            }
                        }
                    }
                }
            }
            .onAppear {
                print("Transaction ID: \(transactionView.transactionId ?? "nil")")
                guard let transactionIdString = transactionView.transactionId else {
                    DispatchQueue.main.async {
                        print("Invalid or missing transactionId: \(transactionView.transactionId ?? "nil")")
                    }
                    return
                }

                transactionView.loadTransactionData(for: transactionIdString) { loadedTransactionId in
                    DispatchQueue.main.async {
                        print("Transaction ID loaded for editing: \(loadedTransactionId)")
                    }
                }
            }
            .alert(item: $alertType) { alertType in
                switch alertType {
                case .success:
                    return Alert(title: Text("Success"), message: Text("Transaction saved successfully"), dismissButton: .default(Text("OK"), action: {
                        presentationMode.wrappedValue.dismiss()
                    }))
                case .error(let message):
                    return Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        EditTransactionView(transactionView: TransactionEntryViewModel())
    }
}
