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
    @State private var showingCategoryGrid = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var formIsValid: Bool {
        let institutionValid = !transactionView.institution.isEmpty
        let accountValid = !transactionView.account.isEmpty
        let merchantValid = !transactionView.merchant.isEmpty
        let amountValid = !transactionView.amount.isEmpty
        let isAmountValid: Bool = Double(transactionView.amount) != nil
        let isCategoryIdValid: Bool = Category.all.contains { $0.id == transactionView.categoryId}
        
        // Debugging outputs
        // print("Institution valid: \(institutionValid)")
        // print("Account valid: \(accountValid)")
        // print("Merchant valid: \(merchantValid)")
        // print("Amount valid: \(amountValid) and is a valid number: \(isAmountValid)")
        print("Category ID valid in the VALID form: \(isCategoryIdValid)")

        return institutionValid && accountValid && merchantValid && amountValid && isAmountValid && isCategoryIdValid
    }
    
    init(transactionView: TransactionEntryViewModel) {
        self.transactionView = transactionView
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
                            "Select a transaction date",
                            selection: $transactionDate,
                            in: ...Date(), // Range from the past up to the current date
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    // MARK: Transaction Instiution
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.gray)
                        TextField("Institution or Bank", text: $transactionView.institution)
                            .overlay(
                                HStack {
                                    Spacer() // Pushes the button to the right
                                    if !transactionView.institution.isEmpty {
                                        Button(action: {
                                            transactionView.institution = "" // Clears the text field
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8) // Adds some padding to the right side
                                    }
                                }
                            )
                    }
                    
                    // MARK: Transaction Account
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.gray)
                        TextField("Account Name or Number", text: $transactionView.account)
                            .overlay(
                                HStack{
                                    Spacer()
                                    if !transactionView.account.isEmpty {
                                        Button(action:{
                                            transactionView.amount = ""
                                        }){
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            )
                    }
                    
                    // MARK: Transaction Merchant
                    HStack {
                        Image(systemName: "cart")
                            .foregroundColor(.gray)
                        TextField("Merchant", text: $transactionView.merchant)
                            .overlay(
                                HStack{
                                    Spacer()
                                    if !transactionView.merchant.isEmpty {
                                        Button(action:{
                                            transactionView.merchant = ""
                                        }){
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            )
                    }
                    
                    // MARK: Transaction Amount
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.gray)
                        TextField("Amount(HKD)", text: $transactionView.amount)
                            .keyboardType(.decimalPad)
                            .overlay(
                                HStack{
                                    Spacer()
                                    if !transactionView.amount.isEmpty {
                                        Button(action:{
                                            transactionView.amount = ""
                                        }){
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            )
                    }
                }
                
                Section(header: Text("Type & Category")) {
                    Picker("Type", selection: $transactionView.type) {
                        Text("Select a type").tag(Int?.none)
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
//                                            Picker("Category", selection: $transactionView.categoryId) {
//                                                Text("Select a category").tag(Int?.none)
//                                                ForEach(transactionView.categories, id: \.id) { category in
//                                                    Text(category.name).tag(category.id as Int?)
//                                                }
//                                            }
//                                            .onChange(of: transactionView.categoryId) { newValue in
//                                                if let categoryId = newValue,
//                                                   let selectedCategory = transactionView.categories.first(where: { $0.id == categoryId }) {
//                                                    transactionView.category = selectedCategory.name
//                                                } else {
//                                                    transactionView.category = ""
//                                                }
//                                            }
                    
                    Button(action: {
                        showingCategoryGrid = true
                    }) {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(transactionView.selectedCategoryName)
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showingCategoryGrid, onDismiss: {
                        print("Sheet dismissed. Current selectedCategoryId: \($transactionView.categoryId)")
                    }) {
                        CategoryGridView(selectedCategoryId: $transactionView.categoryId, selectedCategoryName: $transactionView.category)
                    }
                }
                
                Section {
                    Button(action: {
                        transactionView.createdAt = DateFormatter.allNumericUS.string(from: transactionDate)
                        transactionView.saveNewTransaction { success, errorMessage in
                            if success {
                                alertType = .success
                                presentationMode.wrappedValue.dismiss()
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
            NewTransactionView(transactionView: TransactionEntryViewModel())
            NewTransactionView(transactionView: TransactionEntryViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
