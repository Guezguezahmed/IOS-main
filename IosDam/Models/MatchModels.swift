//
//  MatchModels.swift
//  IosDam
//
//  Match data models for detailed match information
//

import Foundation

// MARK: - Match Status Enum

enum MatchStatus: String, Codable {
    case SCHEDULED = "SCHEDULED"
    case IN_PROGRESS = "IN_PROGRESS"
    case COMPLETED = "COMPLETED"
    case CANCELLED = "CANCELLED"
}

// MARK: - Match Event Type

enum MatchEventType: String, Codable {
    case GOAL = "GOAL"
    case YELLOW_CARD = "YELLOW_CARD"
    case RED_CARD = "RED_CARD"
    case SUBSTITUTION = "SUBSTITUTION"
    case PENALTY = "PENALTY"
}

// MARK: - Match Event

struct MatchEvent: Codable, Identifiable {
    let id: String
    let match_id: String
    let event_type: MatchEventType
    let team_id: String
    let player_id: String?
    let minute: Int
    let description: String?
    let created_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case match_id
        case event_type
        case team_id
        case player_id
        case minute
        case description
        case created_at
    }
}

// MARK: - Match Statistics

struct MatchStatistics: Codable {
    let possession_team1: Int? // Percentage
    let possession_team2: Int?
    let shots_team1: Int?
    let shots_team2: Int?
    let shots_on_target_team1: Int?
    let shots_on_target_team2: Int?
    let corners_team1: Int?
    let corners_team2: Int?
    let fouls_team1: Int?
    let fouls_team2: Int?
    let yellow_cards_team1: Int?
    let yellow_cards_team2: Int?
    let red_cards_team1: Int?
    let red_cards_team2: Int?
}

// MARK: - Team Info (lightweight for match details)

struct MatchTeamInfo: Codable, Identifiable {
    let _id: String
    let nom: String
    let logo: String?
    
    var id: String { _id }
}

// MARK: - Referee Info

struct MatchRefereeInfo: Codable, Identifiable {
    let _id: String
    let nom: String
    let prenom: String
    
    var id: String { _id }
    var fullName: String { "\(prenom) \(nom)" }
}

// MARK: - Stadium Info

struct MatchStadiumInfo: Codable, Identifiable {
    let _id: String
    let nom: String
    let adresse: String?
    
    var id: String { _id }
}

// MARK: - Detailed Match Model

struct MatchDetail: Codable, Identifiable {
    let id: String
    let id_equipe1: MatchTeamInfo?
    let id_equipe2: MatchTeamInfo?
    let id_terrain: MatchStadiumInfo?
    let id_arbitre: MatchRefereeInfo?
    let date: Date?
    let score_eq1: Int
    let score_eq2: Int
    let statut: MatchStatus
    let round: Int
    let statistics: MatchStatistics?
    let events: [MatchEvent]?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case id_equipe1
        case id_equipe2
        case id_terrain
        case id_arbitre
        case date
        case score_eq1
        case score_eq2
        case statut
        case round
        case statistics
        case events
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        id_equipe1 = try? container.decode(MatchTeamInfo.self, forKey: .id_equipe1)
        id_equipe2 = try? container.decode(MatchTeamInfo.self, forKey: .id_equipe2)
        id_terrain = try? container.decode(MatchStadiumInfo.self, forKey: .id_terrain)
        id_arbitre = try? container.decode(MatchRefereeInfo.self, forKey: .id_arbitre)
        
        // Handle date parsing
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let formatter = ISO8601DateFormatter()
            date = formatter.date(from: dateString)
        } else {
            date = try? container.decode(Date.self, forKey: .date)
        }
        
        score_eq1 = (try? container.decode(Int.self, forKey: .score_eq1)) ?? 0
        score_eq2 = (try? container.decode(Int.self, forKey: .score_eq2)) ?? 0
        
        if let statusString = try? container.decode(String.self, forKey: .statut) {
            statut = MatchStatus(rawValue: statusString) ?? .SCHEDULED
        } else {
            statut = .SCHEDULED
        }
        
        round = try container.decode(Int.self, forKey: .round)
        statistics = try? container.decode(MatchStatistics.self, forKey: .statistics)
        events = try? container.decode([MatchEvent].self, forKey: .events)
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        updatedAt = try? container.decode(String.self, forKey: .updatedAt)
    }
}

// MARK: - Update Match Score Request

struct UpdateMatchScoreRequest: Codable {
    let score_eq1: Int
    let score_eq2: Int
    let statut: MatchStatus?
}

// MARK: - API Response Wrappers

struct MatchDetailResponse: Codable {
    let match: MatchDetail
}

struct MatchListResponse: Codable {
    let matches: [MatchDetail]
}
