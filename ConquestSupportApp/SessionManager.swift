//
//  SessionManager.swift
//  ConquestSupportApp
//
//  Central app-wide auth state with provider-based flow (placeholder logic).
//

import SwiftUI
import Combine

/// Auth state for routing and UI; single source of truth.
enum AuthState: Equatable {
    case restoringSession
    case signedOut
    case authenticating
    case authenticated
    case failed(String)
}

private enum SessionKeys {
    static let email = "sessionEmail"
    static let displayName = "sessionDisplayName"
    static let organizationName = "sessionOrganizationName"
    static let sessionToken = "sessionToken"
}

final class SessionManager: ObservableObject {
    @Published var authState: AuthState = .restoringSession
    @Published var currentUserDisplayName: String = ""
    @Published var currentOrganizationName: String = ""
    @Published var currentUserEmail: String = ""

    private let defaults = UserDefaults.standard

    /// Mock auth services for testing; replace with real SDK-backed implementations later.
    private let googleAuthService: AuthProviding = MockGoogleAuthService()
    private let microsoftAuthService: AuthProviding = MockMicrosoftAuthService()
    /// Backend auth exchange; replace with real client when API is available.
    private let backendAuthService: BackendAuthServicing = MockBackendAuthService()

    // MARK: - Derived for views (single source of truth: authState)

    var isLoadingSession: Bool {
        if case .restoringSession = authState { return true }
        return false
    }

    var isSigningIn: Bool {
        if case .authenticating = authState { return true }
        return false
    }

    var isAuthenticated: Bool {
        if case .authenticated = authState { return true }
        return false
    }

    var lastAuthError: String? {
        if case .failed(let message) = authState { return message }
        return nil
    }

    init() {
        restoreSession()
    }

    /// Restores a saved session on launch; keeps routing intact.
    private func restoreSession() {
        authState = .restoringSession
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            let email = defaults.string(forKey: SessionKeys.email)
            if let email = email, !email.isEmpty {
                currentUserEmail = email
                currentUserDisplayName = defaults.string(forKey: SessionKeys.displayName) ?? displayNameFromEmail(email)
                currentOrganizationName = defaults.string(forKey: SessionKeys.organizationName) ?? "Conquest Solutions"
                if defaults.string(forKey: SessionKeys.sessionToken) == nil {
                    defaults.set("restored_placeholder", forKey: SessionKeys.sessionToken)
                }
                authState = .authenticated
            } else {
                currentUserDisplayName = ""
                currentOrganizationName = ""
                currentUserEmail = ""
                authState = .signedOut
            }
        }
    }

    func signOut() {
        Task { try? await backendAuthService.signOut() }
        defaults.removeObject(forKey: SessionKeys.email)
        defaults.removeObject(forKey: SessionKeys.displayName)
        defaults.removeObject(forKey: SessionKeys.organizationName)
        defaults.removeObject(forKey: SessionKeys.sessionToken)
        currentUserDisplayName = ""
        currentOrganizationName = ""
        currentUserEmail = ""
        authState = .signedOut
    }

    /// Google SSO via mock auth service. Replace with real AuthProviding + AuthExchanging when backend is ready.
    func signInWithGoogle() async {
        await signInWithProvider(googleAuthService)
    }

    /// Microsoft SSO via mock auth service. Replace with real AuthProviding + AuthExchanging when backend is ready.
    func signInWithMicrosoft() async {
        await signInWithProvider(microsoftAuthService)
    }

    private func signInWithProvider(_ authService: AuthProviding) async {
        await MainActor.run { authState = .authenticating }
        do {
            let payload = try await authService.signIn()
            let token = payload.idToken ?? ""
            let session = try await backendAuthService.exchangeIdentity(provider: authService.provider, token: token)
            await MainActor.run {
                applySession(session)
                authState = .authenticated
            }
        } catch {
            await MainActor.run {
                authState = .failed(error.localizedDescription)
            }
        }
    }

    /// Persists session for restore and future backend use.
    private func applySession(_ session: AppSession) {
        currentUserEmail = session.user.email
        currentUserDisplayName = session.user.displayName
        currentOrganizationName = session.organization.name
        defaults.set(session.user.email, forKey: SessionKeys.email)
        defaults.set(session.user.displayName, forKey: SessionKeys.displayName)
        defaults.set(session.organization.name, forKey: SessionKeys.organizationName)
        defaults.set(session.token, forKey: SessionKeys.sessionToken)
    }

    private func displayNameFromEmail(_ email: String) -> String {
        if let prefix = email.split(separator: "@").first, !prefix.isEmpty {
            return String(prefix).capitalized
        }
        return "User"
    }
}
