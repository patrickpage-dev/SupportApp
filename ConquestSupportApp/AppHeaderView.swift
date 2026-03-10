//
//  AppHeaderView.swift
//  ConquestSupportApp
//
//  Reusable Conquest logo header for Home, Support, and Account tabs.
//

import SwiftUI
import UIKit

struct AppHeaderView: View {
    @Environment(\.openURL) private var openURL
    @State private var showOpenWebsiteConfirm = false

    /// Fixed height for the header; use for scroll content top padding.
    static let height: CGFloat = 160

    private static let topPadding: CGFloat = 4
    private static let logoMaxHeight: CGFloat = 155
    private static let logoAssetName = "ConquestLogo"
    private static let mainSiteURLString = "https://csatlanta.com/"
    private static var hasLogoAsset: Bool { UIImage(named: logoAssetName) != nil }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Button {
                    showOpenWebsiteConfirm = true
                } label: {
                    logoContent(availableWidth: geo.size.width)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Conquest Solutions website")
                .accessibilityHint("Opens csatlanta.com in Safari")
                .padding(.top, Self.topPadding)
                .frame(maxWidth: .infinity, alignment: .top)
                Spacer(minLength: 0)
            }
            .frame(height: Self.height)
            .frame(maxWidth: .infinity)
            .background(AppTheme.background)
            .overlay(alignment: .bottom) {
                LinearGradient(colors: [AppTheme.background, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 20)
            }
            .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .frame(height: Self.height)
        .alert("Open Website?", isPresented: $showOpenWebsiteConfirm) {
            Button("Cancel", role: .cancel) { showOpenWebsiteConfirm = false }
            Button("Open") {
                if let url = URL(string: Self.mainSiteURLString) { openURL(url) }
                showOpenWebsiteConfirm = false
            }
        } message: {
            Text("You're about to leave the app and open csatlanta.com in Safari.")
        }
    }

    private func logoContent(availableWidth: CGFloat) -> some View {
        let logoWidth = max(0, availableWidth - 64)
        return Group {
            if Self.hasLogoAsset {
                Image(Self.logoAssetName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: logoWidth, maxHeight: Self.logoMaxHeight)
                    .accessibilityLabel("Conquest Solutions logo")
            } else {
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
}

#Preview {
    VStack(spacing: 0) {
        AppHeaderView()
        Spacer()
    }
    .background(AppTheme.background)
}
