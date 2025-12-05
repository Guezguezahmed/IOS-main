import SwiftUI

struct ForgotPasswordUIView: View {
    // MARK: - State
    @State private var currentStep: Int = 1
    
    // Step 1
    @State private var email: String = ""
    
    // Step 2
    @State private var verificationCode: String = ""
    
    // Step 3
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    // Step 1: retour vers login
    @Environment(\.presentationMode) var presentationMode
    
    // Loading & Alert
    @State private var isLoading: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                // MARK: - Bouton Back
                Button(action: {
                    if currentStep == 1 {
                        // Retour au LoginView
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        currentStep -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text(currentStep == 1 ? "Retour" : "Back")
                    }
                    .foregroundColor(.green)
                }
                Spacer()
            }
            
            Text("Forgot Password")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top, 20)
            
            // 🔹 Petit texte global (instruction selon étape)
            Text(instructionForCurrentStep)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Step Content
            switch currentStep {
            case 1:
                step1View
            case 2:
                step2View
            case 3:
                step3View
            default:
                EmptyView()
            }
            
            Spacer()
        }
        .padding()
        .disabled(isLoading)
        .overlay(
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(1.5)
                }
            }
        )
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                // Si on est à l'étape 3 et le mot de passe est réinitialisé, retourner au login
                if currentStep == 3 && alertMessage.contains("réinitialisé") {
                    presentationMode.wrappedValue.dismiss()
                }
            }))
        }
    }
    
    // MARK: - Instructions dynamiques
    var instructionForCurrentStep: String {
        switch currentStep {
        case 1:
            return "Étape 1 : Entrez votre email pour recevoir un code de récupération."
        case 2:
            return "Étape 2 : Vérifiez votre boîte email et saisissez le code envoyé."
        case 3:
            return "Étape 3 : Choisissez un nouveau mot de passe sécurisé."
        default:
            return ""
        }
    }
    
    // MARK: - Step 1: Saisir email
    var step1View: some View {
        VStack(spacing: 20) {
            Text("Veuillez entrer l'adresse email associée à votre compte.")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            TextField("Entrez votre email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            
            Button(action: {
                requestResetCode()
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(12)
            }
            .disabled(email.isEmpty)
        }
    }
    
    // MARK: - Step 2: Saisir code
    var step2View: some View {
        VStack(spacing: 20) {
            Text("Un code a été envoyé à votre email.")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            Text("Veuillez entrer ce code pour continuer.")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            TextField("Code de vérification", text: $verificationCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            
            Button(action: {
                verifyResetCode()
            }) {
                Text("Valider le code")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(verificationCode.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(12)
            }
            .disabled(verificationCode.isEmpty)
        }
    }
    
    // MARK: - Step 3: Nouveau mot de passe
    var step3View: some View {
        VStack(spacing: 20) {
            Text("Choisissez un mot de passe contenant au moins 6 caractères.")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            SecureField("Nouveau mot de passe", text: $newPassword)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            
            SecureField("Confirmer le mot de passe", text: $confirmPassword)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            
            Button(action: {
                resetPassword()
            }) {
                Text("Réinitialiser")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((newPassword.isEmpty || confirmPassword.isEmpty) ? Color.gray : Color.green)
                    .cornerRadius(12)
            }
            .disabled(newPassword.isEmpty || confirmPassword.isEmpty)
        }
    }
    
    // MARK: - API Calls
    func requestResetCode() {
        isLoading = true
        APIService.forgotPassword(email: email) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    alertMessage = response.message ?? "Code envoyé"
                    showAlert = true
                    currentStep = 2
                case .failure(let error):
                    alertMessage = (error as? APIError)?.message ?? error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    func verifyResetCode() {
        isLoading = true
        APIService.verifyResetCode(email: email, code: verificationCode) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    alertMessage = response.message ?? "Code valide"
                    showAlert = true
                    currentStep = 3
                case .failure(let error):
                    alertMessage = (error as? APIError)?.message ?? error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    func resetPassword() {
        guard newPassword == confirmPassword else {
            alertMessage = "Les mots de passe ne correspondent pas"
            showAlert = true
            return
        }
        isLoading = true
        APIService.resetPassword(email: email, code: verificationCode, newPassword: newPassword, confirmPassword: confirmPassword) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    alertMessage = response.message ?? "Mot de passe réinitialisé"
                    showAlert = true
                case .failure(let error):
                    alertMessage = (error as? APIError)?.message ?? error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

struct ForgotPasswordUIView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordUIView()
    }
}
