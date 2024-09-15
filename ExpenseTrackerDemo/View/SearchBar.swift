//
//  SearchBar.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 14/9/2024.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        TextField("Search transactions...", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.leading, 30)
            .padding(.trailing, 8)
            .focused($isTextFieldFocused)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minHeight: 48)
                        .padding(.top, 6)
                    Spacer()  // Keeps the image aligned to the left
                }
                .padding(.leading, 10),
                alignment: .leading
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isTextFieldFocused = true
                }
            }
    }
}
