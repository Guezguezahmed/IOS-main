//
// EventDetailView.swift
// IosDam
//
// Event detail screen with join, generate bracket, and view matches

import SwiftUI

struct EventDetailView: View {
    let event: Tournament
    let onNavigateToMatches: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var participantNames: [String] = []
    @State private var isLoadingParticipants = false
    @State private var currentUserId: String? = nil
    @State private var isGeneratingBracket = false
    @State private var isBracketGenerated = false
    @State private var isUserAnArbitre = false
    @State private var hasJoined = false
    @State private var userRole: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Body
                bodySection
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: loadData)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
    
    // MARK: - Header Section
    
    var headerSection: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(headerColor)
                .frame(height: 220)
            
            VStack(alignment: .leading) {
                // Back and Share buttons
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: { /* Share */ }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Event info
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.type)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text(event.tournamentName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.white)
                    
                    Text(organizerName)
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.8))
                }
                .padding()
            }
            .frame(height: 220)
        }
    }
    
    // MARK: - Body Section
    
    var bodySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text(event.stadium)
                    .font(.system(size: 20, weight: .bold))
                
                // Event details
                DetailInfoRowView(icon: "calendar", title: "Date", value: formattedDate)
                DetailInfoRowView(icon: "clock", title: "Time", value: event.time)
                DetailInfoRowView(icon: "person.2.fill", title: "Participants", value: "\(participantsCount)/\(event.maxParticipants) Teams")
                DetailInfoRowView(icon: "dollarsign.circle", title: "Entry Fee", value: "$\(event.entryFee ?? 0)")
                DetailInfoRowView(icon: "star.fill", title: "Prize Pool", value: "$\(event.prizePool ?? 0)", isLast: true)
            }
            
            Group {
                // Registered teams
                VStack(alignment: .leading, spacing: 12) {
                    Text("Registered Teams (\(participantsCount))")
                        .font(.system(size: 20, weight: .bold))
                    
                    if isLoadingParticipants {
                        ProgressView()
                    } else {
                        ForEach(Array(participantNames.enumerated()), id: \.offset) { index, name in
                            TeamRowView(name: name, index: index)
                        }
                    }
                }
                
                // Rules (if any)
                if !event.referee.isEmpty {
                    RulesCardView(rules: ["Tournament follows standard FIFA rules", "Team must have minimum 11 players", "Fair play is mandatory"])
                }
            }
            
            Group {
                // Action buttons
                actionButtons
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .offset(y: -30)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Action Buttons
    
    var actionButtons: some View {
        VStack(spacing: 12) {
            joinSection
            matchSection
            newFeatureButtons
        }
    }
    
    // MARK: - Join Section
    
    private var joinSection: some View {
        Group {
            if isOwner {
                Button(action: { /* TODO: Navigate to edit tournament */ }) {
                    Text("Edit Tournament")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            } else if hasJoined {
                Text("Joined")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(12)
            } else if userRole == "OWNER" {
                Button(action: joinTournament) {
                    Text("Join Tournament")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Match Section
    
    private var matchSection: some View {
        Group {
            if isBracketGenerated {
                Button(action: onNavigateToMatches) {
                    Text("View Matches")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            } else if isUserAnArbitre {
                Button(action: generateBracket) {
                    HStack {
                        if isGeneratingBracket {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        } else {
                            Text("Generate Bracket")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isGeneratingBracket ? Color.gray : Color.orange)
                    .cornerRadius(12)
                }
                .disabled(isGeneratingBracket)
            }
        }
    }
    
    // MARK: - New Feature Buttons
    
    private var newFeatureButtons: some View {
        Group {
            NavigationLink(destination: LeaderboardView(tournamentId: event.id)) {
                HStack {
                    Image(systemName: "list.number")
                        .foregroundColor(.white)
                    Text("View Leaderboard")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.29, green: 0.0, blue: 0.51))
                .cornerRadius(12)
            }
            
            if isBracketGenerated {
                NavigationLink(destination: TournamentBracketsView(tournament: event)) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.white)
                        Text("View Brackets")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.0, green: 0.5, blue: 0.5))
                    .cornerRadius(12)
                }
            }
            
            NavigationLink(destination: TournamentForumView(tournamentId: event.id)) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .foregroundColor(.white)
                    Text("Tournament Forum")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.6, green: 0.4, blue: 0.2))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var headerColor: Color {
        event.type == "Tournament" ? Color.purple : Color.orange
    }
    
    var organizerName: String {
        if let org = event.idOrganisateur {
            return [org.prenom, org.nom].compactMap { $0 }.joined(separator: " ")
        }
        return event.nom
    }
    
    var participantsCount: Int {
           event.participants.compactMap { $0.stringValue }.count
       }
       
       var formattedDate: String {
           let formatter = DateFormatter()
           formatter.dateFormat = "EEEE, MMMM d, yyyy"
           return formatter.string(from: event.date)
       }
       
       var isOwner: Bool {
           currentUserId == event.idOrganisateur?.id
       }
       
       // MARK: - Data Loading
    
    func loadData() {
        // Get current user
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
            currentUserId = user._id
            userRole = user.role
        }
        
        isBracketGenerated = event.isBracketGenerated
        
        // Check if user is arbitre
        if let userId = currentUserId, let organizerId = event.idOrganisateur?.id {
            APIService.checkArbitreInAcademie(academieId: organizerId, userId: userId) { result in
                DispatchQueue.main.async {
                    if case .success(let isArbitre) = result {
                        isUserAnArbitre = isArbitre
                    }
                }
            }
        }
        
        // Load participant names
        loadParticipantNames()
        
        // Check if user has joined
        if let userId = currentUserId {
            let participantIds = event.participants.compactMap { $0.stringValue }
            hasJoined = participantIds.contains(userId)
        }
    }
    
    func loadParticipantNames() {
        isLoadingParticipants = true
        let participantIds = event.participants.compactMap { $0.stringValue }
        
        var names: [String] = []
        let group = DispatchGroup()
        
        for id in participantIds {
            group.enter()
            APIService.getUserProfile(userId: id) { result in
                if case .success(let user) = result {
                    let name = [user.prenom, user.nom].joined(separator: " ")
                    names.append(name)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            participantNames = names
            isLoadingParticipants = false
        }
    }
    
    func joinTournament() {
        guard let userId = currentUserId else { return }
        
        APIService.addParticipant(coupeId: event.id, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    alertMessage = "You have joined the tournament!"
                    showAlert = true
                    hasJoined = true
                case .failure(let error):
                    alertMessage = "Failed to join: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    func generateBracket() {
        isGeneratingBracket = true
        
        APIService.generateBracket(coupeId: event.id) { result in
            DispatchQueue.main.async {
                isGeneratingBracket = false
                switch result {
                case .success:
                    alertMessage = "Bracket generated successfully!"
                    showAlert = true
                    isBracketGenerated = true
                case .failure(let error):
                    alertMessage = "Failed to generate: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Detail Info Row

struct DetailInfoRowView: View {
    let icon: String
    let title: String
    let value: String
    var isLast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color.green)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                    Text(value)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            if !isLast {
                Divider()
            }
        }
    }
}

// MARK: - Team Row

struct TeamRowView: View {
    let name: String
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.white)
                .frame(width: 40, height: 40)
                .background(Color.green)
                .cornerRadius(8)
            
            Text(name)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Rules Card

struct RulesCardView: View {
    let rules: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color.blue)
                Text("Tournament Rules")
                    .font(.system(size: 18, weight: .bold))
            }
            
            ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(rule)
                        .font(.system(size: 14))
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}
