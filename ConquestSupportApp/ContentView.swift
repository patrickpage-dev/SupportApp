//
//  ContentView.swift
//  ConquestSupportApp
//
//  Created by Patrick Page on 2/3/26.
//

import SwiftUI
import UIKit

// MARK: - PreferenceKey for measured header height (Dynamic Type–safe layout)

private struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// Drives a single alert; only one alert is shown at a time.
private enum ActiveAlert: Identifiable {
    case callUnavailable
    case emailUnavailable
    case emailOptions
    case invalidBlogURL
    var id: Self { self }
}

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Single source of truth for support contact; digits derived for tel/copy.
    private let supportPhoneDisplay = "770-953-2500"
    private var supportPhoneDigits: String { supportPhoneDisplay.filter(\.isNumber) }
    private let supportEmail = "support@csatlanta.com"
    /// Top padding for pinned logo (below safe area).
    private let topPadding: CGFloat = 4
    /// Max logo height; keeps top group compact so content sits higher.
    private let logoMaxHeight: CGFloat = 180
    /// Conquest blog URL string for in-app Safari sheet; validated before opening.
    private let blogURLString = "https://csatlanta.com/resources/blog/"
    /// Height of the pinned header surface (single source of truth for header bar).
    private let pinnedHeaderHeight: CGFloat = 185
    /// Reject header measurements above this to avoid full-screen values pushing content off-screen.
    private let maxReasonableHeaderHeight: CGFloat = 500

    /// Our Services list (all 7 items in order).
    private let servicesList: [(title: String, symbol: String)] = [
        ("Managed IT (On Prem and Cloud)", "server.rack"),
        ("Access Control", "lock.shield"),
        ("Cameras", "video.fill"),
        ("Telecom Solutions", "antenna.radiowaves.left.and.right"),
        ("Networking", "network"),
        ("Cybersecurity", "shield.fill"),
        ("Backup & Disaster Recovery", "arrow.clockwise.icloud.fill")
    ]

    /// Services to show: all when expanded, first 2 when collapsed.
    private var visibleServices: [(title: String, symbol: String)] {
        isServicesExpanded ? servicesList : Array(servicesList.prefix(2))
    }

    /// Add Conquest Solutions logo to Assets as "ConquestLogo" to replace this placeholder.
    private static let logoAssetName = "ConquestLogo"
    /// Cached so logoView does not call UIImage(named:) on every body evaluation.
    private static let hasLogoAsset: Bool = UIImage(named: Self.logoAssetName) != nil

    @State private var activeAlert: ActiveAlert?
    /// Used by .alert(item:) for 2-button alerts; not set for .emailOptions (uses confirmationDialog).
    @State private var alertItem: ActiveAlert?
    @State private var showEmailOptionsDialog = false
    @State private var showBlogSafari = false
    @State private var blogURLToOpen: URL?
    @State private var showEmailCopiedConfirmation = false
    @State private var measuredHeaderHeight: CGFloat = 0
    @State private var isServicesExpanded = false
    @State private var isSupportBorderBreathing = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
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
                        activeAlert = .emailOptions
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
                        .strokeBorder(AppTheme.conquestRed.opacity(reduceMotion ? 0.25 : (isSupportBorderBreathing ? 0.35 : 0.15)), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .onAppear {
                    if !reduceMotion {
                        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                            isSupportBorderBreathing = true
                        }
                    }
                }

                // Conquest Blog section
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(AppTheme.conquestRed.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "newspaper.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(AppTheme.conquestRed)
                            }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Conquest Blog")
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.titleTextColor)
                            Text("Updates, security tips, and IT insights.")
                                .font(AppTheme.calloutFont)
                                .foregroundStyle(AppTheme.titleTextColor)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer(minLength: 0)
                    }
                    Button {
                        guard let url = URL(string: blogURLString), url.scheme != nil else {
                            activeAlert = .invalidBlogURL
                            alertItem = .invalidBlogURL
                            return
                        }
                        blogURLToOpen = url
                        showBlogSafari = true
                    } label: {
                        Label("View Blog", systemImage: "arrow.up.right")
                            .font(AppTheme.buttonFont)
                            .foregroundStyle(AppTheme.buttonForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.conquestRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
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
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Our Services section
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isServicesExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Our Services")
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.titleTextColor)
                            Spacer()
                            Image(systemName: isServicesExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.titleTextColor)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Our Services")
                    .accessibilityValue(isServicesExpanded ? "Expanded" : "Collapsed")
                    .accessibilityHint("Double tap to expand or collapse")

                    ForEach(Array(visibleServices.enumerated()), id: \.element.title) { index, item in
                        ourServicesTile(title: item.title, symbol: item.symbol)
                        if index < visibleServices.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 20)

                    footerView
                        .padding(.top, 20)
                    }
                    .padding(EdgeInsets(top: max(measuredHeaderHeight, logoMaxHeight + topPadding), leading: 16, bottom: 32, trailing: 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(AppTheme.background)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        logoView(availableWidth: geo.size.width)
                            .padding(.top, topPadding)
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .frame(height: pinnedHeaderHeight)
                    .frame(maxWidth: .infinity)
                    .background(GeometryReader { g in
                        Color.clear.preference(key: HeaderHeightKey.self, value: g.size.height)
                    })
                    .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 2)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)
                // Header is decorative; enable hit testing if header becomes interactive (e.g., sign-in/profile).
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onPreferenceChange(HeaderHeightKey.self) { value in
                if value > 0, value <= maxReasonableHeaderHeight { measuredHeaderHeight = value }
            }
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
                            activeAlert = nil
                        },
                        secondaryButton: .cancel(Text("OK")) { alertItem = nil; activeAlert = nil }
                    )
                case .emailUnavailable:
                    return Alert(
                        title: Text("Email Not Available"),
                        message: Text("Could not open mail. Support email: \(supportEmail)"),
                        primaryButton: .default(Text("Copy Email")) {
                            copySupportEmail()
                            alertItem = nil
                            activeAlert = nil
                        },
                        secondaryButton: .cancel(Text("OK")) { alertItem = nil; activeAlert = nil }
                    )
                case .emailOptions:
                    fatalError("emailOptions uses confirmationDialog")
                case .invalidBlogURL:
                    return Alert(
                        title: Text("Blog Unavailable"),
                        message: Text("The blog link is misconfigured. Please try again later."),
                        dismissButton: .cancel(Text("OK")) { alertItem = nil; activeAlert = nil }
                    )
                }
            }
            .confirmationDialog("Email Support", isPresented: $showEmailOptionsDialog, titleVisibility: .visible) {
                Button("Compose Email") {
                    showEmailOptionsDialog = false
                    activeAlert = nil
                    openEmail()
                }
                Button("Copy Email") {
                    copySupportEmail()
                    showEmailOptionsDialog = false
                    activeAlert = nil
                }
                Button("Cancel", role: .cancel) {
                    showEmailOptionsDialog = false
                    activeAlert = nil
                }
            } message: {
                Text("Choose an option")
            }
            .sheet(isPresented: $showBlogSafari) {
                if let url = blogURLToOpen {
                    SafariView(url: url)
                } else {
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Logo area: same width as primary buttons, max height capped; preserves transparency and aspect ratio.
    /// If the mark still looks small, the asset may have large transparent padding; a tighter-cropped asset would improve perceived size.
    private func logoView(availableWidth: CGFloat) -> some View {
        let logoWidth = availableWidth - 64
        return Group {
            if Self.hasLogoAsset {
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

    /// List row for Our Services: icon + label; no tile/button styling.
    private func ourServicesTile(title: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.conquestRed)
                .frame(width: 24, height: 24, alignment: .center)
            Text(title)
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.titleTextColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                activeAlert = .callUnavailable
                alertItem = .callUnavailable
            }
        }
    }

    private func openEmail() {
        guard let url = buildMailtoURL() else { return }
        openURL(url) { accepted in
            if !accepted {
                activeAlert = .emailUnavailable
                alertItem = .emailUnavailable
            }
        }
    }

    /// Copies support email to pasteboard and shows inline confirmation (VoiceOver-friendly).
    private func copySupportEmail() {
        UIPasteboard.general.string = supportEmail
        showEmailCopiedConfirmation = true
        UIAccessibility.post(notification: .announcement, argument: "Support email copied to clipboard")
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
