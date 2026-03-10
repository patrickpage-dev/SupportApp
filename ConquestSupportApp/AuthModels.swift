//
//  AuthModels.swift
//  ConquestSupportApp
//
//  Auth-related DTOs for tokens, exchange, and session. Mock-friendly; no real network types.
//

import Foundation

/// Payload from an ID token (e.g. from Google/Microsoft). TODO: Replace with real JWT decoding when SDK is integrated.
struct IdentityTokenPayload: Sendable {
    var sub: String?
    var email: String?
    var name: String?
    var emailVerified: Bool?
    /// Raw ID token string for exchange; mocks provide a fake value.
    var idToken: String?
}

/// Request to exchange a provider token for an app session. TODO: Wire to real backend when API exists.
struct AuthExchangeRequest: Sendable {
    var provider: AuthProvider
    var idToken: String?
    var accessToken: String?
}

/// Response from the auth exchange endpoint. TODO: Map from real API response.
struct AuthExchangeResponse: Sendable {
    var session: AppSession
}

/// User identity returned after auth. TODO: Align with backend user model.
struct AuthenticatedUser: Sendable {
    var id: String?
    var email: String
    var displayName: String
}

/// Organization context for the authenticated user. TODO: Align with backend org model.
struct AuthenticatedOrganization: Sendable {
    var id: String?
    var name: String
}

/// In-app session after successful auth. Persisted for restore; TODO: refresh logic when backend is live.
struct AppSession: Sendable {
    var token: String
    var user: AuthenticatedUser
    var organization: AuthenticatedOrganization
    var expiresAt: Date?
}
