//
//  CategoryGridView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 12/9/2024.
//

import SwiftUI
import SwiftUIFontIcon

struct CategoryGridView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedCategoryId: Int?
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    var categories: [Category] = Category.all
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories, id: \.id) { category in
                    VStack {
                        // FontIcon with consistent sizing and alignment
                        FontIcon.text(.awesome5Solid(code: category.icon), fontsize: 28, color: .customIcon)
                            .frame(width: 60, height: 60)
                            .padding(.bottom, 5)

                        // Text with controlled font size and alignment
                        Text(category.name)
                            .font(.system(size: category.name.count > 9 ? 12 : 14)) // Smaller font for longer names
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding()
                    .frame(width: 115, height: 140)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .onTapGesture {
                        // print("Category selected with ID: \(category.id)")
                        self.selectedCategoryId = category.id
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding()
        }
    }
}

struct CategoryGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CategoryGridView(selectedCategoryId: .constant(1))
            CategoryGridView(selectedCategoryId: .constant(1))
                .preferredColorScheme(.dark)
        }
    }
}
