//
//  ForumModels.swift
//  IosDam
//
//  Tournament Forum/Discussion models
//

import Foundation

// MARK: - Forum Message

struct ForumMessage: Codable, Identifiable {
    let id: String
    let tournament_id: String
    let user_id: String
    let user_name: String
    let content: String
    let created_at: String
    let updated_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case tournament_id
        case user_id
        case user_name
        case content
        case created_at
        case updated_at
    }
}

// MARK: - Create Message Request

struct CreateMessageRequest: Codable {
    let tournament_id: String
    let content: String
}

// MARK: - API Response Wrappers

struct ForumMessageResponse: Codable {
    let message: ForumMessage
}

struct ForumMessagesListResponse: Codable {
    let messages: [ForumMessage]
}
