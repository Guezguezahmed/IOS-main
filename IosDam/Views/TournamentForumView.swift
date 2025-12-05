//
//  TournamentForumView.swift
//  IosDam
//
//  Tournament Forum/Discussion View - Xcode 12.3 Compatible
//

import SwiftUI

struct TournamentForumView: View {
    let tournamentId: String
    
    @State private var messages: [ForumMessage] = []
    @State private var newMessage: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var isPosting: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading messages...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                errorView(message: error)
            } else {
                messagesList
                composeSection
            }
        }
        .navigationBarTitle("Forum", displayMode: .inline)
        .onAppear {
            loadMessages()
        }
    }
    
    private var messagesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if messages.isEmpty {
                    emptyStateView
                } else {
                    ForEach(messages.sorted(by: { $0.created_at > $1.created_at })) { message in
                        MessageBubble(message: message, onDelete: {
                            deleteMessage(message)
                        })
                    }
                }
            }
            .padding()
        }
    }
    
    private var composeSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: postMessage) {
                    if isPosting {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(newMessage.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                }
                .disabled(newMessage.isEmpty || isPosting)
            }
            .padding()
            .background(Color.white)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Messages Yet")
                .font(.headline)
            
            Text("Be the first to start the discussion!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
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
                loadMessages()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func loadMessages() {
        isLoading = true
        errorMessage = nil
        
        APIService.getTournamentMessages(tournamentId: tournamentId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let msgs):
                    messages = msgs
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func postMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isPosting = true
        
        let messageData = CreateMessageRequest(
            tournament_id: tournamentId,
            content: newMessage
        )
        
        APIService.postTournamentMessage(messageData: messageData) { result in
            DispatchQueue.main.async {
                isPosting = false
                switch result {
                case .success(let message):
                    messages.append(message)
                    newMessage = ""
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func deleteMessage(_ message: ForumMessage) {
        APIService.deleteMessage(messageId: message.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    messages.removeAll { $0.id == message.id }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ForumMessage
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation: Bool = false
    
    private var isCurrentUser: Bool {
        guard let userData = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(UserModel.self, from: userData) else {
            return false
        }
        return user._id == message.user_id
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(message.user_name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(message.user_name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if isCurrentUser {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(
                                title: Text("Delete Message"),
                                message: Text("Are you sure you want to delete this message?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    onDelete()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var formattedTime: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: message.created_at) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return ""
    }
}

struct TournamentForumView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TournamentForumView(tournamentId: "sample-id")
        }
    }
}
