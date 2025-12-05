//
// TeamDetailsView.swift
// IosDam
//
// Detailed team view with roster

import SwiftUI

struct TeamDetailsView: View {
    let teamId: String
    @State private var team: PopulatedEquipe? = nil
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            if let team = team {
                teamContentView(team: team)
            } else if isLoading {
                ProgressView("Loading team...")
            } else {
                errorView
            }
        }
        .navigationBarTitle("Team Details", displayMode: .inline)
        .onAppear {
            loadTeamDetails()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Content Views
    
    func teamContentView(team: PopulatedEquipe) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                teamHeaderView(team: team)
                
                if let stats = team.stats {
                    statsSection(stats: stats)
                }
                
                if !team.starters.isEmpty {
                    startersSection(team: team)
                }
                
                if !team.substitutes.isEmpty {
                    substitutesSection(team: team)
                }
                
                otherMembersSection(team: team)
                
                Spacer(minLength: 30)
            }
        }
    }
    
    var errorView: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(Color.gray)
            Text("Failed to load team")
                .foregroundColor(Color.gray)
        }
    }
    
    func teamHeaderView(team: PopulatedEquipe) -> some View {
        VStack(spacing: 15) {
            // Logo placeholder (AsyncImage not available in iOS 14)
            TeamLogoPlaceholder(name: team.nom)
                .frame(width: 100, height: 100)
            
            Text(team.nom)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.black)
            
            Text(team.categorie.rawValue)
                .font(.system(size: 16))
                .foregroundColor(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(categoryColor(team.categorie))
                .cornerRadius(20)
        }
        .padding(.top, 20)
    }
    
    func statsSection(stats: StatsEquipe) -> some View {
        VStack(spacing: 15) {
            Text("Statistics")
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                StatCard(title: "Wins", value: "\(stats.wins)", color: Color.green)
                StatCard(title: "Losses", value: "\(stats.losses)", color: Color.red)
                StatCard(title: "Win Rate", value: String(format: "%.1f%%", stats.win_rate), color: Color.blue)
                StatCard(title: "Trophies", value: "\(stats.trophies_won)", color: Color.orange)
                StatCard(title: "Goals For", value: "\(stats.goals_for)", color: Color.green)
                StatCard(title: "Goals Against", value: "\(stats.goals_against)", color: Color.red)
            }
            .padding(.horizontal)
        }
    }
    
    func startersSection(team: PopulatedEquipe) -> some View {
        VStack(spacing: 10) {
            Text("Starters")
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ForEach(team.starters) { player in
                PlayerRowView(player: player)
            }
        }
    }
    
    func substitutesSection(team: PopulatedEquipe) -> some View {
        VStack(spacing: 10) {
            Text("Substitutes")
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ForEach(team.substitutes) { player in
                PlayerRowView(player: player)
            }
        }
    }
    
    func otherMembersSection(team: PopulatedEquipe) -> some View {
        let otherMembers = team.members.filter { member in
            !team.starters.contains(where: { $0._id == member._id }) &&
            !team.substitutes.contains(where: { $0._id == member._id })
        }
        
        return Group {
            if !otherMembers.isEmpty {
                VStack(spacing: 10) {
                    Text("Other Members")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(otherMembers) { player in
                        PlayerRowView(player: player)
                    }
                }
            }
        }
    }
    
    // MARK: - Data Loading
    
    func loadTeamDetails() {
        isLoading = true
        
        APIService.getTeamById(teamId: teamId) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let teamData):
                    self.team = teamData
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    func categoryColor(_ category: Categorie) -> Color {
        switch category {
        case .KIDS: return Color.purple
        case .YOUTH: return Color.blue
        case .JUNIOR: return Color.orange
        case .SENIOR: return Color.green
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Player Row View

struct PlayerRowView: View {
    let player: PlayerInfo
    
    var body: some View {
        HStack(spacing: 15) {
            // Player initials
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 45, height: 45)
                Text(initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.green)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(player.fullName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.black)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    var initials: String {
        let firstInitial = String(player.prenom.prefix(1)).uppercased()
        let lastInitial = String(player.nom.prefix(1)).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Team Logo Placeholder (reused from TeamsListView)



// MARK: - Preview

struct TeamDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamDetailsView(teamId: "test-id")
        }
    }
}
