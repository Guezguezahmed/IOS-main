//
// TeamsListView.swift
// IosDam
//
// List all teams with search and filter

import SwiftUI

struct TeamsListView: View {
    // 1. Add this environment variable to handle navigation back
    @Environment(\.presentationMode) var presentationMode
    
    @State private var teams: [Equipe] = []
    @State private var filteredTeams: [Equipe] = []
    @State private var searchText = ""
    @State private var selectedCategory: Categorie? = nil
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showCreateTeam = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    HStack {
                        // 2. Add Back Button here
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 8) // Add some spacing

                        Text("Teams")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.black)
                        
                        Spacer()
                        
                        Button(action: { showCreateTeam = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color.green)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.gray)
                        TextField("Search teams...", text: $searchText)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryFilterButton(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            ForEach(Categorie.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
                
                // Teams list
                if isLoading {
                    Spacer()
                    ProgressView("Loading teams...")
                    Spacer()
                } else if filteredTeams.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("No teams found")
                            .font(.system(size: 18))
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredTeams) { team in
                                NavigationLink(destination: TeamDetailsView(teamId: team._id)) {
                                    TeamCardView(team: team)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
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
        .onChange(of: searchText) { _ in
            filterTeams()
        }
        .onChange(of: selectedCategory) { _ in
            filterTeams()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showCreateTeam) {
            CreateTeamView(onTeamCreated: {
                loadTeams()
            })
        }
    }
    
    func loadTeams() {
        isLoading = true
        
        // Get current user
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let currentUser = try? JSONDecoder().decode(UserModel.self, from: data) else {
            isLoading = false
            alertMessage = "User not found. Please log in again."
            showAlert = true
            return
        }
        
        APIService.getAllTeams { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let allTeams):
                    // Filter: Only show teams owned by current user
                    self.teams = allTeams.filter { $0.id_academie == currentUser._id }
                    filterTeams()
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    func filterTeams() {
        var filtered = teams
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { team in
                team.nom.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.categorie == category }
        }
        
        filteredTeams = filtered
    }
}

// MARK: - Team Card View

struct TeamCardView: View {
    let team: Equipe
    
    var body: some View {
        HStack(spacing: 15) {
            // Team logo or placeholder
            if let logoURL = team.logo, !logoURL.isEmpty {
                TeamLogoPlaceholder(name: team.nom)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                TeamLogoPlaceholder(name: team.nom)
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(team.nom)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.black)
                
                Text(team.categorie.rawValue)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(categoryColor(team.categorie))
                    .cornerRadius(5)
                
                if let stats = team.stats {
                    HStack(spacing: 10) {
                        Label("\(stats.wins)W", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(Color.green)
                        Label("\(stats.losses)L", systemImage: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(Color.red)
                        if stats.trophies_won > 0 {
                            Label("\(stats.trophies_won)", systemImage: "trophy.fill")
                                .font(.caption)
                                .foregroundColor(Color.orange)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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

// MARK: - Team Logo Placeholder

struct TeamLogoPlaceholder: View {
    let name: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.2))
            Text(initials)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.green)
        }
    }
    
    var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color.white : Color.gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color.gray.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: - Preview

struct TeamsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamsListView()
        }
    }
}
