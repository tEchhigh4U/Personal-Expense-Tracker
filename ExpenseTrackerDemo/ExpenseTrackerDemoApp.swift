//
//  ExpenseTrackerDemoApp.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import SwiftUI

@main
struct ExpenseTrackerDemoApp: App {
    @StateObject var transactionListVM = TransactionListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionListVM)
        }
    }
}
