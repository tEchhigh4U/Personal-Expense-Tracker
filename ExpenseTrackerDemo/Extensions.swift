//
//  Extensions.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation
import SwiftUI

extension Color {
    static let customBackground = Color("Background")
    static let customIcon = Color("Icon")
    static let customText = Color("Text")
    static let customSystemBackground = Color(uiColor: .systemBackground)
}

extension DateFormatter{
    static let allNumericHK: DateFormatter = {
        print("Initializing DateFormatter")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        return formatter
    }()
}

extension String {
    func dateParsed() -> Date {
        guard let parsedDate = DateFormatter.allNumericHK.date(from: self) else { return Date()}
        
        return parsedDate
    }
}
