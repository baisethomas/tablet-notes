import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    // Validation state
    @State private var isEmailValid = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Reset Password")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(10)
                        .onChange(of: email) {
                            isEmailValid = isValidEmail(email)
                        }
                    
                    if !isEmailValid && !email.isEmpty {
                        Text("Please enter a valid email address")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Button {
                    resetPassword()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isSubmitting || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 30)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Reset Link Sent", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("If an account exists with this email, you will receive instructions to reset your password.")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        return isEmailValid && !email.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func resetPassword() {
        guard isFormValid else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.resetPassword(email: email)
                await MainActor.run {
                    isSubmitting = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    if let authError = error as? AuthError {
                        errorMessage = authError.localizedDescription
                    } else {
                        errorMessage = "Failed to send reset link. Please try again."
                    }
                    isSubmitting = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ForgotPasswordView(authService: AuthService.shared)
} 