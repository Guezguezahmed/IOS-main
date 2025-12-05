//
// OnboardingView.swift
// IosDam
//
// Onboarding carousel with 3 welcome screens

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var navigateToLogin = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "first_page_illustration",
            title: "Welcome to DAM",
            description: "Manage your sports academy, teams, and tournaments all in one place"
        ),
        OnboardingPage(
            imageName: "second_page_illustration",
            title: "Build Your Team",
            description: "Create and manage teams, track statistics, and organize your roster"
        ),
        OnboardingPage(
            imageName: "third_page_illustration",
            title: "Compete & Win",
            description: "Join tournaments, track matches, and climb the leaderboard"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        Text("Skip")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 20)
                
                // Page view
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Get Started or Next button
                if currentPage == pages.count - 1 {
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Get Started")
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
                    .padding(.bottom, 40)
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Next")
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
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $navigateToLogin) {
            LoginView()
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Illustration
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .padding(.horizontal, 40)
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text(page.description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
