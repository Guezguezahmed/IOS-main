//
// TournamentModels.swift
// IosDam
//
// Tournament/Event data models

import Foundation

// MARK: - Organizer

struct Organizer: Codable, Identifiable {
    let id: String
    let nom: String?
    let prenom: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nom
        case prenom
    }
}

// MARK: - Match

struct Match: Codable, Identifiable {
    let id: String
    let idEquipe1: String?
    let idEquipe2: String?
    let idTerrain: String?
    let idArbitre: String?
    let date: Date?
    let scoreEq1: Int?
    let scoreEq2: Int?
    let statut: String?
    let round: Int
    let nextMatch: String?
    let positionInNextMatch: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case idEquipe1 = "id_equipe1"
        case idEquipe2 = "id_equipe2"
        case idTerrain = "id_terrain"
        case idArbitre = "id_arbitre"
        case date
        case scoreEq1 = "score_eq1"
        case scoreEq2 = "score_eq2"
        case statut
        case round
        case nextMatch
        case positionInNextMatch
    }
}

// MARK: - Tournament/Coupe

struct Tournament: Codable, Identifiable {
    let id: String
    let nom: String
    let tournamentName: String
    let participants: [ParticipantID]
    let dateDebut: Date
    let dateFin: Date
    let stadium: String
    let date: Date
    let time: String
    let maxParticipants: Int
    let entryFee: Int?
    let prizePool: Int?
    let referee: [String]
    let categorie: String
    let type: String
    let idOrganisateur: Organizer?
    let matches: [Match]?
    let isBracketGenerated: Bool
    let currentRound: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nom
        case tournamentName
        case participants
        case dateDebut = "date_debut"
        case dateFin = "date_fin"
        case stadium
        case date
        case time
        case maxParticipants
        case entryFee
        case prizePool
        case referee
        case categorie
        case type
        case idOrganisateur = "id_organisateur"
        case matches
        case isBracketGenerated
        case currentRound
    }
    
    // Custom initializer to provide defaults for optional fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        nom = try container.decode(String.self, forKey: .nom)
        tournamentName = try container.decode(String.self, forKey: .tournamentName)
        participants = try container.decode([ParticipantID].self, forKey: .participants)
        
        // Decode dates - handle both ISO8601 strings and Date objects
        let dateFormatter = ISO8601DateFormatter()
        
        if let dateDebutString = try? container.decode(String.self, forKey: .dateDebut),
           let parsedDate = dateFormatter.date(from: dateDebutString) {
            dateDebut = parsedDate
        } else {
            dateDebut = try container.decode(Date.self, forKey: .dateDebut)
        }
        
        if let dateFinString = try? container.decode(String.self, forKey: .dateFin),
           let parsedDate = dateFormatter.date(from: dateFinString) {
            dateFin = parsedDate
        } else {
            dateFin = try container.decode(Date.self, forKey: .dateFin)
        }
        
        if let dateString = try? container.decode(String.self, forKey: .date),
           let parsedDate = dateFormatter.date(from: dateString) {
            date = parsedDate
        } else {
            date = try container.decode(Date.self, forKey: .date)
        }
        
        stadium = try container.decode(String.self, forKey: .stadium)
        time = try container.decode(String.self, forKey: .time)
        maxParticipants = try container.decode(Int.self, forKey: .maxParticipants)
        entryFee = try? container.decode(Int.self, forKey: .entryFee)
        prizePool = try? container.decode(Int.self, forKey: .prizePool)
        referee = (try? container.decode([String].self, forKey: .referee)) ?? []
        categorie = try container.decode(String.self, forKey: .categorie)
        type = try container.decode(String.self, forKey: .type)
        idOrganisateur = try? container.decode(Organizer.self, forKey: .idOrganisateur)
        matches = try? container.decode([Match].self, forKey: .matches)
        isBracketGenerated = (try? container.decode(Bool.self, forKey: .isBracketGenerated)) ?? false
        currentRound = try? container.decode(Int.self, forKey: .currentRound)
    }
}

// MARK: - Participant ID (can be string or object with $oid)

enum ParticipantID: Codable {
    case string(String)
    case object([String: String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let obj = try? container.decode([String: String].self) {
            self = .object(obj)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid participant ID format")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str):
            try container.encode(str)
        case .object(let obj):
            try container.encode(obj)
        }
    }
    
    var stringValue: String? {
        switch self {
        case .string(let str):
            return str
        case .object(let obj):
            return obj["$oid"]
        }
    }
}

// MARK: - Add Participant Request

struct AddParticipantRequest: Codable {
    let userId: String
}

// MARK: - Participant Name Response

struct ParticipantNameResponse: Codable {
    let exists: Bool?
}
