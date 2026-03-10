//
//  LoginView.swift
//  ConquestSupportApp
//
//  Sign-in screen: email, password, validation, mock auth (Phase 1).
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var sessionManager: SessionManager

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showSupportSheet = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && password.count >= 4
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Conquest Client Portal")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.titleTextColor)
                    .padding(.top, 40)

                cardContent
            }
            .padding(.horizontal, 20)
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
            NavigationStack {
                SupportView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { showSupportSheet = false }
                        }
                    }
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sign In")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.titleTextColor)

            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(AppTheme.calloutFont)
                    .foregroundStyle(AppTheme.titleTextColor)
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .onChange(of: email) { _, _ in errorMessage = nil }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(AppTheme.calloutFont)
                    .foregroundStyle(AppTheme.titleTextColor)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .onChange(of: password) { _, _ in errorMessage = nil }
            }

            if let message = errorMessage {
                Text(message)
                    .font(AppTheme.calloutFont)
                    .foregroundStyle(AppTheme.conquestRed)
            }

            Button {
                attemptSignIn()
            } label: {
                Label("Sign In", systemImage: "arrow.right.circle.fill")
                    .font(AppTheme.buttonFont)
                    .foregroundStyle(AppTheme.buttonForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.buttonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(sessionManager.isSigningIn || !isFormValid)

            Button("Forgot Password?") {
                // Placeholder; non-functional for Phase 1
            }
            .font(AppTheme.calloutFont)
            .foregroundStyle(AppTheme.conquestRed)
            .frame(maxWidth: .infinity)

            Button("Need Help? Contact Support") {
                showSupportSheet = true
            }
            .font(AppTheme.calloutFont)
            .foregroundStyle(AppTheme.titleTextColor.opacity(0.8))
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

    private func attemptSignIn() {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            errorMessage = "Please enter your email."
            return
        }
        if password.count < 4 {
            errorMessage = "Please enter a password with at least 4 characters."
            return
        }
        errorMessage = nil
        focusedField = nil
        Task {
            await sessionManager.signIn(email: trimmed, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionManager())
}
