//
//  SupportIssue.swift
//  ConquestSupportApp
//
//  Placeholder model for support issues/tickets. TODO: Align with Accelo issue/ticket API when integrating.
//

import Foundation

/// Placeholder status for a support issue. TODO: Map from Accelo status values.
enum SupportIssueStatus: String, Sendable, CaseIterable {
    case open
    case inProgress
    case resolved
    case closed
}

/// Placeholder priority for a support issue. TODO: Map from Accelo priority values.
enum SupportIssuePriority: String, Sendable, CaseIterable {
    case low
    case normal
    case high
    case urgent
}

/// Support issue/ticket placeholder. TODO: Replace with Accelo-backed model (IDs, custom fields, etc.).
struct SupportIssue: Sendable, Identifiable {
    var id: String
    var subject: String
    var status: SupportIssueStatus
    var priority: SupportIssuePriority
    var createdAt: Date
}
