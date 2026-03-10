//
//  AccountView.swift
//  ConquestSupportApp
//
//  Account/settings: profile info and sign out (Phase 1).
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 24) {
                    profileCard
                    signOutButton
                }
                .padding(20)
                .padding(.top, AppHeaderView.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background)

            VStack(spacing: 0) {
                AppHeaderView()
                    .frame(height: AppHeaderView.height)
                    .frame(maxWidth: .infinity)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Signed in as")
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.titleTextColor)
            Text(sessionManager.currentUserEmail.isEmpty ? sessionManager.currentUserDisplayName : sessionManager.currentUserEmail)
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.titleTextColor)
            Divider()
            HStack {
                Text("Organization")
                    .font(AppTheme.calloutFont)
                    .foregroundStyle(AppTheme.titleTextColor)
                Spacer()
                Text(sessionManager.currentOrganizationName)
                    .font(AppTheme.calloutFont)
                    .foregroundStyle(AppTheme.conquestRed)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground).opacity(0.98))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppTheme.conquestRed.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private var signOutButton: some View {
        Button {
            sessionManager.signOut()
        } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(AppTheme.buttonFont)
                .foregroundStyle(AppTheme.buttonForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PrimaryActionButtonStyle())
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environmentObject(SessionManager())
    }
}
