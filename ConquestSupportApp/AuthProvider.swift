//
//  AuthProvider.swift
//  ConquestSupportApp
//
//  Supported SSO providers; used for routing and future SDK integration.
//

import Foundation

/// Supported identity providers. Add cases when adding new SSO options.
enum AuthProvider: String, CaseIterable, Sendable {
    case google
    case microsoft
}
