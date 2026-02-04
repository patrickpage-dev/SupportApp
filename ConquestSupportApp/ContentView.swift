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

    /// Single source of truth for support contact; digits derived for tel/copy.
    private let supportPhoneDisplay = "770-953-2500"
    private var supportPhoneDigits: String { supportPhoneDisplay.filter(\.isNumber) }
    private let supportEmail = "support@csatlanta.com"
    /// Top padding for logo hierarchy; kept small so top content sits higher (safe area handles notch).
    private let topPadding: CGFloat = 8
    /// Max logo height; keeps top group compact so content sits higher.
    private let logoMaxHeight: CGFloat = 180
    /// Minimum vertical space reserved below main content for future Sign In section.
    private let minHeightReservedForFutureSignIn: CGFloat = 100

    /// Add Conquest Solutions logo to Assets as "ConquestLogo" to replace this placeholder.
    private static let logoAssetName = "ConquestLogo"

    @State private var showCallUnavailableAlert = false
    @State private var showEmailUnavailableAlert = false
    @State private var showEmailCopiedAlert = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 24) {
                logoView(availableWidth: geo.size.width)

                // Future: Sign In section goes here
                Spacer(minLength: minHeightReservedForFutureSignIn)

                VStack(spacing: 24) {
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
                    .buttonStyle(PrimaryActionButtonStyle())

                    Button {
                        UIPasteboard.general.string = supportEmail
                        showEmailCopiedAlert = true
                    } label: {
                        Label("Copy Email", systemImage: "link")
                                .font(AppTheme.calloutFont)
                                .foregroundStyle(AppTheme.titleTextColor)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(Color.primary.opacity(0.2), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 32)
                }

                footerView
                    .padding(.bottom, 24)
            }
            .padding(EdgeInsets(top: topPadding, leading: 16, bottom: 16, trailing: 16))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppTheme.background)
            .alert("Call Not Available", isPresented: $showCallUnavailableAlert) {
                Button("Copy Number") {
                    UIPasteboard.general.string = supportPhoneDigits
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text("This device cannot place calls. Support number: \(supportPhoneDisplay)")
            }
            .alert("Email Not Available", isPresented: $showEmailUnavailableAlert) {
                Button("Copy Email") {
                    UIPasteboard.general.string = supportEmail
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Could not open mail. Support email: \(supportEmail)")
            }
            .alert("Email copied", isPresented: $showEmailCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Support email has been copied to the clipboard.")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Logo area: same width as primary buttons, max height capped; preserves transparency and aspect ratio.
    /// If the mark still looks small, the asset may have large transparent padding; a tighter-cropped asset would improve perceived size.
    private func logoView(availableWidth: CGFloat) -> some View {
        let logoWidth = availableWidth - 64
        return Group {
            if UIImage(named: Self.logoAssetName) != nil {
                Image(Self.logoAssetName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: logoWidth, maxHeight: logoMaxHeight)
                    .accessibilityLabel("Conquest Solutions logo")
            } else {
                // Placeholder when logo asset is missing; responsive width-based size.
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.primary.opacity(0.12))
                    .frame(width: logoWidth, height: 80)
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
        .padding(.horizontal, 32)
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
        .opacity(0.85)
    }

    private func openCall() {
        guard let url = URL(string: "tel://\(supportPhoneDigits)") else { return }
        openURL(url) { accepted in
            if !accepted {
                showCallUnavailableAlert = true
            }
        }
    }

    private func openEmail() {
        guard let url = buildMailtoURL() else { return }
        openURL(url) { accepted in
            if !accepted {
                showEmailUnavailableAlert = true
            }
        }
    }

    /// Builds mailto URL with subject, body template, and optional app/iOS version lines.
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
        var lines = [
            "Name:",
            "Company / Property:",
            "Best callback #:",
            "Issue summary:",
            "When did it start:",
            "Impact (1 user / many / outage):"
        ]
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            lines.append("App version: \(appVersion) (\(build))")
        }
        lines.append("iOS version: \(UIDevice.current.systemVersion)")
        return lines.joined(separator: "\n\n")
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

#Preview {
    ContentView()
}
