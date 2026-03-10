//
//  MockSupportService.swift
//  ConquestSupportApp
//
//  Mock support service for scaffolding. TODO: Replace with real client when backend/Accelo GET /issues, POST /issues are live.
//

import Foundation

/// Mock implementation of SupportServicing. Returns placeholder issues; no network calls.
final class MockSupportService: SupportServicing, @unchecked Sendable {
    func fetchIssues() async throws -> [SupportIssue] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return [
            SupportIssue(
                id: "mock-issue-1",
                subject: "Placeholder issue",
                status: .open,
                priority: .normal,
                createdAt: Date().addingTimeInterval(-86400)
            )
        ]
    }

    func createIssue(subject: String, priority: SupportIssuePriority) async throws -> SupportIssue {
        try await Task.sleep(nanoseconds: 400_000_000)
        return SupportIssue(
            id: "mock-issue-\(UUID().uuidString.prefix(8))",
            subject: subject,
            status: .open,
            priority: priority,
            createdAt: Date()
        )
    }
}
