//
//  MockMicrosoftAuthService.swift
//  ConquestSupportApp
//
//  Mock Microsoft auth for testing the provider flow without real credentials.
//  Replace with real MSAL integration later.
//

import Foundation

/// Mock Microsoft auth that returns a realistic identity payload after a short delay.
final class MockMicrosoftAuthService: AuthProviding, @unchecked Sendable {
    var provider: AuthProvider { .microsoft }

    /// Set to true to simulate sign-in failure (e.g. for testing error UI).
    static var simulateFailure = false

    func signIn() async throws -> IdentityTokenPayload {
        try await Task.sleep(nanoseconds: 800_000_000)
        if Self.simulateFailure {
            throw NSError(domain: "MockMicrosoftAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Microsoft sign-in failed"])
        }
        return IdentityTokenPayload(
            sub: "microsoft-mock-oid-\(UUID().uuidString.prefix(8))",
            email: "mock.user@outlook.com",
            name: "Mock Microsoft User",
            emailVerified: true,
            idToken: "mock_microsoft_id_token_\(UUID().uuidString)"
        )
    }
}
