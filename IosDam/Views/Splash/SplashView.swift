//
// SplashView.swift
// IosDam
//
// Splash screen with auth check

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var isLoggedIn = false
    
    var body: some View {
        ZStack {
            if isActive {
                if isLoggedIn {
                    HomeView()
                } else {
                    OnboardingView()
                }
            } else {
                Color.green.opacity(0.1).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image("splash_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Text("DAM")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Digital Academy Management")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .padding(.top, 20)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
        // ✅ Transition vers LoginView quand terminé
        .fullScreenCover(isPresented: $isActive) {
            FirstView()
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .previewDevice("iPhone 11") // choisis le modèle que tu veux
    }
}
