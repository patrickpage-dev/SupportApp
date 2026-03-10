//
//  MockBackendAuthService.swift
//  ConquestSupportApp
//
//  Mock backend auth: simulates verifying identity, resolving user/org, issuing session.
//  Replace with real backend client when API is available.
//

import Foundation

/// Mock backend auth for testing. Simulates identity verification, user/org resolution, and session issuance.
final class MockBackendAuthService: BackendAuthServicing, @unchecked Sendable {
    /// Set to true to simulate exchange failure (e.g. invalid token).
    static var simulateExchangeFailure = false

    func exchangeIdentity(provider: AuthProvider, token: String) async throws -> AppSession {
        try await Task.sleep(nanoseconds: 400_000_000)
        if Self.simulateExchangeFailure {
            throw NSError(domain: "MockBackendAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock backend exchange failed"])
        }
        let (email, displayName): (String, String) = switch provider {
        case .google: ("mock.user@gmail.com", "Mock Google User")
        case .microsoft: ("mock.user@outlook.com", "Mock Microsoft User")
        }
        let userId = "\(provider.rawValue)-mock-contact-\(UUID().uuidString.prefix(8))"
        let orgId = "mock-org-\(UUID().uuidString.prefix(8))"
        let sessionToken = "backend_mock_session_\(UUID().uuidString)"
        let user = AuthenticatedUser(id: userId, email: email, displayName: displayName)
        let org = AuthenticatedOrganization(id: orgId, name: "Conquest Solutions")
        return AppSession(token: sessionToken, user: user, organization: org, expiresAt: nil)
    }

    func fetchCurrentSession(token: String?) async throws -> AppSession? {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let token = token, !token.isEmpty else { return nil }
        if token.hasPrefix("restored_placeholder") || token.hasPrefix("backend_mock_session_") {
            let email = "restored@conquest.local"
            let user = AuthenticatedUser(id: nil, email: email, displayName: "Restored User")
            let org = AuthenticatedOrganization(id: nil, name: "Conquest Solutions")
            return AppSession(token: token, user: user, organization: org, expiresAt: nil)
        }
        return nil
    }

    func signOut() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }
}
