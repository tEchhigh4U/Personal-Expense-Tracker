//
//  NewTransactionView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 2/9/2024.
//

import SwiftUI

enum AlertType: Identifiable {
    case success
    case error(String)

    var id: String {
        switch self {
        case .success:
            return "success"
        case .error(let message):
            return message
        }
    }
}

struct NewTransactionView: View {
    @ObservedObject var transactionView = TransactionEntryViewModel()
    
    @State private var transactionDate: Date = Date()
    @State private var showDatePicker = false
    @State private var alertType: AlertType?
    
    var formIsValid: Bool {
        !transactionView.institution.isEmpty &&
        !transactionView.account.isEmpty &&
        !transactionView.merchant.isEmpty &&
        !transactionView.amount.isEmpty &&
        transactionView.categoryId != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")){
                    Button(action: {
                        withAnimation {
                            self.showDatePicker.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("Date: \(transactionDate, formatter: DateFormatter.allNumericUS)")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if showDatePicker {
                        DatePicker(
                            "Select Date",
                            selection: $transactionDate,
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
                        TextField("Amount(HKD)", text: $transactionView.amount)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section(header: Text("Type & Category")) {
                        Picker("Type", selection: $transactionView.type) {
                            Text("Select a type").tag(Int?.none)
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }

                        Picker("Category", selection: $transactionView.categoryId) {
                            Text("Select a category").tag(Int?.none)
                            ForEach(transactionView.categories, id: \.id) { category in
                                Text(category.name).tag(category.id as Int?)
                            }
                        }
                        .onChange(of: transactionView.categoryId) { newValue in
                            if let categoryId = newValue,
                               let selectedCategory = transactionView.categories.first(where: { $0.id == categoryId }) {
                                transactionView.category = selectedCategory.name
                            } else {
                                transactionView.category = ""
                            }
                        }
                    }
                
                Section {
                    Button(action: {
                        transactionView.createdAt = DateFormatter.allNumericUS.string(from: transactionDate)
                        transactionView.saveNewTransaction { success, errorMessage in
                            if success {
                                alertType = .success
                            } else {
                                alertType = .error(errorMessage ?? "An unknown error occurred.")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Save Transaction")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(!formIsValid)
                }
            }
            .alert(item: $alertType) { type -> Alert in
                switch type {
                case .success:
                    return Alert(title: Text("Success"), message: Text("Transaction created successfully."), dismissButton: .default(Text("OK")))
                case .error(let message):
                    return Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK"), action: {
                        transactionView.errorMessage = nil
                    }))
                }
            }
            .navigationBarTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                customizeNavigationBar()
                print("Form is valid: \(formIsValid)")
            }
            .onDisappear {
                resetNavigationBar()
            }
        }
    }
    
    private func customizeNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 14)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func resetNavigationBar() {
        UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance()
        UINavigationBar.appearance().compactAppearance = UINavigationBarAppearance()
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
    }
}

// Preview provider for SwiftUI Canvas
struct NewTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NewTransactionView()
            NewTransactionView()
                .preferredColorScheme(.dark)
        }
    }
}
