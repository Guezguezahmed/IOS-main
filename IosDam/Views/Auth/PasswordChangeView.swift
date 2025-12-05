//
// PasswordChangedView.swift
// IosDam
//
// Password change success confirmation

import SwiftUI

struct PasswordChangedView: View {
    @State private var navigateToLogin = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Success Icon with animation
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                }
                
                // Success Message
                VStack(spacing: 10) {
                    Text("Password Changed!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Your password has been successfully reset")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Back to Login Button
                Button(action: {
                    navigateToLogin = true
                }) {
                    HStack {
                        Spacer()
                        Text("Back to Login")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $navigateToLogin) {
            LoginView()
        }
        .onAppear {
            // Auto-navigate after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                navigateToLogin = true
            }
        }
    }
}

//MARK: - Preview

struct PasswordChangedView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordChangedView()
    }
}
