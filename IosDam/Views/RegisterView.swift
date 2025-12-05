import SwiftUI

struct RegisterView: View {
    // MARK: - Données
    @State private var nom = ""
    @State private var prenom = ""
    @State private var tel = ""
    @State private var email = ""
    @State private var age = Date()
    @State private var role = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var verificationCode = ""

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    @State private var currentStep = 1
    let roles = ["JOUEUR", "ARBITRE", "OWNER"]

    // MARK: - Champs touchés
    @State private var nomTouched = false
    @State private var prenomTouched = false
    @State private var telTouched = false
    @State private var emailTouched = false
    @State private var passwordTouched = false
    @State private var confirmPasswordTouched = false
    @State private var codeTouched = false

    // MARK: - Navigation
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                VStack {
                    // Step indicator + instructions + simple progress bar
                    VStack(spacing: 6) {
                        Text("Step \(currentStep) / 4")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 20)

                        Text(instructionForStep)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)

                        // Simple progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                Capsule()
                                    .fill(Color.green)
                                    .frame(width: progressWidth(total: geo.size.width), height: 6)
                                    .animation(.easeInOut, value: currentStep)
                            }
                        }
                        .frame(height: 12)
                        .padding(.horizontal)
                    }

                    Spacer()

                    // MARK: - Steps
                    switch currentStep {
                    case 1: step1
                    case 2: step2
                    case 3: step3
                    case 4: step4
                    default: EmptyView()
                    }

                    Spacer()

                    // MARK: - HStack des boutons
                    HStack {
                        if currentStep == 1 {
                            NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true)) {
                                Text("Login")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.green)
                            }
                        } else {
                            Button(action: { currentStep -= 1 }) {
                                Text("Back")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.black)
                            }
                        }

                        Spacer()

                        Button(currentStep < 4 ? "Next" : "Validate") {
                            handleNext()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()

                if isLoading {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView("Patientez...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Info"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        // Retour automatique au login si code valide
                        if alertMessage.contains("Code valide") || alertMessage.contains("vous pouvez maintenant vous connecter".lowercased()) || alertMessage.contains("Vous pouvez maintenant vous connecter") {
                            presentationMode.wrappedValue.dismiss()
                            clearFields()
                        }
                    })
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Step Instructions (français)
    var instructionForStep: String {
        switch currentStep {
        case 1:
            return "Veuillez entrer vos informations personnelles pour créer votre compte."
        case 2:
            return "Enregistrez votre numéro tunisien, votre date de naissance et choisissez votre rôle."
        case 3:
            return "Créez un mot de passe sécurisé (min 6 caractères) et confirmez-le."
        case 4:
            return "Un code de vérification a été envoyé à votre email. Veuillez l’entrer pour activer votre compte."
        default:
            return ""
        }
    }

    // MARK: - Progress bar width calc
    func progressWidth(total: CGFloat) -> CGFloat {
        let fraction = CGFloat(currentStep) / 4.0
        return max(12, total * fraction)
    }

    // MARK: - Step 1: Nom, Prénom, Email
    var step1: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading) {
                TextField("Nom", text: $nom)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { nomTouched = true }

                if nomTouched && nom.isEmpty {
                    Text("⚠️ Nom ne doit pas être vide").foregroundColor(.red).font(.caption).padding(.leading, 10)
                }
            }

            VStack(alignment: .leading) {
                TextField("Prénom", text: $prenom)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { prenomTouched = true }

                if prenomTouched && prenom.isEmpty {
                    Text("⚠️ Prénom ne doit pas être vide").foregroundColor(.red).font(.caption).padding(.leading, 10)
                }
            }

            VStack(alignment: .leading) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { emailTouched = true }

                if emailTouched {
                    if email.isEmpty {
                        Text("⚠️ Email ne doit pas être vide").foregroundColor(.red).font(.caption).padding(.leading, 10)
                    } else if !isValidEmail(email) {
                        Text("⚠️ Format email invalide").foregroundColor(.red).font(.caption).padding(.leading, 10)
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Téléphone, Age, Rôle
    var step2: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading) {
                TextField("Téléphone", text: $tel)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { telTouched = true }

                if telTouched {
                    if tel.isEmpty {
                        Text("⚠️ Téléphone ne doit pas être vide").foregroundColor(.red).font(.caption).padding(.leading, 10)
                    } else if !isValidTunisianPhone(tel) {
                        Text("⚠️ Numéro tunisien invalide").foregroundColor(.red).font(.caption).padding(.leading, 10)
                    }
                }
            }

            DatePicker("Date de naissance", selection: $age, displayedComponents: .date)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Menu {
                    ForEach(roles, id: \.self) { r in
                        Button(r) { role = r }
                    }
                } label: {
                    HStack {
                        Text(role.isEmpty ? "Choisir un rôle" : role)
                            .foregroundColor(role.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                if role.isEmpty {
                    Text("⚠️ Choisir un rôle").foregroundColor(.red).font(.caption).padding(.leading, 10)
                }
            }
        }
    }

    // MARK: - Step 3: Password
    var step3: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading) {
                SecureField("Mot de passe", text: $password)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { passwordTouched = true }

                if passwordTouched && password.count < 6 {
                    Text("⚠️ Minimum 6 caractères").foregroundColor(.red).font(.caption).padding(.leading, 10)
                }
            }

            VStack(alignment: .leading) {
                SecureField("Confirmer le mot de passe", text: $confirmPassword)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { confirmPasswordTouched = true }

                if confirmPasswordTouched && confirmPassword != password {
                    Text("⚠️ Les mots de passe ne correspondent pas").foregroundColor(.red).font(.caption).padding(.leading, 10)
                }
            }
        }
    }

    // MARK: - Step 4: Code de vérification
    var step4: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading) {
                TextField("Entrez le code de vérification", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { codeTouched = true }

                if codeTouched && verificationCode.count != 6 {
                    Text("⚠️ Code invalide (6 chiffres)").foregroundColor(.red).font(.caption).padding(.leading, 10)
                }
            }
        }
    }

    // MARK: - Next / Register Logic
    func handleNext() {
        switch currentStep {
        case 1:
            if nom.isEmpty || prenom.isEmpty || email.isEmpty || !isValidEmail(email) {
                showAlert = true; alertMessage = "Veuillez remplir correctement tous les champs."
            } else { currentStep = 2 }
        case 2:
            if tel.isEmpty || role.isEmpty || !isValidTunisianPhone(tel) {
                showAlert = true; alertMessage = "Veuillez remplir correctement tous les champs."
            } else { currentStep = 3 }
        case 3:
            if password.isEmpty || confirmPassword.isEmpty || password != confirmPassword || password.count < 6 {
                showAlert = true; alertMessage = "Veuillez remplir correctement tous les champs."
            } else { registerAction() }
        case 4:
            if verificationCode.count != 6 {
                showAlert = true; alertMessage = "Code invalide !"
            } else { verifyCodeAction() }
        default: break
        }
    }

    // MARK: - Register Action
    func registerAction() {
        isLoading = true
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let ageString = formatter.string(from: age)

        APIService.registerUser(nom: nom, prenom: prenom, tel: tel, email: email, age: ageString, role: role, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    currentStep = 4 // passer à la vérification
                case .failure(let error):
                    alertMessage = "❌ Registration failed: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    // MARK: - Verify Code Action
    func verifyCodeAction() {
        isLoading = true
        APIService.verifyCode(email: email, code: verificationCode) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    alertMessage = "✅ Code valide ! Vous pouvez maintenant vous connecter."
                    showAlert = true
                case .failure(let error):
                    alertMessage = "❌ Code incorrect ou expiré : \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    // MARK: - Helpers
    func clearFields() {
        nom = ""; prenom = ""; tel = ""; email = ""; role = ""; password = ""; confirmPassword = ""; verificationCode = ""
        nomTouched = false; prenomTouched = false; emailTouched = false; telTouched = false
        passwordTouched = false; confirmPasswordTouched = false; codeTouched = false
        currentStep = 1
    }

    func isValidEmail(_ email: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: email)
    }

    func isValidTunisianPhone(_ phone: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", "^[2593][0-9]{7}$").evaluate(with: phone)
    }
}
    
