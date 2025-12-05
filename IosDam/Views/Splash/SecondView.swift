//  SecondView.swift
//  IosDam
//
//  Created by Wassim Abdelli on 7/11/2025.
//

import SwiftUI

struct SecondView: View {
    var body: some View {
      
            ZStack {
                Color.white.ignoresSafeArea()
            
                VStack(spacing: 0) {
                    // Skip button en haut à droite
                    HStack {
                        Spacer()
                        NavigationLink(destination: LoginView()
                            .navigationBarBackButtonHidden(true)) {
                            Text("Skip")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 6)
                        }
                        .padding(.trailing, 16)
                    }
                    .frame(height: 44)
                    
                    Spacer()
                    
                    // Illustration image
                    Image("second_page_illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Contenu texte
                    VStack(spacing: 8) {
                        Text("Reach the unknown spot")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Master the Tournament")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 24)
                    
                    // Indicateurs de page
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                        Capsule()
                            .fill(Color.green)
                            .frame(width: 36, height: 6)
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                    .padding(.top, 24)
                    
                    // Bouton suivant -> navigation vers ThirdView
                    HStack {
                        Spacer()
                        NavigationLink(destination: ThirdView()
                            .navigationBarBackButtonHidden(true)) {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black)
                                .clipShape(Circle())
                                .padding(.trailing, 20)
                                .padding(.top, 12)
                        }
                    }
                    .padding(.top, 6)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .navigationBarHidden(true)
        }
    }


struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView()
    }
}
