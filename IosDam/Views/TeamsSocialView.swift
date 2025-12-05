//
//  TeamsSocialView.swift
//  IosDam
//
//  Created by macbook on 1/12/2025.
//

import SwiftUI

// MARK: - Team Invite Model

struct TeamInvite: Identifiable {
    let id = UUID()
    let teamId: String
    let teamName: String
    let invitedBy: String
    let memberCount: Int
    let teamColor: Color
}

// MARK: - Teams Tab Enum

enum TeamsTab {
    case myTeams
    case invites
    case discover
}

// MARK: - Main View

struct TeamsSocialView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: TeamsTab = .myTeams
    @State private var searchText: String = ""
    
    // Data from API
    @State private var myTeams: [Equipe] = []
    @State private var allTeams: [Equipe] = []
    @State private var invites: [TeamInvite] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Teams")
                        .font(.system(size: 28, weight: .bold))
                    Text("Manage your squads")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Tabs
                HStack(spacing: 12) {
                    TeamTabButton(
                        title: "My Teams",
                        isSelected: selectedTab == .myTeams
                    ) {
                        selectedTab = .myTeams
                    }
                    
                    TeamTabButton(
                        title: "Invites",
                        hasNotification: invites.count > 0,
                        isSelected: selectedTab == .invites
                    ) {
                        selectedTab = .invites
                    }
                    
                    TeamTabButton(
                        title: "Discover",
                        isSelected: selectedTab == .discover
                    ) {
                        selectedTab = .discover
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        if selectedTab == .myTeams {
                            MyTeamsContent(teams: myTeams)
                        } else if selectedTab == .invites {
                            InvitesContent(invites: $invites)
                        } else {
                            DiscoverContent(
                                teams: allTeams,
                                myTeamIds: myTeams.map { $0._id },
                                searchText: $searchText,
                                onJoin: { teamId in
                                    joinTeam(teamId: teamId)
                                }
                            )
                        }
                    }
                }
                
                // FAB for creating team
                if selectedTab == .myTeams {
                    HStack {
                        Spacer()
                        Button(action: {
                            // Navigate to create team
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color.white)
                                .frame(width: 56, height: 56)
                                .background(Color(red: 0.4, green: 0.7, blue: 0.6))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadTeams()
        }
    }
    
    // MARK: - API Calls
    
    func loadTeams() {
        isLoading = true
        errorMessage = nil
        
        // Fetch all teams
        APIService.getAllTeams { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let teams):
                    print("✅ Loaded \(teams.count) teams")
                    allTeams = teams
                    
                    // Filter my teams (teams where current user is owner or member)
                    if let userData = UserDefaults.standard.data(forKey: "currentUser"),
                       let currentUser = try? JSONDecoder().decode(UserModel.self, from: userData) {
                        myTeams = teams.filter { team in
                            team.id_academie == currentUser._id ||
                            team.members.contains(currentUser._id)
                        }
                    }
                    
                    // Load sample invites (you can replace this with real API call)
                    loadInvites()
                    
                case .failure(let error):
                    print("❌ Error loading teams: \(error)")
                    errorMessage = "Failed to load teams: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func loadInvites() {
        // TODO: Replace with real API call when backend supports team invites
        // For now, using sample data
        invites = [
            TeamInvite(teamId: "1", teamName: "The Titans", invitedBy: "@john.d", memberCount: 15, teamColor: .green),
            TeamInvite(teamId: "2", teamName: "Storm Breakers", invitedBy: "@team.lead", memberCount: 8, teamColor: .purple)
        ]
    }
    
    func joinTeam(teamId: String) {
        guard let userData = UserDefaults.standard.data(forKey: "currentUser"),
              let currentUser = try? JSONDecoder().decode(UserModel.self, from: userData) else {
            return
        }
        
        // TODO: Implement join team API call
        // This is a placeholder - replace with actual API endpoint
        print("Joining team: \(teamId) for user: \(currentUser._id)")
    }
}

// MARK: - Team Tab Button

struct TeamTabButton: View {
    let title: String
    var hasNotification: Bool = false
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0.4, green: 0.7, blue: 0.6) : .secondary)
                
                if hasNotification {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(red: 0.9, green: 0.95, blue: 0.93) : Color.clear)
            .cornerRadius(8)
        }
    }
}

// MARK: - My Teams Content

struct MyTeamsContent: View {
    let teams: [Equipe]
    
