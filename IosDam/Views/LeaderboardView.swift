//
//  LeaderboardView.swift
//  IosDam
//
//  Tournament Leaderboard/Standings View - Xcode 12.3 Compatible
//

import SwiftUI

struct LeaderboardView: View {
    let tournamentId: String
    
    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading standings...")
            } else if let error = errorMessage {
                errorView(message: error)
            } else if entries.isEmpty {
                emptyStateView
            } else {
                standingsTable
            }
        }
        .navigationBarTitle("Leaderboard", displayMode: .large)
        .onAppear {
            loadStandings()
        }
    }
    
    private var standingsTable: some View {
        ScrollView {
            VStack(spacing: 0) {
                tableHeader
                
                ForEach(entries) { entry in
                    LeaderboardRow(entry: entry)
                        .background(rowBackground(position: entry.position))
                }
            }
            .padding()
        }
    }
    
    private var tableHeader: some View {
        HStack(spacing: 8) {
            headerText("#", width: 30)
            headerText("Team", width: nil)
            headerText("P", width: 30)
            headerText("W", width: 30)
            headerText("D", width: 30)
            headerText("L", width: 30)
            headerText("GD", width: 35)
            headerTextBold("Pts", width: 35)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func headerText(_ text: String, width: CGFloat?) -> some View {
        let view = Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
        
        if let w = width {
            return AnyView(view.frame(width: w))
        } else {
            return AnyView(view.frame(maxWidth: .infinity, alignment: .leading))
        }
    }
    
    private func headerTextBold(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .frame(width: width)
    }
    
    private func rowBackground(position: Int) -> Color {
        switch position {
        case 1:
            return Color.yellow.opacity(0.1)
        case 2:
            return Color.gray.opacity(0.1)
        case 3:
            return Color.orange.opacity(0.1)
        default:
            return Color.clear
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.number")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Standings Available")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Standings will appear once matches are played")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
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
                loadStandings()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func loadStandings() {
        isLoading = true
        errorMessage = nil
        
        APIService.getTournamentStandings(tournamentId: tournamentId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let standings):
                    entries = standings.sorted { $0.position < $1.position }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 8) {
            positionBadge
            
            HStack(spacing: 8) {
                if entry.team_logo != nil {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text(entry.team_name.prefix(1).uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                        )
                }
                
                Text(entry.team_name)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(entry.played)")
                .font(.caption)
                .frame(width: 30)
            
            Text("\(entry.won)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .frame(width: 30)
            
            Text("\(entry.drawn)")
                .font(.caption)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            Text("\(entry.lost)")
                .font(.caption)
                .foregroundColor(.red)
                .frame(width: 30)
            
            Text(goalDifferenceText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(goalDifferenceColor)
                .frame(width: 35)
            
            Text("\(entry.points)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(width: 35)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private var positionBadge: some View {
        ZStack {
            Circle()
                .fill(positionColor)
                .frame(width: 30, height: 30)
            
            Text("\(entry.position)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var positionColor: Color {
        switch entry.position {
        case 1:
            return Color.yellow
        case 2:
            return Color.gray
        case 3:
            return Color.orange
        default:
            return Color.blue
        }
    }
    
    private var goalDifferenceText: String {
        let gd = entry.goal_difference
        if gd > 0 {
            return "+\(gd)"
        } else {
            return "\(gd)"
        }
    }
    
    private var goalDifferenceColor: Color {
        if entry.goal_difference > 0 {
            return .green
        } else if entry.goal_difference < 0 {
            return .red
        } else {
            return .secondary
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView(tournamentId: "sample-id")
    }
}
