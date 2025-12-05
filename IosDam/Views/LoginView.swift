import SwiftUI

enum ActiveScreen: Identifiable {
    case home, register, forgotPassword
    
    var id: Int { hashValue }
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var rememberMe: Bool = UserDefaults.standard.bool(forKey: "rememberMe")
    
    @State private var activeScreen: ActiveScreen? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {

                    // Logo proche du haut
                      Image("LogoApp (1)")
                          .resizable()
                          .scaledToFit()
                          .frame(width: 200, height: 200)
                          .padding(.top, 20)
                    
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    // MARK: - Email Field
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        if !email.isEmpty && !isValidEmail(email) {
                            Text("⚠️ Email invalide")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.leading, 30)
                        }
                    }
                    
                    // MARK: - Password Field
                    VStack(alignment: .leading, spacing: 5) {
                        ZStack {
                            HStack {
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                        .autocapitalization(.none)
                                        .padding()
                                } else {
                                    SecureField("Password", text: $password)
                                        .autocapitalization(.none)
                                        .padding()
                                }
                            }
                            HStack {
                                Spacer()
                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 16)
                                }
                            }
                        }
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        if !password.isEmpty && password.count < 6 {
                            Text("⚠️ Mot de passe trop court")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.leading, 30)
                        }
                    }
                    
                    // MARK: - Remember Me
                    Toggle(isOn: $rememberMe) {
                        Text("Remember Me")
                            .foregroundColor(.green)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .padding(.horizontal)
                    
                    // MARK: - Forgot Password
                    Button(action: { activeScreen = .forgotPassword }) {
                        Text("Forgot Password?")
                            .foregroundColor(.green)
                            .font(.footnote)
                            .underline()
                    }
                    .padding(.top, 5)
                    .padding(.trailing, 24)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // MARK: - Login Button
                    Button(action: loginAction) {
                        HStack {
                            Spacer()
                            Text("Login")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1)
                    
                    Spacer()
                    
                    // MARK: - Register Link
                    HStack(spacing: 4) {
                        Text("New member ?")
                        Button("Register now") { activeScreen = .register }
                            .foregroundColor(.green)
                    }
                    .padding(.bottom, 30)
                }
                
                // MARK: - Loader
                if isLoading {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView("Connexion en cours...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(item: $activeScreen) { screen in
                switch screen {
                case .home:
                    HomeView()
                case .register:
                    RegisterView()
                case .forgotPassword:
                    ForgotPasswordUIView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Actions
    func loginAction() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Veuillez remplir tous les champs."
            showAlert = true
            return
        }
        guard isValidEmail(email) else {
            alertMessage = "Email invalide."
            showAlert = true
            return
        }
        
        isLoading = true
        
        APIService.loginUser(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    // Stocker le token
                    if let token = response.access_token {
                        UserDefaults.standard.set(token, forKey: "userToken")
                        UserDefaults.standard.set(rememberMe, forKey: "rememberMe")
                    }

                    // Stocker le user complet
                    if let user = response.user, let encoded = try? JSONEncoder().encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "currentUser")
                        
                        // ✅ Store user role immediately for AppStorage
                        UserDefaults.standard.set(user.role, forKey: "user_role")
                        
                        // ✅ Store user name for AppStorage
                        UserDefaults.standard.set(user.prenom, forKey: "user_prenom")
                        UserDefaults.standard.set(user.nom, forKey: "user_nom")
                        
                        print("🎯 User enregistré avec succès")
                    }

                    activeScreen = .home
                case .failure(let error):
                    alertMessage = "❌ Login failed: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    
    // MARK: - Helpers
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
