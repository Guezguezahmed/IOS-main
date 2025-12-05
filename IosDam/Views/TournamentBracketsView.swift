//
//  TournamentBracketsView.swift
//  IosDam
//
//  Tournament Bracket Visualization - Xcode 12.3 Compatible
//

import SwiftUI

struct TournamentBracketsView: View {
    let tournament: Tournament
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            VStack(spacing: 40) {
                if let matches = tournament.matches, !matches.isEmpty {
                    bracketsContent(matches: matches)
                } else if tournament.isBracketGenerated {
                    Text("Bracket generated but no matches available")
                        .foregroundColor(.secondary)
                } else {
                    emptyBracketView
                }
            }
            .padding(32)
        }
        .navigationBarTitle("Tournament Bracket", displayMode: .inline)
    }
    
    private func bracketsContent(matches: [Match]) -> some View {
        let roundsDict = Dictionary(grouping: matches, by: { $0.round })
        let sortedRounds = roundsDict.keys.sorted()
        
        return HStack(alignment: .top, spacing: 60) {
            ForEach(sortedRounds, id: \.self) { round in
                roundColumn(round: round, matches: roundsDict[round] ?? [])
            }
        }
    }
    
    private func roundColumn(round: Int, matches: [Match]) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Text(roundName(round))
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            ForEach(matches) { match in
                MatchBracketCard(match: match)
            }
        }
    }
    
    private func roundName(_ round: Int) -> String {
        switch round {
        case 1:
            return "Round 1"
        case 2:
            return "Quarter Finals"
        case 3:
            return "Semi Finals"
        case 4:
            return "Final"
        default:
            return "Round \(round)"
        }
    }
    
    private var emptyBracketView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Bracket Not Generated")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("The tournament bracket will be generated once all participants are registered")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Match Bracket Card

struct MatchBracketCard: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 0) {
            teamRow(teamId: match.idEquipe1, score: match.scoreEq1, isTop: true)
            Divider()
            teamRow(teamId: match.idEquipe2, score: match.scoreEq2, isTop: false)
        }
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func teamRow(teamId: String?, score: Int?, isTop: Bool) -> some View {
        HStack {
            Text(teamId != nil ? "Team" : "TBD")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(teamId != nil ? .primary : .secondary)
            
            Spacer()
            
            if let score = score {
                Text("\(score)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            } else {
                Text("-")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
    }
}

struct TournamentBracketsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TournamentBracketsView Preview")
            .navigationTitle("Tournament Bracket")
    }
}
