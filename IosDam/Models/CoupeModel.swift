//
// CoupeModel.swift
// IosDam
//

import Foundation

// MARK: - Enums

// Unchanged
enum CoupeCategorie: String, CaseIterable, Codable {
    case SENIOR = "Senior"
    case JUNIOR = "Junior"
    case YOUTH = "Youth"
    case KIDS = "Kids"
}

// 🛑 FIX: Added 'CaseIterable' here so we can loop through it in the Picker
enum CoupeType: String, Codable, CaseIterable {
    case TOURNAMENT = "Tournament"
    case LEAGUE = "League"
}

// MARK: - Main Model (unchanged)
struct CoupeModel: Codable {
    let _id: String
    let nom: String
    let participants: [String]
    let date_debut: Date
    let date_fin: Date
    let tournamentName: String
    let stadium: String
    let maxParticipants: Int
    let entryFee: Int?
    let prizePool: Int?
    let referee: [String]
    let categorie: CoupeCategorie
    let type: CoupeType
    let ownerId: String
    let createdAt: Date
    let updatedAt: Date
}
