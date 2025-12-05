import SwiftUI

struct SocialView: View {
    @State private var currentUser: UserModel? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Profil Utilisateur")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // MARK: - Image Profil
                if let currentUser = currentUser,
                   let picture = currentUser.picture,
                   !picture.isEmpty,
                   let imageData = Data(base64Encoded: picture),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                } else {
                    // Use SF Symbol instead of missing image
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 120, height: 120)
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color.green)
                    }
                    .shadow(radius: 5)
                }

                // MARK: - Infos utilisateur
                VStack(alignment: .leading, spacing: 15) {
                    infoRow(title: "Prénom", value: currentUser?.prenom ?? "-")
                    infoRow(title: "Nom", value: currentUser?.nom ?? "-")
                    infoRow(title: "Email", value: currentUser?.email ?? "-")
                    infoRow(title: "Téléphone", value: "\(currentUser?.tel ?? 0)")
                    infoRow(title: "Rôle", value: currentUser?.role ?? "-")
                    infoRow(title: "Email vérifié", value: (currentUser?.isVerified ?? false) ? "✅ Oui" : "❌ Non")
                    infoRow(title: "ID", value: currentUser?._id ?? "-")
                    infoRow(title: "Age", value: currentUser?.age ?? "-")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.green.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
        .onAppear(perform: loadUser)
    }
    
    // MARK: - Fonction pour afficher une ligne
    @ViewBuilder
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Charger user depuis UserDefaults
    func loadUser() {
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserModel.self, from: data) {
            currentUser = user
        }
    }
}
