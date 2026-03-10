//
//  SessionManager.swift
//  ConquestSupportApp
//
//  Lightweight session manager for app-wide auth state (Phase 1 mock).
//

import SwiftUI
import Combine

private enum SessionKeys {
    static let email = "sessionEmail"
    static let displayName = "sessionDisplayName"
    static let organizationName = "sessionOrganizationName"
}

final class SessionManager: ObservableObject {
    @Published var isLoadingSession = true
    @Published var isSigningIn = false
    @Published var isAuthenticated = false
    @Published var currentUserDisplayName: String = ""
    @Published var currentOrganizationName: String = ""
    /// Persisted email for display (e.g. Account screen). Not used for auth in Phase 1.
    @Published var currentUserEmail: String = ""

    private let defaults = UserDefaults.standard

    init() {
        restoreSession()
    }

    /// Simulates restoring a saved session on launch.
    private func restoreSession() {
        isLoadingSession = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            let email = defaults.string(forKey: SessionKeys.email)
            if let email = email, !email.isEmpty {
                currentUserEmail = email
                currentUserDisplayName = defaults.string(forKey: SessionKeys.displayName) ?? displayNameFromEmail(email)
                currentOrganizationName = defaults.string(forKey: SessionKeys.organizationName) ?? "Conquest Solutions"
                isAuthenticated = true
            } else {
                isAuthenticated = false
                currentUserDisplayName = ""
                currentOrganizationName = ""
                currentUserEmail = ""
            }
            isLoadingSession = false
        }
    }

    /// Mock sign-in: call after validating (non-empty email, password count >= 4).
    func signIn(email: String, password: String) async {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, password.count >= 4 else { return }

        await MainActor.run { isSigningIn = true }
        try? await Task.sleep(nanoseconds: 600_000_000)
        await MainActor.run {
            currentUserEmail = trimmed
            currentUserDisplayName = displayNameFromEmail(trimmed)
            currentOrganizationName = "Conquest Solutions"
            defaults.set(trimmed, forKey: SessionKeys.email)
            defaults.set(currentUserDisplayName, forKey: SessionKeys.displayName)
            defaults.set(currentOrganizationName, forKey: SessionKeys.organizationName)
            isAuthenticated = true
            isSigningIn = false
        }
    }

    func signOut() {
        defaults.removeObject(forKey: SessionKeys.email)
        defaults.removeObject(forKey: SessionKeys.displayName)
        defaults.removeObject(forKey: SessionKeys.organizationName)
        isAuthenticated = false
        currentUserDisplayName = ""
        currentOrganizationName = ""
        currentUserEmail = ""
    }

    private func displayNameFromEmail(_ email: String) -> String {
        if let prefix = email.split(separator: "@").first, !prefix.isEmpty {
            return String(prefix).capitalized
        }
        return "User"
    }
}
