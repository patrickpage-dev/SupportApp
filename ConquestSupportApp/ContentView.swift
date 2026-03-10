//
//  ContentView.swift
//  ConquestSupportApp
//
//  Root router: loading session → MainTabView (logged-in) or LoginView (signed out).
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        Group {
            if sessionManager.isLoadingSession {
                loadingView
            } else if sessionManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: sessionManager.isAuthenticated)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading…")
                .font(AppTheme.calloutFont)
                .foregroundStyle(AppTheme.titleTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionManager())
}
