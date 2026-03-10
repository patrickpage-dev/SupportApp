//
//  SupportQuickAccessView.swift
//  ConquestSupportApp
//
//  Compact support-only view for signed-out users: Call and Email only.
//

import SwiftUI
import UIKit

private enum QuickSupportAlert: Identifiable {
    case callUnavailable
    case emailUnavailable
    var id: Self { self }
}

struct SupportQuickAccessView: View {
    @Environment(\.openURL) private var openURL
    var onDismiss: (() -> Void)?

    private let supportPhoneDisplay = "770-953-2500"
    private var supportPhoneDigits: String { supportPhoneDisplay.filter(\.isNumber) }
    private let supportEmail = "support@csatlanta.com"

    @State private var alertItem: QuickSupportAlert?
    @State private var showEmailOptionsDialog = false
    @State private var showEmailCopiedConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 0)
                Button("Done") {
                    onDismiss?()
                }
                .font(AppTheme.calloutFont)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.conquestRed)
                .padding(.trailing, 20)
                .padding(.top, 16)
            }

            ScrollView {
                VStack(spacing: 20) {
                    supportCard
                }
                .padding(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .task(id: showEmailCopiedConfirmation) {
            guard showEmailCopiedConfirmation else { return }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showEmailCopiedConfirmation = false
        }
        .alert(item: $alertItem) { alert in
            switch alert {
            case .callUnavailable:
                return Alert(
                    title: Text("Call Not Available"),
                    message: Text("This device cannot place calls. Support number: \(supportPhoneDisplay)"),
                    primaryButton: .default(Text("Copy Number")) {
                        UIPasteboard.general.string = supportPhoneDigits
                        alertItem = nil
                    },
                    secondaryButton: .cancel(Text("OK")) { alertItem = nil }
                )
            case .emailUnavailable:
                return Alert(
                    title: Text("Email Not Available"),
                    message: Text("Could not open mail. Support email: \(supportEmail)"),
                    primaryButton: .default(Text("Copy Email")) {
                        copySupportEmail()
                        alertItem = nil
                    },
                    secondaryButton: .cancel(Text("OK")) { alertItem = nil }
                )
            }
        }
        .confirmationDialog("Email Support", isPresented: $showEmailOptionsDialog, titleVisibility: .visible) {
            Button("Compose Email") {
                showEmailOptionsDialog = false
                openEmail()
            }
            Button("Copy Email") {
                copySupportEmail()
                showEmailOptionsDialog = false
            }
            Button("Cancel", role: .cancel) {
                showEmailOptionsDialog = false
            }
        } message: {
            Text("Choose an option")
        }
    }

    private var supportCard: some View {
        VStack(spacing: 16) {
            Text("Contact Support")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.titleTextColor)

            Text("Choose an option below to reach our support team.")
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.titleTextColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)

            VStack(spacing: 16) {
                Button {
                    openCall()
                } label: {
                    Label("Call Support", systemImage: "phone.fill")
                        .font(AppTheme.buttonFont)
                        .foregroundStyle(AppTheme.buttonForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.buttonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PrimaryActionButtonStyle())

                Button {
                    showEmailOptionsDialog = true
                } label: {
                    Label("Email Support", systemImage: "envelope.fill")
                        .font(AppTheme.buttonFont)
                        .foregroundStyle(AppTheme.buttonForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.buttonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .padding(.horizontal, 32)

            if showEmailCopiedConfirmation {
                Text("Support email copied to clipboard.")
                    .font(AppTheme.calloutFont)
                    .foregroundStyle(AppTheme.titleTextColor)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Support email copied to clipboard")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
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

    private func openCall() {
        guard let url = URL(string: "tel://\(supportPhoneDigits)") else { return }
        openURL(url) { accepted in
            if !accepted {
                alertItem = .callUnavailable
            }
        }
    }

    private func openEmail() {
        guard let url = buildMailtoURL() else { return }
        openURL(url) { accepted in
            if !accepted {
                alertItem = .emailUnavailable
            }
        }
    }

    private func copySupportEmail() {
        UIPasteboard.general.string = supportEmail
        showEmailCopiedConfirmation = true
        UIAccessibility.post(notification: .announcement, argument: "Support email copied to clipboard")
    }

    private func buildMailtoURL() -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Support Request"),
            URLQueryItem(name: "body", value: emailBodyTemplate())
        ]
        return components.url
    }

    private func emailBodyTemplate() -> String {
        ["Name:", "Company/Property:", "Best callback #:", "Issue Summary:"].joined(separator: "\n")
    }
}

#Preview {
    SupportQuickAccessView(onDismiss: nil)
}
