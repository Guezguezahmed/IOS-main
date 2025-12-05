//
//  LeaderboardModels.swift
//  IosDam
//
//  Leaderboard and rankings data models
//

import Foundation

// MARK: - Leaderboard Entry

struct LeaderboardEntry: Codable, Identifiable {
    let id: String
    let team_id: String
    let team_name: String
    let team_logo: String?
    let position: Int
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let goals_for: Int
    let goals_against: Int
    let goal_difference: Int
    let points: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case team_id
        case team_name
        case team_logo
        case position
        case played
        case won
        case drawn
        case lost
        case goals_for
        case goals_against
        case goal_difference
        case points
    }
}

// MARK: - Tournament Standings

struct TournamentStandings: Codable {
    let tournament_id: String
    let tournament_name: String
    let entries: [LeaderboardEntry]
    let last_updated: String?
    
    enum CodingKeys: String, CodingKey {
        case tournament_id
        case tournament_name
        case entries
        case last_updated
    }
}

// MARK: - Player Statistics

struct PlayerStats: Codable, Identifiable {
    let id: String
    let player_id: String
    let player_name: String
    let team_id: String
    let team_name: String
    let matches_played: Int
    let goals: Int
    let assists: Int
    let yellow_cards: Int
    let red_cards: Int
    let minutes_played: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case player_id
        case player_name
        case team_id
        case team_name
        case matches_played
        case goals
        case assists
        case yellow_cards
        case red_cards
        case minutes_played
    }
}

// MARK: - API Response Wrappers

struct TournamentStandingsResponse: Codable {
    let standings: TournamentStandings
}

struct LeaderboardListResponse: Codable {
    let leaderboard: [LeaderboardEntry]
}
