//
//  EmptyStateView.swift
//  ExpenseTrackerDemo
//
//  Created by William Hui on 15/9/2024.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.full")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.customIcon)
                .padding()
                .background(Circle().fill(Color.customIcon.opacity(0.2)))
                .shadow(radius: 10, x: 5, y: 5)
            
            Text("No transactions were found")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .background(Color(.systemBackground))
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
