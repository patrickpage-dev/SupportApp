//
//  MockGoogleAuthService.swift
//  ConquestSupportApp
//
//  Mock Google auth for testing the provider flow without real credentials.
//  Replace with real Google Sign-In SDK integration later.
//

import Foundation

/// Mock Google auth that returns a realistic identity payload after a short delay.
final class MockGoogleAuthService: AuthProviding, @unchecked Sendable {
    var provider: AuthProvider { .google }

    /// Set to true to simulate sign-in failure (e.g. for testing error UI).
    static var simulateFailure = false

    func signIn() async throws -> IdentityTokenPayload {
        try await Task.sleep(nanoseconds: 800_000_000)
        if Self.simulateFailure {
            throw NSError(domain: "MockGoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Google sign-in failed"])
        }
        return IdentityTokenPayload(
            sub: "google-mock-sub-\(UUID().uuidString.prefix(8))",
            email: "mock.user@gmail.com",
            name: "Mock Google User",
            emailVerified: true,
            idToken: "mock_google_id_token_\(UUID().uuidString)"
        )
    }
}
