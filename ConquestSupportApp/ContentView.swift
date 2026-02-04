//
//  ContentView.swift
//  ConquestSupportApp
//
//  Created by Patrick Page on 2/3/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    private let supportPhoneNumber = "770-953-2500"
    private let supportEmail = "support@csatlanta.com"
    /// Top padding for logo hierarchy (logo no longer vertically centered).
    private let topPadding: CGFloat = 24

    /// Add Conquest Solutions logo to Assets as "ConquestLogo" to replace this placeholder.
    private static let logoAssetName = "ConquestLogo"

    @State private var showCallUnavailableAlert = false
    @State private var showEmailUnavailableAlert = false

    var body: some View {
        VStack(spacing: 24) {
            logoView

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
                .buttonStyle(.plain)

                Button {
                    openEmail()
                } label: {
                    Label("Email Support", systemImage: "envelope.fill")
                        .font(AppTheme.buttonFont)
                        .foregroundStyle(AppTheme.buttonForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.buttonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)

            Spacer()

            footerView
                .padding(.bottom, 24)
        }
        .padding()
        .padding(.top, topPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .alert("Call Not Available", isPresented: $showCallUnavailableAlert) {
            Button("Copy Number") {
                UIPasteboard.general.string = "7709532500"
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device cannot place calls. Support number: \(supportPhoneNumber)")
        }
        .alert("Email Not Available", isPresented: $showEmailUnavailableAlert) {
            Button("Copy Email") {
                UIPasteboard.general.string = supportEmail
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Could not open mail. Support email: \(supportEmail)")
        }
    }

    /// Logo area: original rendering preserves asset transparency.
    private var logoView: some View {
        Group {
            if UIImage(named: Self.logoAssetName) != nil {
                // Hero size; 200 pt balances prominence with spacing to buttons (title removed).
                Image(Self.logoAssetName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .accessibilityLabel("Conquest Solutions logo")
            } else {
                // Add Conquest Solutions logo to Assets as "ConquestLogo" to replace this placeholder.
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.primary.opacity(0.12))
                    .frame(height: 56)
                    .overlay {
                        HStack(spacing: 8) {
                            Image(systemName: "building.2")
                                .font(AppTheme.calloutFont)
                                .foregroundStyle(AppTheme.primary)
                            Text("Conquest Solutions")
                                .font(AppTheme.calloutFont)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
            }
        }
        .padding(.horizontal, 24)
    }

    /// Footer tagline: subtle, centered, near bottom.
    private var footerView: some View {
        VStack(spacing: 4) {
            Text("Providing")
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.titleTextColor)
            Text("IT and Security Solutions")
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.conquestRed)
            Text("Since 2004")
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.titleTextColor)
        }
        .multilineTextAlignment(.center)
    }

    private func openCall() {
        guard let url = URL(string: "tel://7709532500") else { return }
        openURL(url) { accepted in
            if !accepted {
                showCallUnavailableAlert = true
            }
        }
    }

    private func openEmail() {
        guard let url = URL(string: "mailto:\(supportEmail)") else { return }
        openURL(url) { accepted in
            if !accepted {
                showEmailUnavailableAlert = true
            }
        }
    }
}

#Preview {
    ContentView()
}
