import SwiftUI

struct SignUpView: View {
    @ObservedObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSigningUp = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    // Validation state
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var doPasswordsMatch = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign up to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Sign up form
                VStack(spacing: 20) {
                    // Email field
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
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(10)
                            .onChange(of: password) {
                                isPasswordValid = password.count >= 6
                                doPasswordsMatch = password == confirmPassword || confirmPassword.isEmpty
                            }
                        
                        if !isPasswordValid && !password.isEmpty {
                            Text("Password must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm Password field
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(10)
                            .onChange(of: confirmPassword) {
                                doPasswordsMatch = password == confirmPassword
                            }
                        
                        if !doPasswordsMatch && !confirmPassword.isEmpty {
                            Text("Passwords don't match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    
                    // Sign up button
                    Button {
                        signUp()
                    } label: {
                        if isSigningUp {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isSigningUp || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                }
                .padding(.horizontal, 30)
                
                // Already have an account button
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Log In")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.bottom, 50)
        }
        .alert("Account Created", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your account has been created successfully. You can now log in.")
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        return isEmailValid && isPasswordValid && doPasswordsMatch && 
               !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func signUp() {
        guard isFormValid else { return }
        
        isSigningUp = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signUp(email: email, password: password)
                await MainActor.run {
                    isSigningUp = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    if let authError = error as? AuthError {
                        errorMessage = authError.localizedDescription
                    } else {
                        errorMessage = "Failed to create account. Please try again."
                    }
                    isSigningUp = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SignUpView(authService: AuthService.shared)
    }
} 