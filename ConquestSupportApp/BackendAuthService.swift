//
//  BackendAuthService.swift
//  ConquestSupportApp
//
//  Protocol for backend auth exchange: verify identity, resolve user/org, issue session.
//  Implement with real HTTP client and backend API later.
//

import Foundation

/// Backend-facing auth: exchange provider tokens for app sessions, validate session, sign out.
/// Real implementation will verify Google/Microsoft identity and resolve Accelo contacts/organizations.
protocol BackendAuthServicing: Sendable {
    /// Exchanges a provider identity token for an app session (verify identity, resolve user & org, issue token).
    func exchangeIdentity(provider: AuthProvider, token: String) async throws -> AppSession

    /// Fetches current session for a stored token (e.g. on restore). Returns nil if token invalid or expired.
    func fetchCurrentSession(token: String?) async throws -> AppSession?

    /// Invalidates the session on the backend. Call before clearing local session.
    func signOut() async throws
}
