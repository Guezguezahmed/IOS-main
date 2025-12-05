//
// VerificationView.swift
// IosDam
//
// OTP email verification screen

import SwiftUI

struct VerificationView: View {
    let email: String
    @State private var otpDigits: [String] = ["", "", "", "", "", ""]
    @State private var activeIndex = 0
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    @State private var canResend = false
    @State private var countdown = 60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Verify Your Email")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("We sent a verification code to")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(email)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                }
                .padding(.bottom, 30)
                
                // OTP Input
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        OTPDigitField(
                            digit: $otpDigits[index],
                            isActive: activeIndex == index,
                            onTap: { activeIndex = index }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Countdown or Resend
                if canResend {
                    Button(action: resendCode) {
                        Text("Resend Code")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 20)
                } else {
                    Text("Resend code in \(countdown)s")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                        .onReceive(timer) { _ in
                            if countdown > 0 {
                                countdown -= 1
                            } else {
                                canResend = true
                            }
                        }
                }
                
                Spacer()
                
                // Verify Button
                Button(action: verifyCode) {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Verify")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(isOTPComplete ? Color.green : Color.gray.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
                .disabled(!isOTPComplete || isLoading)
                .padding(.bottom, 40)
            }
            
            if isLoading {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                ProgressView("Verifying...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
        .onChange(of: otpDigits) { _ in
            // Auto-advance to next field
            if activeIndex < 5 && !otpDigits[activeIndex].isEmpty {
                activeIndex += 1
            }
        }
    }
    
    var isOTPComplete: Bool {
        otpDigits.allSatisfy { !$0.isEmpty }
    }
    
    var otpCode: String {
        otpDigits.joined()
    }
    
    func verifyCode() {
        guard isOTPComplete else { return }
        
        isLoading = true
        
        APIService.verifyCode(email: email, code: otpCode) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let response):
                    // Store token and user
                    if let token = response.access_token {
                        UserDefaults.standard.set(token, forKey: "userToken")
                    }
                    if let user = response.user, let encoded = try? JSONEncoder().encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "currentUser")
                    }
                    
                    // Navigate to home
                    navigateToHome = true
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    func resendCode() {
        isLoading = true
        
        APIService.resendVerificationCode(email: email) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    alertMessage = "Verification code resent successfully!"
                    showAlert = true
                    countdown = 60
                    canResend = false
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - OTP Digit Field

struct OTPDigitField: View {
    @Binding var digit: String
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.05))
                )
                .frame(width: 50, height: 60)
            
            TextField("", text: $digit)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 50, height: 60)
                .onChange(of: digit) { newValue in
                    // Limit to 1 digit
                    if newValue.count > 1 {
                        digit = String(newValue.prefix(1))
                    }
                }
                .onTapGesture {
                    onTap()
                }
        }
    }
}

// MARK: - Preview

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView(email: "test@example.com")
    }
}
