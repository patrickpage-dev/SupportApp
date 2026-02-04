//
//  AppTheme.swift
//  ConquestSupportApp
//
//  Centralized colors and typography for Conquest Solutions branding.
//

import SwiftUI

enum AppTheme {
    // MARK: - Colors (asset-based; no hard-coded hex in views)

    static let primary = Color("CSPrimary")
    static let secondary = Color("CSSecondary")
    static let background = Color("CSBackground")
    static let accent = Color("CSAccent")
    /// Conquest brand red (e.g. footer tagline, logo accent).
    static let conquestRed = Color("ConquestRed")

    /// Screen title text: black in light mode, white in dark (adaptive).
    static let titleTextColor = Color.primary
    /// Conquest brand red for primary actions; keep contrast with buttonForeground.
    static let buttonBackground = conquestRed
    /// Text/icons on primary button background. Conservative contrast for accessibility.
    static let buttonForeground = Color.white

    // MARK: - Typography (system San Francisco; .headline, .title2, .body, .callout)

    /// Screen title (e.g. "Conquest Solutions Support").
    static let titleFont = Font.title2.weight(.semibold)
    /// Section or card headline.
    static let headlineFont = Font.headline
    /// Body text.
    static let bodyFont = Font.body
    /// Secondary or caption text.
    static let calloutFont = Font.callout
    /// Primary action button label; slight weight emphasis.
    static let buttonFont = Font.headline.weight(.semibold)
}
