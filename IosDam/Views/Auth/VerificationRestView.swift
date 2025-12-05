//
// VerificationResetView.swift
// IosDam
//
// OTP verification for password reset flow

import SwiftUI

struct VerificationResetView: View {
    let email: String
    @State private var otpDigits: [String] = ["", "", "", "", "", ""]
    @State private var activeIndex = 0
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToSetPassword = false
    @State private var verifiedCode = ""
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
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Verify Reset Code")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Enter the code sent to")
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
                            Text("Verify Code")
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $navigateToSetPassword) {
            SetNewPasswordView(email: email, verificationCode: verifiedCode)
        }
        .onChange(of: otpDigits) { _ in
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
        
        APIService.verifyResetCode(email: email, code: otpCode) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    // Code verified, navigate to set new password
                    verifiedCode = otpCode
                    navigateToSetPassword = true
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                    // Clear OTP fields on error
                    otpDigits = ["", "", "", "", "", ""]
                    activeIndex = 0
                }
            }
        }
    }
    
    func resendCode() {
        isLoading = true
        
        APIService.forgotPassword(email: email) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    alertMessage = "Reset code resent successfully!"
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

// MARK: - Preview

struct VerificationResetView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationResetView(email: "test@example.com")
    }
}
