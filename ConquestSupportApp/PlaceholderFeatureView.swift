//
//  PlaceholderFeatureView.swift
//  ConquestSupportApp
//
//  Placeholder for Phase 2 features (Invoices, Maintenance, Special Requests).
//

import SwiftUI

struct PlaceholderFeatureView: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.conquestRed.opacity(0.6))
            Text("Coming in Phase 2")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.titleTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PlaceholderFeatureView(title: "Invoices")
    }
}
