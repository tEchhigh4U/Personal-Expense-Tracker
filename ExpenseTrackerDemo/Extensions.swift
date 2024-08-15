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
    static let allNumericUS: DateFormatter = {
        print("Initializing DateFormatter")
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
//        formatter.locale = Locale(identifier: "en_HK")
//        formatter.timeZone = TimeZone(identifier: "Asia/Hong_Kong")
        
        return formatter
    }()
}

extension String {
    func dateParsed() -> Date {
        guard let parsedDate = DateFormatter.allNumericUS.date(from: self) else { return Date()}
        
        return parsedDate
    }
}

//extension JSONDecoder.DateDecodingStrategy {
//    static let custom = custom(from: DateFormatter.allNumericHK)
//    
//    static func custom(from formatter: DateFormatter) -> JSONDecoder.DateDecodingStrategy {
//        return .custom { decoder -> Date in
//            let container = try decoder.singleValueContainer()
//            let dateStr = try container.decode(String.self)
//            if let date = formatter.date(from: dateStr) {
//                return date
//            }
//            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
//        }
//    }
//}

