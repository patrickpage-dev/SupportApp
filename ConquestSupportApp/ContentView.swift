//
//  ContentView.swift
//  ConquestSupportApp
//
//  Created by Patrick Page on 2/3/26.
//

import SwiftUI
import UIKit

/// Drives a single alert; only one alert is shown at a time.
private enum ActiveAlert: Identifiable {
    case callUnavailable
    case emailUnavailable
    case invalidBlogURL
    case openWebsiteConfirm
    case openExternalLinkConfirm
    var id: Self { self }
}

private struct ServiceItem: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let url: URL
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
    /// Main site URL for logo tap; opens in external Safari.
    private let mainSiteURLString = "https://csatlanta.com/"
    /// Social / Maps URLs for footer; open in external Safari/Maps.
    private let mapsURLString = "https://www.google.com/maps/place/Conquest+Solutions/@33.9215452,-84.4688156,15z/data=!4m5!3m4!1s0x0:0xce1e5df2e294f4c5!8m2!3d33.9215452!4d-84.4688156"
    private let facebookURLString = "https://www.facebook.com/conquestsolutions/"
    private let linkedInURLString = "https://www.linkedin.com/company/conquestsolutions"
    /// Fixed height for the pinned header.
    private let headerHeight: CGFloat = 185

    /// Fallback URL when a service URL string is invalid (avoids force-unwrap at runtime).
    private static let serviceURLFallback: URL = URL(string: "https://csatlanta.com/")!
    private static func mustURL(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            assertionFailure("Invalid URL: \(string)")
            return Self.serviceURLFallback
        }
        return url
    }

    /// Our Services list (all 7 items in order) with URLs for tappable rows.
    private let servicesList: [ServiceItem] = [
        ServiceItem(id: "managed-it", title: "Managed IT (On Prem and Cloud)", symbol: "server.rack", url: Self.mustURL("https://csatlanta.com/it-solutions/")),
        ServiceItem(id: "access-control", title: "Access Control", symbol: "lock.shield", url: Self.mustURL("https://csatlanta.com/security-solutions/access-control/")),
        ServiceItem(id: "cameras", title: "Cameras", symbol: "video.fill", url: Self.mustURL("https://csatlanta.com/security-solutions/surveillance/")),
        ServiceItem(id: "telecom", title: "Telecom Solutions", symbol: "antenna.radiowaves.left.and.right", url: Self.mustURL("https://csatlanta.com/telecom-solutions/business-communication-systems/")),
        ServiceItem(id: "networking", title: "Networking", symbol: "network", url: Self.mustURL("https://csatlanta.com/telecom-solutions/business-internet/")),
        ServiceItem(id: "cybersecurity", title: "Cybersecurity", symbol: "shield.fill", url: Self.mustURL("https://csatlanta.com/it-solutions/business-it-services/cybersecurity/")),
        ServiceItem(id: "backup-dr", title: "Backup & Disaster Recovery", symbol: "arrow.clockwise.icloud.fill", url: Self.mustURL("https://csatlanta.com/it-solutions/backup-and-disaster-recovery-services/"))
    ]

    /// Services to show: first 3 when collapsed, all when expanded.
    private var visibleServices: [ServiceItem] {
        isServicesExpanded ? servicesList : Array(servicesList.prefix(3))
    }

    /// Add Conquest Solutions logo to Assets as "ConquestLogo" to replace this placeholder.
    private static let logoAssetName = "ConquestLogo"
    /// Cached so logoView does not call UIImage(named:) on every body evaluation.
    private static let hasLogoAsset: Bool = UIImage(named: Self.logoAssetName) != nil

    @State private var alertItem: ActiveAlert?
    @State private var showEmailOptionsDialog = false
    @State private var showBlogSafari = false
    @State private var blogURLToOpen: URL?
    @State private var showEmailCopiedConfirmation = false
    @State private var isServicesExpanded = false
    @State private var isSupportBorderBreathing = false
    @State private var pendingExternalURL: URL?

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

                // Our Services section
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                            isServicesExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Our Services")
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.titleTextColor)
                            Spacer()
                            HStack(spacing: 8) {
                                Text(isServicesExpanded ? "Show less" : "Show more")
                                    .font(AppTheme.calloutFont)
                                    .foregroundStyle(AppTheme.titleTextColor)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(AppTheme.titleTextColor)
                                    .rotationEffect(.degrees(isServicesExpanded ? 180 : 0))
                                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isServicesExpanded)
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Our Services")
                    .accessibilityValue(isServicesExpanded ? "Expanded" : "Collapsed")
                    .accessibilityHint("Double tap to expand or collapse")

                    ForEach(Array(visibleServices.enumerated()), id: \.element.id) { index, service in
                        serviceRow(service)
                            .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top)))
                        if index < visibleServices.count - 1 {
                            Divider()
                        }
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
                .padding(.horizontal, 20)
                .padding(.top, 12)

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
                        guard let url = URL(string: blogURLString),
                              let scheme = url.scheme?.lowercased(),
                              scheme == "http" || scheme == "https" else {
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

                    footerView
                        .padding(.top, 20)
                    }
                    .padding(EdgeInsets(top: headerHeight, leading: 16, bottom: 32, trailing: 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(AppTheme.background)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Button {
                            alertItem = .openWebsiteConfirm
                        } label: {
                            logoView(availableWidth: geo.size.width)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Conquest Solutions website")
                        .accessibilityHint("Opens csatlanta.com in Safari")
                        .padding(.top, topPadding)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .frame(height: headerHeight)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .bottom) {
                        LinearGradient(colors: [AppTheme.background, .clear], startPoint: .top, endPoint: .bottom)
                            .frame(height: 20)
                    }
                    .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)
                // Header allows hit testing so logo button can receive taps.
                .allowsHitTesting(true)
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
                case .invalidBlogURL:
                    return Alert(
                        title: Text("Blog Unavailable"),
                        message: Text("The blog link is misconfigured. Please try again later."),
                        dismissButton: .cancel(Text("OK")) { alertItem = nil }
                    )
                case .openWebsiteConfirm:
                    return Alert(
                        title: Text("Open Website?"),
                        message: Text("You're about to leave the app and open csatlanta.com in Safari."),
                        primaryButton: .default(Text("Open")) {
                            openMainSite()
                            alertItem = nil
                        },
                        secondaryButton: .cancel(Text("Cancel")) { alertItem = nil }
                    )
                case .openExternalLinkConfirm:
                    return Alert(
                        title: Text("Open Link?"),
                        message: Text("You're about to leave the app."),
                        primaryButton: .default(Text("Open")) {
                            if let url = pendingExternalURL { openURL(url) }
                            pendingExternalURL = nil
                            alertItem = nil
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            pendingExternalURL = nil
                            alertItem = nil
                        }
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

    /// Tappable service row: opens service URL via "Open Link?" confirmation when url is non-nil.
    private func serviceRow(_ service: ServiceItem) -> some View {
        Button {
            pendingExternalURL = service.url
            alertItem = .openExternalLinkConfirm
        } label: {
            ourServicesTile(title: service.title, symbol: service.symbol)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel("\(service.title), opens website")
        .accessibilityHint("Opens in your browser")
    }

    /// Footer social icon: asset image in circular background, opens URL in external browser.
    /// When useWhiteBackdrop is true, inner content is hard-masked to a circle to remove square artifacts.
    private func socialIconButton(
        imageName: String,
        urlString: String,
        iconSize: CGFloat = 36,
        innerPadding: CGFloat,
        accessibilityLabel: String,
        useWhiteBackdrop: Bool = false,
        innerMaskScale: CGFloat = 0.86
    ) -> some View {
        Button {
            guard let url = URL(string: urlString) else { return }
            pendingExternalURL = url
            alertItem = .openExternalLinkConfirm
        } label: {
            Circle()
                .fill(AppTheme.conquestRed.opacity(0.10))
                .frame(width: iconSize, height: iconSize)
                .overlay {
                    ZStack {
                        if useWhiteBackdrop {
                            Circle()
                                .fill(Color.white)
                                .frame(width: iconSize * innerMaskScale, height: iconSize * innerMaskScale)
                        }
                        Image(imageName)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .padding(innerPadding)
                            .frame(width: iconSize * innerMaskScale, height: iconSize * innerMaskScale)
                            .clipShape(Circle())
                    }
                    .frame(width: iconSize * innerMaskScale, height: iconSize * innerMaskScale)
                }
                .overlay {
                    Circle()
                        .strokeBorder(AppTheme.conquestRed.opacity(0.20), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Circle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Opens in Safari")
    }

    /// Footer tagline: subtle, centered, near bottom; social links below.
    private var footerView: some View {
        VStack(spacing: 12) {
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

            HStack(spacing: 16) {
                socialIconButton(
                    imageName: "SocialGoogleMaps",
                    urlString: mapsURLString,
                    iconSize: 36,
                    innerPadding: 6,
                    accessibilityLabel: "Open Google Maps",
                    useWhiteBackdrop: false
                )
                socialIconButton(
                    imageName: "SocialFacebook",
                    urlString: facebookURLString,
                    iconSize: 36,
                    innerPadding: 9,
                    accessibilityLabel: "Open Facebook",
                    useWhiteBackdrop: true,
                    innerMaskScale: 0.88
                )
                socialIconButton(
                    imageName: "SocialLinkedIn",
                    urlString: linkedInURLString,
                    iconSize: 36,
                    innerPadding: 8,
                    accessibilityLabel: "Open LinkedIn",
                    useWhiteBackdrop: true,
                    innerMaskScale: 0.86
                )
            }
        }
    }

    private func openMainSite() {
        guard let url = URL(string: mainSiteURLString) else { return }
        openURL(url)
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
