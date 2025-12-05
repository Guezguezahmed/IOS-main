import SwiftUI
import Foundation
import Combine

// MARK: - 1. View Model

class AddTournamentViewModel: ObservableObject {
    let didCreateCoupe = PassthroughSubject<Void, Never>()

    @Published var name: String = ""
    @Published var tournamentName: String = ""
    @Published var stadium: String = ""
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var maxParticipants: Int = 16
    @Published var entryFee: String = ""
    @Published var prizePool: String = ""
    
    @Published var selectedCategory: CoupeCategorie = .SENIOR
    @Published var selectedType: CoupeType = .TOURNAMENT
    
    @Published var availableReferees: [UserModel] = []
    @Published var selectedReferees: [UserModel] = []
    
    @Published var availableStadiums: [Terrain] = []
    @Published var selectedStadium: Terrain? = nil
    
    @Published var isLoading = false
    @Published var submissionResult: String?
    @Published var isSuccess = false
    
    var authToken: String = UserDefaults.standard.string(forKey: "userToken") ?? "MOCK_TOKEN"

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    func resetFields() {
        name = ""
        tournamentName = ""
        stadium = ""
        
        let now = Date()
        date = now
        time = now
        endDate = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        
        maxParticipants = 16
        entryFee = ""
        prizePool = ""
        
        selectedCategory = .SENIOR
        selectedType = .TOURNAMENT
        selectedReferees = []
        
        isSuccess = false
        submissionResult = nil
    }
    
    func fetchMyReferees() {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let currentUser = try? JSONDecoder().decode(UserModel.self, from: data) else { return }
        
        APIService.getArbitresByAcademie(idAcademie: currentUser._id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let referees):
                    self?.availableReferees = referees
                case .failure(let error):
                    print("Error fetching referees: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchMyStadiums() {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let currentUser = try? JSONDecoder().decode(UserModel.self, from: data) else { return }
        
        APIService.getAllStadiums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let allStadiums):
                    print("DEBUG: Current user ID: \(currentUser._id)")
                    print("DEBUG: Total stadiums fetched: \(allStadiums.count)")
                    
                    // Filter: Only show stadiums owned by current user
                    let userStadiums = allStadiums.filter { $0.id_academie == currentUser._id }
                    print("DEBUG: User's stadiums: \(userStadiums.count)")
                    
                    self?.availableStadiums = userStadiums
                    
                case .failure(let error):
                    print("Error fetching stadiums: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addReferee(_ referee: UserModel) {
        if !selectedReferees.contains(where: { $0._id == referee._id }) {
            selectedReferees.append(referee)
        }
    }
    
    func removeReferee(referee: UserModel) {
        selectedReferees.removeAll(where: { $0._id == referee._id })
    }
    
    func createCoupe() {
        guard !authToken.isEmpty else {
            submissionResult = "Authentication token missing. Please log in as an OWNER."
            isSuccess = false
            return
        }
        
        isLoading = true
        submissionResult = nil
        isSuccess = false
        
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        startComponents.hour = timeComponents.hour
        startComponents.minute = timeComponents.minute
        let finalStartDate = calendar.date(from: startComponents) ?? Date()

        let coupeDto = CreateCoupeDto(
            nom: name,
            participants: [],
            date_debut: finalStartDate,
            date_fin: endDate,
            tournamentName: tournamentName,
            stadium: selectedStadium?.name ?? stadium,
            date: dateFormatter.string(from: date),
            time: timeFormatter.string(from: time),
            maxParticipants: maxParticipants,
            entryFee: Int(entryFee),
            prizePool: Int(prizePool),
            referee: selectedReferees.map { $0._id },
            categorie: selectedCategory.rawValue,
            type: selectedType.rawValue
        )
        
        APIService.createCoupe(coupeData: coupeDto, token: authToken) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(_):
                    self?.resetFields()
                    self?.didCreateCoupe.send()
                case .failure(let error):
                    self?.submissionResult = "Creation Failed: \(error.localizedDescription)"
                    self?.isSuccess = false
                }
            }
        }
    }
}

// MARK: - 2. Main View

