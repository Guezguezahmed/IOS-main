//
// EquipeModels.swift
// IosDam
//
// Data models for Team (Equipe) management matching Android backend schema

import Foundation

// MARK: - Enums

enum Categorie: String, Codable, CaseIterable {
    case KIDS = "KIDS"
    case YOUTH = "YOUTH"
    case JUNIOR = "JUNIOR"
    case SENIOR = "SENIOR"
}

// MARK: - Tournament Placement

struct TournamentPlacement: Codable {
    let tournament_id: String
    let tournament_name: String
    let placement: Int // 1 = winner, 2 = runner-up, etc.
    let season: String // e.g., "2024-2025"
    let date: String
}

// MARK: - Recent Match

struct RecentMatch: Codable {
    let result: String // "W", "D", "L"
    let date: String
}

// MARK: - Team Statistics

struct StatsEquipe: Codable {
    // Match Results
    let total_matches: Int
    let wins: Int
    let draws: Int
    let losses: Int
    
    // Calculated fields
    let win_rate: Double
    let goal_difference: Int
    let avg_goals_per_match: Double
    
    // Goals
    let goals_for: Int
    let goals_against: Int
    
    // Streaks
    let current_win_streak: Int
    let best_win_streak: Int
    let current_loss_streak: Int
    let best_loss_streak: Int
    
    // Trophies
    let trophies_won: Int
    let runners_up: Int
    let third_place: Int
    
    // Discipline
    let total_yellow_cards: Int
    let total_red_cards: Int
    
    // Home/Away performance
    let home_wins: Int
    let away_wins: Int
    let clean_sheets: Int
    
    // History
    let tournament_history: [TournamentPlacement]
    let last_five_matches: [RecentMatch]
    
    // Form
    let form_rating: Double // 0-10 scale
    let momentum_indicator: String // "Rising", "Falling", "Stable"
    
    // Default initializer with default values
    init(total_matches: Int = 0, wins: Int = 0, draws: Int = 0, losses: Int = 0,
         win_rate: Double = 0.0, goal_difference: Int = 0, avg_goals_per_match: Double = 0.0,
         goals_for: Int = 0, goals_against: Int = 0,
         current_win_streak: Int = 0, best_win_streak: Int = 0,
         current_loss_streak: Int = 0, best_loss_streak: Int = 0,
         trophies_won: Int = 0, runners_up: Int = 0, third_place: Int = 0,
         total_yellow_cards: Int = 0, total_red_cards: Int = 0,
         home_wins: Int = 0, away_wins: Int = 0, clean_sheets: Int = 0,
         tournament_history: [TournamentPlacement] = [], last_five_matches: [RecentMatch] = [],
         form_rating: Double = 5.0, momentum_indicator: String = "Stable") {
        self.total_matches = total_matches
        self.wins = wins
        self.draws = draws
        self.losses = losses
        self.win_rate = win_rate
        self.goal_difference = goal_difference
        self.avg_goals_per_match = avg_goals_per_match
        self.goals_for = goals_for
        self.goals_against = goals_against
        self.current_win_streak = current_win_streak
        self.best_win_streak = best_win_streak
        self.current_loss_streak = current_loss_streak
        self.best_loss_streak = best_loss_streak
        self.trophies_won = trophies_won
        self.runners_up = runners_up
        self.third_place = third_place
        self.total_yellow_cards = total_yellow_cards
        self.total_red_cards = total_red_cards
        self.home_wins = home_wins
        self.away_wins = away_wins
        self.clean_sheets = clean_sheets
        self.tournament_history = tournament_history
        self.last_five_matches = last_five_matches
        self.form_rating = form_rating
        self.momentum_indicator = momentum_indicator
    }
}

// MARK: - Main Equipe Model

struct Equipe: Codable, Identifiable {
    let _id: String
    let nom: String
    let logo: String?
    let id_academie: String
    let categorie: Categorie
    let is_active: Bool
    let members: [String] // IDs only
    let starters: [String] // IDs only
    let substitutes: [String] // IDs only
    let stats: StatsEquipe?
    
    var id: String { _id }
    
    // Default values for optional fields
    init(_id: String, nom: String, logo: String? = nil, id_academie: String,
         categorie: Categorie, is_active: Bool = true,
         members: [String] = [], starters: [String] = [], substitutes: [String] = [],
         stats: StatsEquipe? = nil) {
        self._id = _id
        self.nom = nom
        self.logo = logo
        self.id_academie = id_academie
        self.categorie = categorie
        self.is_active = is_active
        self.members = members
        self.starters = starters
        self.substitutes = substitutes
        self.stats = stats
    }
}

// MARK: - Player Info (for populated responses)

struct PlayerInfo: Codable, Identifiable {
    let _id: String
    let nom: String
    let prenom: String
    
    var id: String { _id }
    var fullName: String { "\(prenom) \(nom)" }
}

// MARK: - Populated Equipe Model

struct PopulatedEquipe: Codable, Identifiable {
    let _id: String
    let nom: String
    let logo: String?
    let id_academie: String
    let categorie: Categorie
    let is_active: Bool
    let members: [PlayerInfo]
    let starters: [PlayerInfo]
    let substitutes: [PlayerInfo]
    let stats: StatsEquipe?
    
    var id: String { _id }
}

// MARK: - Request DTOs

struct CreateEquipeRequest: Codable {
    let nom: String
    let id_academie: String
    let categorie: Categorie
    let logo: String?
    let description: String?
    let is_active: Bool
    let members: [String]
    let starters: [String]
    let substitutes: [String]
    
    init(nom: String, id_academie: String, categorie: Categorie,
         logo: String? = nil, description: String? = nil, is_active: Bool = true,
         members: [String] = [], starters: [String] = [], substitutes: [String] = []) {
        self.nom = nom
        self.id_academie = id_academie
        self.categorie = categorie
        self.logo = logo
        self.description = description
        self.is_active = is_active
        self.members = members
        self.starters = starters
        self.substitutes = substitutes
    }
}

struct UpdateEquipeRequest: Codable {
    let nom: String?
    let categorie: Categorie?
    let is_active: Bool?
    let starters: [String]?
    let substitutes: [String]?
}

struct UpdateTeamMembersRequest: Codable {
    let playerId: String
}

// MARK: - API Response Wrapper

struct EquipeResponse: Codable {
    let equipe: Equipe
}

struct PopulatedEquipeResponse: Codable {
    let equipe: PopulatedEquipe
}

struct EquipeListResponse: Codable {
    let equipes: [Equipe]
}
