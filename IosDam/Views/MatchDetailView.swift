//
//  MatchDetailView.swift
//  IosDam
//
//  Detailed Match View - Xcode 12.3 Compatible
//

import SwiftUI

struct MatchDetailView: View {
    let matchId: String
    
    @State private var match: MatchDetail?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var showingEditScore: Bool = false
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading match details...")
            } else if let error = errorMessage {
                errorView(message: error)
            } else if let match = match {
                matchContentView(match: match)
            }
        }
        .navigationBarTitle("Match Details", displayMode: .inline)
        .onAppear {
            loadMatch()
        }
        .sheet(isPresented: $showingEditScore) {
            if let match = match {
                EditScoreView(match: match) { updatedMatch in
                    self.match = updatedMatch
                }
            }
        }
    }
    
    private func matchContentView(match: MatchDetail) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                matchHeaderSection(match: match)
                scoreSection(match: match)
                matchInfoSection(match: match)
                
                if let stats = match.statistics {
                    statisticsSection(stats: stats)
                }
                
                if let events = match.events, !events.isEmpty {
                    eventsSection(events: events)
                }
            }
            .padding()
        }
    }
    
    private func matchHeaderSection(match: MatchDetail) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                teamView(team: match.id_equipe1, isHome: true)
                Text("VS")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                teamView(team: match.id_equipe2, isHome: false)
            }
            
            statusBadge(status: match.statut)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func teamView(team: MatchTeamInfo?, isHome: Bool) -> some View {
        VStack(spacing: 8) {
            if let team = team {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(team.nom.prefix(2).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                    )
                
                Text(team.nom)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(isHome ? "Home" : "Away")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("TBD")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func scoreSection(match: MatchDetail) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 40) {
                scoreBox(score: match.score_eq1, teamName: match.id_equipe1?.nom ?? "Team 1")
                Text("-")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                scoreBox(score: match.score_eq2, teamName: match.id_equipe2?.nom ?? "Team 2")
            }
            
            if match.statut == .COMPLETED || match.statut == .IN_PROGRESS {
                Button(action: {
                    showingEditScore = true
                }) {
                    Text("Edit Score")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func scoreBox(score: Int, teamName: String) -> some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.system(size: 48, weight: .bold))
            Text(teamName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func matchInfoSection(match: MatchDetail) -> some View {
        VStack(spacing: 12) {
            InfoRow(icon: "calendar", title: "Date", value: formattedDate(match.date))
            InfoRow(icon: "mappin.circle", title: "Stadium", value: match.id_terrain?.nom ?? "TBD")
            InfoRow(icon: "person.fill", title: "Referee", value: match.id_arbitre?.fullName ?? "TBD")
            InfoRow(icon: "number", title: "Round", value: "Round \(match.round)")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func statisticsSection(stats: MatchStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Match Statistics")
                .font(.headline)
                .fontWeight(.bold)
            
            if let poss1 = stats.possession_team1, let poss2 = stats.possession_team2 {
                StatBar(title: "Possession", value1: poss1, value2: poss2, suffix: "%")
            }
            
            if let shots1 = stats.shots_team1, let shots2 = stats.shots_team2 {
                StatBar(title: "Shots", value1: shots1, value2: shots2)
            }
            
            if let shotsOn1 = stats.shots_on_target_team1, let shotsOn2 = stats.shots_on_target_team2 {
                StatBar(title: "Shots on Target", value1: shotsOn1, value2: shotsOn2)
            }
            
            if let fouls1 = stats.fouls_team1, let fouls2 = stats.fouls_team2 {
                StatBar(title: "Fouls", value1: fouls1, value2: fouls2)
            }
            
            if let yellow1 = stats.yellow_cards_team1, let yellow2 = stats.yellow_cards_team2 {
                StatBar(title: "Yellow Cards", value1: yellow1, value2: yellow2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func eventsSection(events: [MatchEvent]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Match Events")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(events.sorted(by: { $0.minute < $1.minute })) { event in
                EventRow(event: event)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func statusBadge(status: MatchStatus) -> some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " "))
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor(status))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private func statusColor(_ status: MatchStatus) -> Color {
        switch status {
        case .SCHEDULED:
            return Color.blue
        case .IN_PROGRESS:
            return Color.orange
        case .COMPLETED:
            return Color.green
        case .CANCELLED:
            return Color.red
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "TBD" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                loadMatch()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func loadMatch() {
        isLoading = true
        errorMessage = nil
        
        APIService.getMatchById(matchId: matchId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let matchDetail):
                    match = matchDetail
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct StatBar: View {
    let title: String
    let value1: Int
    let value2: Int
    var suffix: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(value1)\(suffix)")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                GeometryReader { geometry in
                    let total = value1 + value2
                    let ratio = total > 0 ? CGFloat(value1) / CGFloat(total) : 0.5
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * ratio)
                        
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: geometry.size.width * (1 - ratio))
                    }
                    .frame(height: 8)
                    .cornerRadius(4)
                }
                .frame(height: 8)
                
                Text("\(value2)\(suffix)")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
}

struct EventRow: View {
    let event: MatchEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(event.minute)'")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 35)
                .padding(6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
            
            Image(systemName: eventIcon)
                .foregroundColor(eventColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.event_type.rawValue.replacingOccurrences(of: "_", with: " "))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let description = event.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var eventIcon: String {
        switch event.event_type {
        case .GOAL:
            return "soccerball"
        case .YELLOW_CARD:
            return "square.fill"
        case .RED_CARD:
            return "square.fill"
        case .SUBSTITUTION:
            return "arrow.left.arrow.right"
        case .PENALTY:
            return "exclamationmark.circle"
        }
    }
    
    private var eventColor: Color {
        switch event.event_type {
        case .GOAL:
            return .green
        case .YELLOW_CARD:
            return .yellow
        case .RED_CARD:
            return .red
        case .SUBSTITUTION:
            return .blue
        case .PENALTY:
            return .orange
        }
    }
}

// MARK: - Edit Score View

struct EditScoreView: View {
    @Environment(\.presentationMode) var presentationMode
    let match: MatchDetail
    let onUpdate: (MatchDetail) -> Void
    
    @State private var score1: String
    @State private var score2: String
    @State private var selectedStatus: MatchStatus
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    
    init(match: MatchDetail, onUpdate: @escaping (MatchDetail) -> Void) {
        self.match = match
        self.onUpdate = onUpdate
        _score1 = State(initialValue: "\(match.score_eq1)")
        _score2 = State(initialValue: "\(match.score_eq2)")
        _selectedStatus = State(initialValue: match.statut)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Scores")) {
                    HStack {
                        Text(match.id_equipe1?.nom ?? "Team 1")
                        Spacer()
                        TextField("Score", text: $score1)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text(match.id_equipe2?.nom ?? "Team 2")
                        Spacer()
                        TextField("Score", text: $score2)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                }
                
                Section(header: Text("Match Status")) {
                    Picker("Status", selection: $selectedStatus) {
                        Text("Scheduled").tag(MatchStatus.SCHEDULED)
                        Text("In Progress").tag(MatchStatus.IN_PROGRESS)
                        Text("Completed").tag(MatchStatus.COMPLETED)
                        Text("Cancelled").tag(MatchStatus.CANCELLED)
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: updateScore) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Update Match")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .navigationBarTitle("Edit Score", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func updateScore() {
        guard let s1 = Int(score1), let s2 = Int(score2) else {
            errorMessage = "Please enter valid scores"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        let scoreData = UpdateMatchScoreRequest(
            score_eq1: s1,
            score_eq2: s2,
            statut: selectedStatus
        )
        
        APIService.updateMatchScore(matchId: match.id, scoreData: scoreData) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success(let updatedMatch):
                    onUpdate(updatedMatch)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(matchId: "sample-id")
    }
}
