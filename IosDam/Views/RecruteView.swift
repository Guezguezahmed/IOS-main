import SwiftUI
import Foundation // Needed for DispatchQueue

// Assuming UserModel and APIService are defined elsewhere

struct RecruteView: View {
    @Environment(\.presentationMode) var presentationMode

    let idAcademie: String
    
    @State private var searchText = ""
    @State private var arbitres: [UserModel] = []
    @State private var isLoading = false
    @State private var arbitreStatus: [String: Bool] = [:] // idArbitre -> exists
    
    // ❌ OLD: @State private var searchTask: Task<Void, Never>? = nil
    // ✅ FIX: Use DispatchQueue work item for debounce in Xcode 12.3
    @State private var searchWorkItem: DispatchWorkItem? = nil

    var body: some View {
        NavigationView {
            VStack {
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher un arbitre...", text: $searchText)
                        .onChange(of: searchText) { newValue in
                            // ✅ FIX: Debounce using DispatchWorkItem
                            self.searchWorkItem?.cancel()
                            
                            guard !newValue.isEmpty else {
                                self.arbitres = []
                                return
                            }
                            
                            let workItem = DispatchWorkItem {
                                self.performSearch(query: newValue)
                            }
                            self.searchWorkItem = workItem
                            
                            // Schedule the search to run after 0.5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                if isLoading {
                    ProgressView()
                        .padding()
                }
                
                // Results List
                List(arbitres, id: \._id) { arbitre in
                    HStack {
                        // Profile Picture logic... (unchanged)
                        if let picture = arbitre.picture, !picture.isEmpty,
                            let imageData = Data(base64Encoded: picture),
                            let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(arbitre.prenom) \(arbitre.nom)")
                                .font(.headline)
                            Text(arbitre.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Action Button / Status Display (unchanged)
                        if !idAcademie.isEmpty {
                            if let exists = arbitreStatus[arbitre._id], exists {
                                Text("Déjà membre")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            } else {
                                Button(action: {
                                    addArbitre(arbitre: arbitre)
                                }) {
                                    Text("Ajouter")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .background(Color.green)
                                        .cornerRadius( 8 )
                                }
                            }
                        } else {
                            // Displayed if idAcademie is an empty string
                            Text("Reconnectez-vous")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Recrutement", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Retour")
                }
                .foregroundColor(.green)
            })
            .onAppear {
                checkArbitreStatuses()
            }
        }
    }
    
    // MARK: - API Calls (unchanged logic)
    
    // ✅ NEW FUNCTION: Vérifie le statut de chaque arbitre
    func checkArbitreStatuses() {
        guard !arbitres.isEmpty && !idAcademie.isEmpty else { return }
        
        for arbitre in arbitres {
            APIService.checkArbitreExists(idAcademie: self.idAcademie, idArbitre: arbitre._id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let exists):
                        self.arbitreStatus[arbitre._id] = exists
                    case .failure(let error):
                        print("Error checking arbitre status: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func performSearch(query: String) {
        // Guard against empty query is handled in onChange now, but kept for safety
        guard !query.isEmpty else {
            arbitres = []
            return
        }
        
        isLoading = true
        APIService.searchArbitres(query: query) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let users):
                    self.arbitres = users
                    // ✅ CALL NEW FUNCTION: Vérifie le statut des nouveaux résultats
                    self.checkArbitreStatuses()
                case .failure(let error):
                    print("Search error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addArbitre(arbitre: UserModel) {
        // ✅ FIX: idAcademie est utilisé directement
        APIService.addArbitreToAcademie(idAcademie: self.idAcademie, idArbitre: arbitre._id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Mark as added successfully
                    arbitreStatus[arbitre._id] = true
                case .failure(let error):
                    print("Add arbitre error: \(error.localizedDescription)")
                }
            }
        }
    }
}
