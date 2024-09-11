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
    @Binding var selectedCategoryId: Int
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    var categories: [Category] = Category.all
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories, id: \.id) { category in
                    VStack {
                        // FontIcon with consistent sizing and alignment
                        FontIcon.text(.awesome5Solid(code: category.icon), fontsize: 22, color: .blue)
                            .frame(width: 50, height: 50)  // Fixed frame size for uniformity
//                            .background(GeometryReader { geometry in
//                                Color.clear  // Using GeometryReader to ensure precise layout
//                                    .onAppear {
//                                        print("Icon width: \(geometry.size.width), height: \(geometry.size.height)")
//                                    }
//                            })
                            .padding(.bottom, 5)  // Consistent padding below the icon

                        // Text with controlled font size and alignment
                        Text(category.name)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)  // Center-align text for better aesthetics
                            .lineLimit(2)                     // Limiting text to two lines to avoid overflow
                    }
                    .padding()
                    .frame(width: 100, height: 120) // Explicit width and height for each grid item
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .onTapGesture {
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
        CategoryGridView(selectedCategoryId: .constant(1))
    }
}
