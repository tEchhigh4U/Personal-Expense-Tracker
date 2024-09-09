//
//  TransactionModel.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/8/2024.
//

import Foundation
import SwiftUIFontIcon

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    let date: String
    let institution: String
    let account: String
    var merchant: String
    let amount: Double
    let type: TransactionType.RawValue
    var categoryId: Int
    var category: String
    let isPending: Bool
    var isTransfer: Bool
    var isExpense: Bool
    var isEdited: Bool
    
    var icon: FontAwesomeCode {
        if let category = Category.all.first(where: { $0.id == categoryId}) {
            return category.icon
        }
        
        return .question
    }
    
    // Computed property to parse date string to Date    
    var dateParsed: Date {
        return date.dateParsed()
    }
    
    var signedAmount: Double {
        return type == TransactionType.credit.rawValue ? amount : -amount
    }
    
    var month: String {
        dateParsed.formatted(.dateTime.year().month(.wide))
    }
}

enum TransactionType: String, CaseIterable {
    case debit = "debit"
    case credit = "credit"
}

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
    static let healthAndFitness = Category(id: 10, name: "Health & Fitness", icon: .heartbeat)
    static let education = Category(id: 11, name: "Education", icon: .graduation_cap)
    static let travel = Category(id: 12, name: "Travel", icon: .plane)
    static let giftsAndDonations = Category(id: 13, name: "Gifts & Donations", icon: .gift)
    static let investments = Category(id: 14, name: "Investments", icon: .chart_line)
    static let insurance = Category(id: 15, name: "Insurance", icon: .shield_alt)
    static let taxes = Category(id: 16, name: "Taxes", icon: .file_invoice)
    
    // Subcategories
    // Auto & Transport
    static let publicTransportation = Category(id: 101, name: "Public Transportation", icon: .bus, mainCategoryId: 1)
    static let taxi = Category(id: 102, name: "Taxi", icon: .taxi, mainCategoryId: 1)
    static let uber = Category(id: 103, name: "Uber", icon: .uber, mainCategoryId: 1)

    // Bills & Utilities
    static let mobilePhone = Category(id: 201, name: "Mobile Phone", icon: .mobile_alt, mainCategoryId: 2)

    // Entertainment
    static let moviesAndDVDs = Category(id: 301, name: "Movies & DVDs", icon: .film, mainCategoryId: 3)

    // Fees & Charges
    static let bankFee = Category(id: 401, name: "Bank Fee", icon: .hand_holding_usd, mainCategoryId: 4)
    static let fianceCharge = Category(id: 402, name: "Fiance Charge", icon: .hand_holding_usd, mainCategoryId: 4)

    // Food & Dining
    static let groceries = Category(id: 501, name: "Groceries", icon: .shopping_basket, mainCategoryId: 5)
    static let restaurants = Category(id: 502, name: "Restaurants", icon: .utensils, mainCategoryId: 5)

    // Home
    static let rent = Category(id: 601, name: "Rent", icon: .house_user, mainCategoryId: 6)
    static let homeSupplies = Category(id: 602, name: "Home Supplies", icon: .lightbulb, mainCategoryId: 6)

    // Income
    static let paycheque = Category(id: 701, name: "Paycheque", icon: .dollar_sign, mainCategoryId: 7)

    // Shopping
    static let software = Category(id: 801, name: "Software", icon: .icons, mainCategoryId: 8)

    // Transfer
    static let creditCardPayment = Category(id: 901, name: "Credit Card Payment", icon: .exchange_alt, mainCategoryId: 9)

    // Health & Fitness
    static let gymMembership = Category(id: 1001, name: "Gym Membership", icon: .dumbbell, mainCategoryId: 10)
    static let pharmacy = Category(id: 1002, name: "Pharmacy", icon: .capsules, mainCategoryId: 10)

    // Education
    static let tuition = Category(id: 1101, name: "Tuition", icon: .university, mainCategoryId: 11)
    static let books = Category(id: 1102, name: "Books", icon: .book, mainCategoryId: 11)

    // Travel
    static let airTravel = Category(id: 1201, name: "Air Travel", icon: .plane_departure, mainCategoryId: 12)
    static let hotel = Category(id: 1202, name: "Hotel", icon: .hotel, mainCategoryId: 12)

    // Gifts & Donations
    static let charitableDonations = Category(id: 1301, name: "Charitable Donations", icon: .hands_helping, mainCategoryId: 13)
    static let gifts = Category(id: 1302, name: "Gifts", icon: .gifts, mainCategoryId: 13)

    // Investments
    static let stocks = Category(id: 1401, name: "Stocks", icon: .chart_line, mainCategoryId: 14)
    static let bonds = Category(id: 1402, name: "Bonds", icon: .money_bill_wave, mainCategoryId: 14)

    // Insurance
    static let healthInsurance = Category(id: 1501, name: "Health Insurance", icon: .briefcase_medical, mainCategoryId: 15)
    static let carInsurance = Category(id: 1502, name: "Car Insurance", icon: .car, mainCategoryId: 15)

    // Taxes
    static let incomeTax = Category(id: 1601, name: "Income Tax", icon: .file_invoice_dollar, mainCategoryId: 16)
    static let propertyTax = Category(id: 1602, name: "Property Tax", icon: .home, mainCategoryId: 16)
}

extension Category {
    static let categories: [Category] = [
        .autoAndTransport,
        .billAndUtilities,
        .entertainment,
        .feesAndCharges,
        .foodAndDining,
        .home,
        .income,
        .shopping,
        .transfer,
        .healthInsurance,
        .education,
        .travel,
        .giftsAndDonations,
        .investments,
        .insurance,
        .taxes
    ]
    
    static let subCategories: [Category] = [
        .publicTransportation,
        .taxi,
        .uber,
        .mobilePhone,
        .moviesAndDVDs,
        .bankFee,
        .fianceCharge,
        .groceries,
        .restaurants,
        .rent,
        .homeSupplies,
        .paycheque,
        .software,
        .creditCardPayment,
        .gymMembership,
        .pharmacy,
        .tuition,
        .books,
        .airTravel,
        .hotel,
        .charitableDonations,
        .gifts,
        .stocks,
        .bonds,
        .healthInsurance,
        .carInsurance,
        .incomeTax,
        .propertyTax
    ]
    
    static let all: [Category] = categories + subCategories
}