    let cardColors: [Color] = [
        Color.blue,
        Color.orange,
        Color.purple,
        Color.green,
        Color.red
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            if teams.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No teams yet")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create or join a team to get started")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
            } else {
                ForEach(teams.indices, id: \.self) { index in
                    TeamCard(
                        team: teams[index],
                        cardColor: cardColors[index % cardColors.count]
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct TeamCard: View {
    let team: Equipe
    let cardColor: Color
    
    var teamIcon: String {
        switch team.nom.prefix(1).lowercased() {
        case "t": return "bolt.fill"
        case "p": return "flame.fill"
        case "d": return "shield.fill"
        case "s": return "star.fill"
        default: return "sportscourt.fill"
        }
    }
    
    var body: some View {
        Button(action: {
            // Navigate to team details
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    // Team Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: teamIcon)
                            .font(.system(size: 24))
                            .foregroundColor(Color.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(team.nom)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.white)
                        
                        HStack(spacing: 8){
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 10))
                                Text("\(team.members.count) Members")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(Color.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.white)
                }
                
                // Stats
                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        Text("\(team.stats?.wins ?? 0)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.white)
                        Text("Wins")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(team.stats?.losses ?? 0)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.white)
                        Text("Losses")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(calculateWinRate(team: team))%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.white)
                        Text("Win Rate")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                
                Text("Est. 2024")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            .padding(20)
            .background(cardColor)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func calculateWinRate(team: Equipe) -> Int {
        let wins = team.stats?.wins ?? 0
        let losses = team.stats?.losses ?? 0
        let total = wins + losses
        guard total > 0 else { return 0 }
        return Int((Double(wins) / Double(total)) * 100)
    }
}

// MARK: - Invites Content

struct InvitesContent: View {
    @Binding var invites: [TeamInvite]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pending Invitations")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            if invites.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "envelope.open.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No pending invites")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Team invitations will appear here")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(invites) { invite in
                    TeamInviteCard(invite: invite) { action in
                        if action == .accept {
                            invites.removeAll { $0.id == invite.id }
                        } else {
                            invites.removeAll { $0.id == invite.id }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }
}

struct TeamInviteCard: View {
    let invite: TeamInvite
    let onAction: (InviteAction) -> Void
    
    enum InviteAction {
        case accept, decline
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Team Icon
            Circle()
                .fill(invite.teamColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(invite.teamName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Invited by \(invite.invitedBy)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text("\(invite.memberCount) members")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: { onAction(.decline) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Button(action: { onAction(.accept) }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.4, green: 0.7, blue: 0.6))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(12)
    }
}

// MARK: - Discover Content

struct DiscoverContent: View {
    let teams: [Equipe]
    let myTeamIds: [String]
    @Binding var searchText: String
    let onJoin: (String) -> Void
    
    var filteredTeams: [Equipe] {
        let availableTeams = teams.filter { !myTeamIds.contains($0._id) }
        if searchText.isEmpty {
            return availableTeams
        }
        return availableTeams.filter { $0.nom.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search teams...", text: $searchText)
                    .font(.system(size: 16))
            }
            .padding()
            .background(Color(red: 0.9, green: 0.95, blue: 0.93))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Text("Teams Open for Recruitment")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            if filteredTeams.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No teams found")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Try a different search term")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(filteredTeams, id: \._id) { team in
                    DiscoverTeamCard(team: team, onJoin: onJoin)
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }
}

struct DiscoverTeamCard: View {
    let team: Equipe
    let onJoin: (String) -> Void
    @State private var hasJoined = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Team Icon
            Circle()
                .fill(Color.orange)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.nom)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Seeking powerful strikers")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                let wins = team.stats?.wins ?? 0
                let losses = team.stats?.losses ?? 0
                let winRate = wins + losses > 0 ? Int((Double(wins) / Double(wins + losses)) * 100) : 0
                
                Text("\(wins) wins • \(winRate)% win rate")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Join Button
            Button(action: {
                hasJoined = true
                onJoin(team._id)
            }) {
                Image(systemName: hasJoined ? "checkmark" : "person.badge.plus")
                    .font(.system(size: 16))
                    .foregroundColor(hasJoined ? .green : Color(red: 0.4, green: 0.7, blue: 0.6))
                    .frame(width: 36, height: 36)
                    .background(hasJoined ? Color.green.opacity(0.15) : Color(red: 0.4, green: 0.7, blue: 0.6).opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct TeamsSocialView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsSocialView()
    }
}
