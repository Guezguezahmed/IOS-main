//
// EventComponents.swift
// IosDam
//
// Reusable components for Events views

import SwiftUI

// MARK: - Stat Card

struct StatCardView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Search Bar

struct SearchBarView: View {
    @Binding var query: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.gray)
            TextField("Search tournaments or stadiums...", text: $query)
                .font(.system(size: 14))
            if !query.isEmpty {
                Button(action: { query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Tab Data Model

struct TabData {
    let label: String
    let count: Int
    let isSelected: Bool
}

// MARK: - Tab Chip

struct TabChipView: View {
    let tab: TabData
    @Binding var selectedType: String
    
    var body: some View {
        Button(action: {
            selectedType = tab.label
        }) {
            HStack(spacing: 4) {
                Text(verbatim: tab.label)
                    .font(.system(size: 14, weight: tab.isSelected ? .semibold : .regular))
                Text(verbatim: "(\(tab.count))")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(tab.isSelected ? Color.green : Color.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(tab.isSelected ? Color.green.opacity(0.15) : Color(UIColor.systemGray6))
            .foregroundColor(tab.isSelected ? Color.green : Color.black)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(tab.isSelected ? Color.green : Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

// MARK: - Event Card

struct EventCardView: View {
    let event: Tournament
    let onClick: () -> Void
    
    var body: some View {
        NavigationLink(destination: 
            EventDetailView(
                event: event,
                onNavigateToMatches: {
                    // TODO: Navigate to matches
                }
            )
        ) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                                            Text(event.tournamentName)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color.white)
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 14))
                                                Text(organizerName)
                                                    .font(.system(size: 14))
                                            }
                                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    Spacer()
                }
                .padding()
                .background(headerColor)
                .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // Body
                VStack(alignment: .leading, spacing: 8) {
                    DetailRowView(icon: "location.fill", text: event.stadium)
                    DetailRowView(icon: "calendar", text: "\(formattedDate) • \(event.time)")
                    
                    HStack {
                        DetailRowView(icon: "person.2.fill", text: "\(participantsCount)/\(event.maxParticipants) Players")
                        Spacer()
                        if event.prizePool ?? 0 > 0 {
                            Text("$\(event.prizePool ?? 0)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.52, green: 0.89, blue: 0.63))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Progress Bar
                    let progress = Float(participantsCount) / Float(max(event.maxParticipants, 1))
                    VStack(alignment: .trailing, spacing: 4) {
                        ProgressView(value: Double(progress))
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.orange))
                            .frame(height: 6)
                        Text("\(Int(progress * 100))% Full")
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
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
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: event.date)
    }
}

// MARK: - Detail Row

struct DetailRowView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.green)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.label))
        }
    }
}

// MARK: - Rounded Corner Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
