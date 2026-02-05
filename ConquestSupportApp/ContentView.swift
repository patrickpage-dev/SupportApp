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
    /// Top padding for pinned logo (below safe area).
    private let topPadding: CGFloat = 4
    /// Max logo height; keeps top group compact so content sits higher.
    private let logoMaxHeight: CGFloat = 180
    /// Conquest blog URL for in-app Safari sheet.
    private let blogURL = URL(string: "https://csatlanta.com/resources/blog/")!
    /// Reserved height for pinned footer so scroll content is not obscured (~90–120pt).
    private let footerHeightReserved: CGFloat = 100
    /// Reserved height for pinned logo so scroll content starts below it.
    private let logoHeightReserved: CGFloat = 190
    /// Height of the visible pinned header surface that receives the shadow (logo + top padding).
    private let pinnedHeaderHeight: CGFloat = 185

    /// Add Conquest Solutions logo to Assets as "ConquestLogo" to replace this placeholder.
    private static let logoAssetName = "ConquestLogo"

    @State private var showCallUnavailableAlert = false
    @State private var showEmailUnavailableAlert = false
    @State private var showEmailCopiedAlert = false
    @State private var showEmailOptions = false
    @State private var showBlogSafari = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Action group: directly under logo
                        VStack(spacing: 16) {
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
                        showEmailOptions = true
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
                }
                .padding(.top, 8)

                // Conquest Blog section
                VStack(spacing: 12) {
                    Text("Conquest Blog")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.titleTextColor)
                    Text("Updates, security tips, and IT insights.")
                        .font(AppTheme.calloutFont)
                        .foregroundStyle(AppTheme.titleTextColor)
                        .multilineTextAlignment(.center)
                    Button {
                        showBlogSafari = true
                    } label: {
                        Label("View Blog", systemImage: "arrow.up.right.square")
                            .font(AppTheme.calloutFont)
                            .foregroundStyle(AppTheme.titleTextColor)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color.primary.opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 24)

                    }
                    .padding(EdgeInsets(top: logoHeightReserved, leading: 16, bottom: footerHeightReserved + 24, trailing: 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(AppTheme.background)
                            .frame(height: pinnedHeaderHeight)
                        logoView(availableWidth: geo.size.width)
                            .padding(.top, topPadding)
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .frame(height: pinnedHeaderHeight)
                    .frame(maxWidth: .infinity)
                    .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 2)

                    Color.clear
                        .frame(height: max(0, logoHeightReserved - pinnedHeaderHeight))

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)

                footerView
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .alert("Email Support", isPresented: $showEmailOptions) {
                Button("Compose Email") {
                    openEmail()
                }
                Button("Copy Email") {
                    UIPasteboard.general.string = supportEmail
                    showEmailCopiedAlert = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose an option")
            }
            .sheet(isPresented: $showBlogSafari) {
                SafariView(url: blogURL)
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

    /// Builds mailto URL with subject and body template.
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
        let lines = [
            "Name:",
            "Company/Property:",
            "Best callback #:",
            "Issue Summary:"
        ]
        return lines.joined(separator: "\n")
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
