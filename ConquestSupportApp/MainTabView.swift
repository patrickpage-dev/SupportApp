//
//  MainTabView.swift
//  ConquestSupportApp
//
//  Logged-in shell: Home (Dashboard), Support, Account tabs.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case dashboard
    case support
    case account
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.dashboard)

            SupportView()
                .tabItem {
                    Label("Support", systemImage: "headset")
                }
                .tag(AppTab.support)

            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
            .tag(AppTab.account)
        }
        .onAppear { selectedTab = .dashboard }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SessionManager())
}
