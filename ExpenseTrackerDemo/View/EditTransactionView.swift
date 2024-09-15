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
    @State private var selectedCategoryId: Int? = nil
    @State private var showingCategoryGrid = false
    @State private var showingDeleteConfirmation = false
    @State private var showDatePicker = false
    
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
                    Button(action: {
                        withAnimation {
                            self.showDatePicker.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("Date: \(selectedDate, formatter: DateFormatter.allNumericUS)")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if showDatePicker {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.wheel)
                    }
                    
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.gray)
                        TextField("Institution or Bank", text: $transactionView.institution)
                    }
                    
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.gray)
                        TextField("Account name or number", text: $transactionView.account)
                    }
                    
                    HStack {
                        Image(systemName: "cart")
                            .foregroundColor(.gray)
                        TextField("Merchant", text: $transactionView.merchant)
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.gray)
                        TextField("Amount (HKD)", value: $amount, formatter: NumberFormatter.currency)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { newValue in
                                let formattedAmount = String(format: "%.2f", newValue)
                                transactionView.amount = formattedAmount
                                if let saveAmount = Double(formattedAmount) {
                                    amount = saveAmount
                                    print("Saved Amount to database: \($transactionView.amount)")
                            }
                        }
                    }
                }
                
                Section(header: Text("Type & Category")) {
                    Picker("Type", selection: $transactionView.type) {
                        Text("Select a type").tag(Int?.none)
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
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
                        CategoryGridView(selectedCategoryId: $selectedCategoryId, selectedCategoryName: $transactionView.category)
                    }
                }
                
                Section {
                    Button(action: {
                        transactionView.createdAt = DateFormatter.allNumericUS.string(from: selectedDate)
                        transactionView.saveTransaction { success, errorMessage in
                            if success {
                                alertType = .success
                            } else {
                                alertType = .error(errorMessage ?? "An unknown error occurred.")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.green)
                            Text("Update Transaction")
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showingDeleteConfirmation = true
                                }) {
                                    Image(systemName: "trash")
                                        .imageScale(.medium)
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .confirmationDialog("Are you sure you want to delete this transaction?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                transactionView.deleteTransaction { success, errorMessage in
                                    if success {
                                        alertType = .success
                                        presentationMode.wrappedValue.dismiss()
                                    } else {
                                        alertType = .error(errorMessage ?? "An unknown error occurred.")
                                    }
                                }
                            }
                            Button("Cancel", role: .cancel) {}
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

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            EditTransactionView(transactionView: TransactionEntryViewModel())
            EditTransactionView(transactionView: TransactionEntryViewModel())
                .preferredColorScheme(.dark)
        }
        
    }
}