struct AddTournement: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AddTournamentViewModel()
    @State private var showSuccessToast = false
    @State private var showRefereeSheet = false
    
    // ⭐️ NEW: Preselected type from ChooseTournamentView
    let preselectedType: CoupeType?
    
    init(preselectedType: CoupeType? = nil) {
        self.preselectedType = preselectedType
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // GROUP 1: Header + Basic Fields (9 views)
                        Group {
                            // Tournament Details Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.selectedType == .LEAGUE ? "League Details" : "Tournament Details")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Fill in the information below")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Tournament Name
                            ModernTextField(
                                icon: "star.fill",
                                placeholder: "e.g., Champions League 2024",
                                text: $viewModel.tournamentName
                            )
                            .padding(.horizontal)
                            
                            // Competition Name
                            ModernTextField(
                                icon: "doc.text.fill",
                                placeholder: "Competition Name",
                                text: $viewModel.name
                            )
                            .padding(.horizontal)
                            
                            // Stadium Dropdown
                            ModernMenuField(
                                icon: "building.2.fill",
                                title: viewModel.selectedStadium?.name ?? "Select a stadium...",
                                isPlaceholder: viewModel.selectedStadium == nil
                            ) {
                                // Stadium selection handled by Menu
                            }
                            .padding(.horizontal)
                            .overlay(
                                Menu {
                                    if viewModel.availableStadiums.isEmpty {
                                        Text("No stadiums available")
                                            .foregroundColor(.secondary)
                                    } else {
                                        ForEach(viewModel.availableStadiums, id: \._id) { stadium in
                                            Button(action: {
                                                viewModel.selectedStadium = stadium
                                            }) {
                                                Text(stadium.name)
                                            }
                                        }
                                    }
                                } label: {
                                    Color.clear
                                }
                            )
                            
                            // Referee
                            ModernMenuField(
                                icon: "person.fill",
                                title: selectedRefereeText,
                                isPlaceholder: viewModel.selectedReferees.isEmpty
                            ) {
                                showRefereeSheet = true
                            }
                            .padding(.horizontal)
                            
                            // Selected Referees
                            if !viewModel.selectedReferees.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.selectedReferees, id: \._id) { referee in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("\(referee.prenom) \(referee.nom)")
                                                .font(.system(size: 14))
                                            Spacer()
                                            Button {
                                                viewModel.removeReferee(referee: referee)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        // GROUP 2: Pickers + Dates (6 views)
                        Group {
                            // Category Picker
                            ModernPickerField(
                                title: "Categorie",
                                selection: $viewModel.selectedCategory
                            )
                            .padding(.horizontal)
                            
                            // Type Picker - Locked if preselected
                            ModernPickerField(
                                title: "Type",
                                selection: $viewModel.selectedType,
                                isDisabled: preselectedType != nil
                            )
                            .padding(.horizontal)
                            
                            // Date and Time Row
                            HStack(spacing: 12) {
                                ModernDateField(
                                    icon: "calendar",
                                    date: $viewModel.date,
                                    displayComponents: .date
                                )
                                
                                ModernDateField(
                                    icon: "clock",
                                    date: $viewModel.time,
                                    displayComponents: .hourAndMinute
                                )
                            }
                            .padding(.horizontal)
                            
                            // End Date
                            ModernDateField(
                                icon: "calendar",
                                label: "End Date",
                                date: $viewModel.endDate,
                                displayComponents: .date
                            )
                            .padding(.horizontal)
                        }
                        
                        // GROUP 3: Participants + Fees + Buttons (6 views)
                        Group {
                            // Max Participants
                            ModernStepperField(
                                icon: "person.2.fill",
                                label: "Max Participants",
                                value: $viewModel.maxParticipants
                            )
                            .padding(.horizontal)
                            
                            // Entry Fee
                            ModernTextField(
                                icon: "dollarsign.circle",
                                placeholder: "e.g., $25",
                                text: $viewModel.entryFee,
                                keyboardType: .numberPad
                            )
                            .padding(.horizontal)
                            
                            // Prize Pool
                            ModernTextField(
                                icon: "star.fill",
                                placeholder: "e.g., $500",
                                text: $viewModel.prizePool,
                                keyboardType: .numberPad
                            )
                            .padding(.horizontal)
                            
                            // Error Message
                            if let result = viewModel.submissionResult, !viewModel.isSuccess {
                                Text(result)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                            
                            // Buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Back")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(UIColor.systemGray6))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    viewModel.createCoupe()
                                }) {
                                    HStack {
                                        if viewModel.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text("Create Tournament")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.4, green: 0.7, blue: 0.6))
                                    .cornerRadius(12)
                                }
                                .disabled(viewModel.isLoading || viewModel.name.isEmpty || viewModel.tournamentName.isEmpty)
                                .opacity((viewModel.isLoading || viewModel.name.isEmpty || viewModel.tournamentName.isEmpty) ? 0.6 : 1.0)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchMyReferees()
            viewModel.fetchMyStadiums()
            // ⭐️ NEW: Set preselected type if provided
            if let preselectedType = preselectedType {
                viewModel.selectedType = preselectedType
            }
        }
        .onReceive(viewModel.didCreateCoupe) { _ in
            withAnimation {
                showSuccessToast = true
            }
        }
        .toast(isShowing: $showSuccessToast, message: "Tournament Created!", image: "checkmark.circle.fill")
        .sheet(isPresented: $showRefereeSheet) {
            RefereeSelectionSheet(
                availableReferees: viewModel.availableReferees,
                onSelect: { referee in
                    viewModel.addReferee(referee)
                    showRefereeSheet = false
                }
            )
        }
    }
    
    var selectedRefereeText: String {
        if viewModel.selectedReferees.isEmpty {
            return "Select a referee..."
        } else {
            return "\(viewModel.selectedReferees.count) referee(s) selected"
        }
    }
}

