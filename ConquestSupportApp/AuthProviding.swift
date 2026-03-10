//
//  AuthProviding.swift
//  ConquestSupportApp
//
//  Protocol abstractions for provider auth. Implement with real SDKs (Google Sign-In, MSAL) later.
//

import Foundation

/// Obtains identity tokens from a provider. TODO: Implement with Google Sign-In SDK / MSAL; throw on user cancel or error.
protocol AuthProviding: Sendable {
    var provider: AuthProvider { get }
    /// Presents provider UI and returns ID token payload. TODO: Replace with real SDK sign-in flow.
    func signIn() async throws -> IdentityTokenPayload
}

/// Exchanges a provider token for an app session. TODO: Implement with real HTTP client and backend endpoint.
protocol AuthExchanging: Sendable {
    func exchange(request: AuthExchangeRequest) async throws -> AuthExchangeResponse
}
