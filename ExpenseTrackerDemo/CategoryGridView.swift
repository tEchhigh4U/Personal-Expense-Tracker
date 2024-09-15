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
    @Binding var selectedCategoryName: String
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    var categories: [Category] = Category.all
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories, id: \.id) { category in
                    VStack {
                        // MARK: Categroy Icon
                        FontIcon.text(.awesome5Solid(code: category.icon), fontsize: 28, color: .customIcon)
                            .frame(width: 60, height: 60)
                            .padding(.bottom, 5)

                        // MARK: Category Name
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
                        print("Setting selectedCategoryId from \(String(describing: self.selectedCategoryId)) to \(category.id)")
                        self.selectedCategoryId = category.id
                        selectedCategoryName = category.name
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
            // Mock data for preview purposes
            let mockCategoryId: Int? = 1
            let mockCategoryName: String = "Sample Category"
            
            CategoryGridView(selectedCategoryId: .constant(mockCategoryId), selectedCategoryName: .constant(mockCategoryName))
            CategoryGridView(selectedCategoryId: .constant(mockCategoryId), selectedCategoryName: .constant(mockCategoryName))
                .preferredColorScheme(.dark)
        }
    }
}
