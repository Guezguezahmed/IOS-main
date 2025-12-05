//
//  ProfileModels.swift
//  IosDam
//
//  Profile data models

import Foundation

// User Profile
struct UserProfile: Codable {
    let initials: String
    let name: String
    let handle: String
    let level: Int
    let wins: Int
    let losses: Int
    let winRate: String
    let goalsScored: Int
    let assists: Int
    let cleanSheets: Int
    let totalMatches: Int
    let favoriteStadium: String
    let memberSince: String
}

// Achievement
struct Achievement: Identifiable {
    let id = UUID()
    let iconName: String
    let iconColor: String // hex color
    let title: String
    let description: String
    let unlocked: Bool
}

// Match Result
struct MatchResultProfile: Identifiable {
    let id = UUID()
    let status: String // "W", "L", "D"
    let title: String
    let date: String
    let score: String
}

// Mock Data
extension UserProfile {
    static let mock = UserProfile(
        initials: "AR",
        name: "Alex Rodriguez",
        handle: "alexrod",
        level: 12,
        wins: 28,
        losses: 12,
        winRate: "62%",
        goalsScored: 84,
        assists: 32,
        cleanSheets: 15,
        totalMatches: 45,
        favoriteStadium: "Arena Sports Complex",
        memberSince: "January 2024"
    )
}

extension Achievement {
    static let mockAchievements = [
        Achievement(iconName: "star.fill", iconColor: "FF9800", title: "Hat Trick Hero", description: "Score 3 goals in one match", unlocked: true),
        Achievement(iconName: "flame.fill", iconColor: "FF9800", title: "Winning Streak", description: "Win 5 matches in a row", unlocked: true),
        Achievement(iconName: "star.fill", iconColor: "FF9800", title: "Tournament Champion", description: "Win a tournament", unlocked: true),
        Achievement(iconName: "star.circle.fill", iconColor: "4CAF50", title: "Perfect Season", description: "Win all league matches", unlocked: false)
    ]
}

extension MatchResultProfile {
    static let mockMatches = [
        MatchResultProfile(status: "W", title: "Champions Cup", date: "Nov 5", score: "3-1"),
        MatchResultProfile(status: "W", title: "Sunday League", date: "Nov 3", score: "2-0"),
        MatchResultProfile(status: "L", title: "Quick Match", date: "Nov 1", score: "1-2"),
        MatchResultProfile(status: "W", title: "Elite Knockout", date: "Oct 28", score: "4-2"),
        MatchResultProfile(status: "D", title: "Weekend Warriors", date: "Oct 25", score: "2-2")
    ]
}
