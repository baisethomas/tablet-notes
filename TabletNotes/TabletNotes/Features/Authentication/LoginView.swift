import SwiftUI

struct LoginView: View {
    @ObservedObject var authService: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var errorMessage: String?
    
    // Validation state
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo and welcome text
                        VStack(spacing: 20) {
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                            
                            Text("TabletNotes")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Your sermon notes companion")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 50)
                        
                        // Login form
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
                                    .textContentType(.password)
                                    .padding()
                                    .background(Color(uiColor: .systemGray6))
                                    .cornerRadius(10)
                                    .onChange(of: password) {
                                        isPasswordValid = password.count >= 6
                                    }
                                
                                if !isPasswordValid && !password.isEmpty {
                                    Text("Password must be at least 6 characters")
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
                            
                            // Login button
                            Button {
                                login()
                            } label: {
                                if isLoggingIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Log In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(isLoggingIn || !isFormValid)
                            .opacity(isFormValid ? 1.0 : 0.6)
                            
                            // Forgot password
                            Button {
                                showForgotPassword = true
                            } label: {
                                Text("Forgot Password?")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 5)
                            
                            // Sign up link
                            HStack {
                                Text("Don't have an account?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button {
                                    showSignUp = true
                                } label: {
                                    Text("Sign Up")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authService: authService)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(authService: authService)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        return isEmailValid && isPasswordValid && !email.isEmpty && !password.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func login() {
        guard isFormValid else { return }
        
        isLoggingIn = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                isLoggingIn = false
            } catch {
                await MainActor.run {
                    if let authError = error as? AuthError {
                        errorMessage = authError.localizedDescription
                    } else {
                        errorMessage = "Failed to log in. Please try again."
                    }
                    isLoggingIn = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView(authService: AuthService.shared)
} 