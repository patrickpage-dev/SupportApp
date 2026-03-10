//
//  LoginView.swift
//  ConquestSupportApp
//
//  Sign-in screen: SSO-style buttons (Google, Microsoft), placeholder auth flow.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var sessionManager: SessionManager

    @State private var showSupportSheet = false

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Conquest Client Portal")
                        .font(AppTheme.calloutFont)
                        .foregroundStyle(AppTheme.titleTextColor.opacity(0.9))

                    cardContent
                }
                .padding(.horizontal, 20)
                .padding(.top, AppHeaderView.height + 16)
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
        .overlay {
            if sessionManager.isSigningIn {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.white)
                }
            }
        }
        .sheet(isPresented: $showSupportSheet) {
            SupportQuickAccessView(onDismiss: { showSupportSheet = false })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sign In")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.titleTextColor)

            if let message = sessionManager.lastAuthError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(AppTheme.conquestRed)
                    Text(message)
                        .font(AppTheme.calloutFont)
                        .foregroundStyle(AppTheme.conquestRed)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.conquestRed.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button {
                Task { await sessionManager.signInWithGoogle() }
            } label: {
                HStack(spacing: 12) {
                    Image("googleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Continue with Google")
                        .font(AppTheme.buttonFont)
                        .foregroundStyle(AppTheme.titleTextColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.conquestRed.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(sessionManager.isSigningIn)

            Button {
                Task { await sessionManager.signInWithMicrosoft() }
            } label: {
                HStack(spacing: 12) {
                    Image("microsoftIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Continue with Microsoft")
                        .font(AppTheme.buttonFont)
                        .foregroundStyle(AppTheme.titleTextColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.conquestRed.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(sessionManager.isSigningIn)

            Button {
                showSupportSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "headphones")
                    Text("Need Help? Contact Support")
                        .fontWeight(.medium)
                }
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.conquestRed)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
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
}

#Preview {
    LoginView()
        .environmentObject(SessionManager())
}
