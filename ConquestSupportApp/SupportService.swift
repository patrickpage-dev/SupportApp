//
//  SupportService.swift
//  ConquestSupportApp
//
//  Protocol for support/issues operations. TODO: Implement with backend/Accelo API (GET /issues, POST /issues).
//

import Foundation

/// Service for fetching and creating support issues. TODO: Real implementation calls backend; backend resolves from Accelo.
protocol SupportServicing: Sendable {
    /// Fetches issues for the current session. TODO: GET /issues with session token; backend returns Accelo tickets.
    func fetchIssues() async throws -> [SupportIssue]

    /// Creates a new support issue. TODO: POST /issues with session token; backend creates in Accelo.
    func createIssue(subject: String, priority: SupportIssuePriority) async throws -> SupportIssue
}
