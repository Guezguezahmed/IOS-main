//
//  ProfileView.swift
//  IosDam
//
//  Profile screen matching Android design - Xcode 12.3 Compatible

import SwiftUI

struct ProfileView: View {
    @State private var user: UserProfile = .mock
    @State private var achievements: [Achievement] = Achievement.mockAchievements
    @State private var matches: [MatchResultProfile] = MatchResultProfile.mockMatches
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Custom Header
                customHeader
                
                // Main Profile Card
                MainProfileCardView(user: user)
                
                Spacer().frame(height: 16)
                
                // Quick Stats Grid
                QuickStatsGridView(user: user)
                
                Spacer().frame(height: 8)
                
                // Achievements and Matches Section
                achievementsAndMatchesSection
                
                // Footer Section
                footerSection
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Achievements and Matches Section
    
    private var achievementsAndMatchesSection: some View {
        Group {
            // Achievements Section
            SectionHeaderView(title: "Achievements", showViewAll: true)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievements) { achievement in
                        AchievementCardView(achievement: achievement)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer().frame(height: 8)
            
            // Recent Matches Section
            SectionHeaderView(title: "Recent Matches", showViewAll: true)
            
            VStack(spacing: 0) {
                ForEach(matches) { match in
                    MatchRowView(match: match)
                }
            }
            
            Spacer().frame(height: 16)
        }
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        Group {
            FooterDetailRowView(iconName: "location.fill", title: "Favorite Stadium", value: user.favoriteStadium)
            FooterDetailRowView(iconName: "calendar", title: "Member Since", value: user.memberSince)
            
            Spacer().frame(height: 32)
        }
    }
    
    // MARK: - Custom Header
    
    private var customHeader: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
            
            NavigationLink(destination: ProfileSettingsView()) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Main Profile Card

struct MainProfileCardView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Initials Circle
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 64, height: 64)
                    Text(user.initials)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.white)
                    
                    Text("@\(user.handle)")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    Spacer().frame(height: 4)
                    
                    // Level Badge
                    Text("Level \(user.level)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "4CAF50"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(20)
            
            // Stats Row
            HStack(spacing: 0) {
                ProfileStatCircleView(value: "\(user.wins)", label: "Wins")
                Spacer()
                ProfileStatCircleView(value: "\(user.losses)", label: "Losses")
                Spacer()
                ProfileStatCircleView(value: user.winRate, label: "Win Rate")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(hex: "4CAF50"))
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Profile Stat Circle

struct ProfileStatCircleView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 70, height: 70)
                Text(value)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color.white)
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.9))
        }
    }
}

// MARK: - Quick Stats Grid

struct QuickStatsGridView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                QuickStatCardView(iconName: "sportscourt.fill", iconColor: "2196F3", value: "\(user.goalsScored)", label: "Goals Scored")
                QuickStatCardView(iconName: "arrow.up.right", iconColor: "673AB7", value: "\(user.assists)", label: "Assists")
            }
            HStack(spacing: 16) {
                QuickStatCardView(iconName: "shield.fill", iconColor: "FF9800", value: "\(user.cleanSheets)", label: "Clean Sheets")
                QuickStatCardView(iconName: "person.3.fill", iconColor: "4CAF50", value: "\(user.totalMatches)", label: "Total Matches")
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Quick Stat Card

struct QuickStatCardView: View {
    let iconName: String
    let iconColor: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: iconColor))
            
            Text(value)
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(Color(UIColor.label))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    let title: String
    let showViewAll: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
            
            if showViewAll {
                HStack(spacing: 4) {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "4CAF50"))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "4CAF50"))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Achievement Card

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: achievement.iconColor).opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: achievement.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: achievement.iconColor))
            }
            
            Text(achievement.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
                .lineLimit(2)
            
            Text(achievement.description)
                .font(.system(size: 11))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .lineLimit(2)
        }
        .frame(width: 150, height: 120, alignment: .topLeading)
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Match Row

struct MatchRowView: View {
    let match: MatchResultProfile
    
    var statusColor: Color {
        switch match.status {
        case "W": return Color(hex: "4CAF50")
        case "L": return Color(hex: "F44336")
        case "D": return Color(hex: "9E9E9E")
        default: return Color.black
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Status Box
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusColor)
                        .frame(width: 40, height: 40)
                    Text(match.status)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                    Text(match.date)
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                
                Spacer()
                
                Text(match.score)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 4)
        }
    }
}

// MARK: - Footer Detail Row

struct FooterDetailRowView: View {
    let iconName: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "4CAF50"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(UIColor.label))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