// MARK: - 3. Modern Components

struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .keyboardType(keyboardType)
        }
        .padding()
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(12)
    }
}

struct ModernMenuField: View {
    let icon: String
    let title: String
    var isPlaceholder: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isPlaceholder ? .secondary : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(red: 0.9, green: 0.95, blue: 0.93))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernPickerField<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T
    var isDisabled: Bool = false // ⭐️ NEW: Support for disabled state
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button(action: {
                        if !isDisabled {
                            selection = option
                        }
                    }) {
                        Text(option.rawValue.capitalized)
                    }
                }
            } label: {
                HStack {
                    Text(selection.rawValue.capitalized)
                        .font(.system(size: 16))
                        .foregroundColor(isDisabled ? .secondary : .primary)
                    Spacer()
                    Image(systemName: isDisabled ? "lock.fill" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(isDisabled ? Color(UIColor.systemGray6) : Color(red: 0.9, green: 0.95, blue: 0.93))
                .cornerRadius(12)
            }
            .disabled(isDisabled)
        }
    }
}

struct ModernDateField: View {
    let icon: String
    var label: String?
    @Binding var date: Date
    let displayComponents: DatePicker<Text>.Components
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = label {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                DatePicker("", selection: $date, displayedComponents: displayComponents)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(red: 0.9, green: 0.95, blue: 0.93))
            .cornerRadius(12)
        }
    }
}

struct ModernStepperField: View {
    let icon: String
    let label: String
    @Binding var value: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text("\(label): \(value)")
                .font(.system(size: 16))
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    if value > 4 {
                        value -= 4
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.6))
                        .font(.system(size: 24))
                }
                
                Button(action: {
                    if value < 64 {
                        value += 4
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.6))
                        .font(.system(size: 24))
                }
            }
        }
        .padding()
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(12)
    }
}

// MARK: - 4. Referee Selection Sheet

struct RefereeSelectionSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let availableReferees: [UserModel]
    let onSelect: (UserModel) -> Void
    
    var body: some View {
        NavigationView {
            List {
                if availableReferees.isEmpty {
                    Text("No referees available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(availableReferees, id: \._id) { referee in
                        Button(action: {
                            onSelect(referee)
                        }) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.6))
                                Text("\(referee.prenom) \(referee.nom)")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Select Referee")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - 5. Toast System

struct Toast: View {
    let message: String
    let image: String
    
    var body: some View {
        HStack {
            Image(systemName: image)
            Text(message)
        }
        .padding(12)
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(8)
        .shadow(radius: 5)
        .transition(.opacity)
        .zIndex(1)
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, image: String, duration: TimeInterval = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, image: image, duration: duration))
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let image: String
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isShowing {
                Toast(message: message, image: image)
                    .padding(.top, 50)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
    }
}
