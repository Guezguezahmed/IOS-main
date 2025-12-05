//
// SetNewPasswordView.swift
// IosDam
//
// Set new password after verification

import SwiftUI

struct SetNewPasswordView: View {
    let email: String
    let verificationCode: String
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToPasswordChanged = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Set New Password")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Create a strong password for your account")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 30)
                
                // New Password Field
                VStack(alignment: .leading, spacing: 5) {
                    ZStack {
                        HStack {
                            if showNewPassword {
                                TextField("New Password", text: $newPassword)
                                    .autocapitalization(.none)
                                    .padding()
                            } else {
                                SecureField("New Password", text: $newPassword)
                                    .autocapitalization(.none)
                                    .padding()
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: { showNewPassword.toggle() }) {
                                Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if !newPassword.isEmpty && newPassword.count < 6 {
                        Text("⚠️ Password must be at least 6 characters")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.leading, 30)
                    }
                }
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: 5) {
                    ZStack {
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .autocapitalization(.none)
                                    .padding()
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .autocapitalization(.none)
                                    .padding()
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if !confirmPassword.isEmpty && newPassword != confirmPassword {
                        Text("⚠️ Passwords do not match")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.leading, 30)
                    }
                }
                
                // Password Requirements
                VStack(alignment: .leading, spacing: 5) {
                    Text("Password must:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("• Be at least 6 characters long")
                        .font(.caption)
                        .foregroundColor(newPassword.count >= 6 ? .green : .gray)
                    Text("• Match in both fields")
                        .font(.caption)
                        .foregroundColor(newPassword == confirmPassword && !confirmPassword.isEmpty ? .green : .gray)
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                Spacer()
                
                // Reset Password Button
                Button(action: resetPassword) {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Reset Password")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(isValid ? Color.green : Color.gray.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
                .disabled(!isValid || isLoading)
                .padding(.bottom, 40)
            }
            
            if isLoading {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                ProgressView("Resetting password...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
        }
        .navigationBarHidden(false)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $navigateToPasswordChanged) {
            PasswordChangedView()
        }
    }
    
    var isValid: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }
    
    func resetPassword() {
        guard isValid else { return }
        
        isLoading = true
        
        APIService.resetPassword(email: email, code: verificationCode, newPassword: newPassword, confirmPassword: confirmPassword) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    // Password reset successful
                    navigateToPasswordChanged = true
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Preview

struct SetNewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        SetNewPasswordView(email: "test@example.com", verificationCode: "123456")
    }
}
