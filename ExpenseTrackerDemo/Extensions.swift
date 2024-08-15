//
//  Extensions.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation
import SwiftUI
import SwiftUIFontIcon

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

struct Category {
    let id: Int
    let name: String
    let icon: FontAwesomeCode
    var mainCategoryId: Int?
}

extension Category{
    // Main Category
    static let autoAndTransport = Category(id: 1, name: "Auto & Transport", icon: .car_alt)
    static let billAndUtilities = Category(id: 2, name: "Bills & Utilities", icon: .file_invoice_dollar)
    static let entertainment = Category(id:3, name: "Entertainment", icon: .film)
    static let feesAndCharges = Category(id:4, name:"Fees & Charges", icon: .hand_holding_usd)
    static let foodAndDining = Category(id:5, name:"Food & Dining", icon: .hamburger)
    static let home = Category(id:6, name:"Home", icon: .home)
    static let income = Category(id:7, name:"Income", icon: .dollar_sign)
    static let shopping = Category(id:8, name:"Shopping", icon: .shopping_cart)
    static let transfer = Category(id:9, name:"Transfer", icon: .exchange_alt)
    
    // Sub Category
    static let publicTransportation = Category(id:101, name:"Public Transportation", icon: .bus, mainCategoryId: 1)
    static let taxi = Category(id:102, name: "Taxi", icon: .taxi, mainCategoryId: 1)
    static let mobilePhone = Category(id: 201, name: "Mobile Phone", icon: .mobile_alt, mainCategoryId: 2)
    static let moviesAndDVDs = Category(id: 301, name: "Movies & DVDs", icon: .film, mainCategoryId: 3)
    static let bankFee = Category(id: 401, name: "Bank Fee", icon: .hand_holding_usd, mainCategoryId: 4)
    static let fianceCharge = Category(id: 402, name: "Fiance Charge", icon: .hand_holding_usd, mainCategoryId: 4)
    static let groceries = Category(id: 501, name: "Groceries", icon: .shopping_basket, mainCategoryId: 5)
    static let restaurants = Category(id:502, name: "Restaurants", icon: .utensils, mainCategoryId: 5)
    static let rent = Category(id: 601, name: "Rent", icon: .house_user, mainCategoryId: 6)
    static let homeSupplies = Category(id: 602, name: "Home Supplies", icon: .lightbulb, mainCategoryId: 6)
    static let paycheque = Category(id: 701, name: "Paycheque", icon: .dollar_sign, mainCategoryId: 7)
    static let software = Category(id: 801, name: "Software", icon: .icons, mainCategoryId: 8)
    static let creditCardPayment = Category(id: 901, name: "Credit Card Payment", icon: .exchange_alt, mainCategoryId: 9)
}
