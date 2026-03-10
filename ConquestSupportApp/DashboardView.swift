//
//  DashboardView.swift
//  ConquestSupportApp
//
//  Post-login dashboard: welcome and portal feature cards.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Binding var selectedTab: AppTab

    private let cardCorner: CGFloat = 14

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                welcomeSection
                featureCards
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome")
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.titleTextColor)
            Text(sessionManager.currentUserDisplayName)
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.titleTextColor)
            Text(sessionManager.currentOrganizationName)
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.conquestRed)
        }
    }

    private var featureCards: some View {
        VStack(spacing: 12) {
            NavigationLink {
                PlaceholderFeatureView(title: "Invoices")
            } label: {
                dashboardCard(title: "Invoices", symbol: "doc.text", subtitle: "View and pay invoices")
            }
            .buttonStyle(.plain)

            NavigationLink {
                PlaceholderFeatureView(title: "Maintenance")
            } label: {
                dashboardCard(title: "Maintenance", symbol: "wrench.and.screwdriver", subtitle: "Maintenance requests")
            }
            .buttonStyle(.plain)

            NavigationLink {
                PlaceholderFeatureView(title: "Special Requests")
            } label: {
                dashboardCard(title: "Special Requests", symbol: "envelope.badge", subtitle: "Submit special requests")
            }
            .buttonStyle(.plain)

            Button {
                selectedTab = .support
            } label: {
                dashboardCard(title: "Support", symbol: "headset", subtitle: "Call or email support")
            }
            .buttonStyle(.plain)
        }
    }

    private func dashboardCard(title: String, symbol: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.conquestRed)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.titleTextColor)
                Text(subtitle)
                    .font(AppTheme.calloutFont)
                    .foregroundStyle(AppTheme.titleTextColor.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.titleTextColor.opacity(0.6))
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: cardCorner)
                .fill(Color(.systemBackground).opacity(0.98))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cardCorner)
                .strokeBorder(AppTheme.conquestRed.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        DashboardView(selectedTab: .constant(.dashboard))
            .environmentObject(SessionManager())
    }
}
