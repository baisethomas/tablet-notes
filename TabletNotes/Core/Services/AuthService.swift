import Foundation
import Supabase

/// Authentication errors that can occur during authentication operations
enum AuthError: LocalizedError {
    case signInFailed(String)
    case signUpFailed(String)
    case signOutFailed(String)
    case resetPasswordFailed(String)
    case sessionError(String)
    
    var errorDescription: String? {
        switch self {
        case .signInFailed(let message),
             .signUpFailed(let message),
             .signOutFailed(let message),
             .resetPasswordFailed(let message),
             .sessionError(let message):
            return message
        }
    }
}

/// Service responsible for handling authentication with Supabase
@MainActor
class AuthService: ObservableObject {
    /// Shared instance for singleton access
    static let shared = AuthService()
    
    /// The Supabase client instance
    let supabase: SupabaseClient
    
    /// Whether the user is currently authenticated
    @Published private(set) var isAuthenticated = false
    
    /// The currently authenticated user, if any
    @Published private(set) var currentUser: User? = nil
    
    /// Private initializer to enforce singleton pattern
    private init() {
        // Initialize Supabase client with values from Config
        supabase = SupabaseClient(
            supabaseURL: URL(string: Config.Supabase.url)!,
            supabaseKey: Config.Supabase.anonKey
        )
        
        // Try to restore session
        Task {
            await checkSession()
        }
    }
    
    /// Checks for an existing session and updates authentication state
    private func checkSession() async {
        do {
            currentUser = try await supabase.auth.session.user
            isAuthenticated = currentUser != nil
        } catch {
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    /// Signs in a user with their email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    /// - Throws: An `AuthError.signInFailed` if sign-in fails
    func signIn(email: String, password: String) async throws {
        do {
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            currentUser = authResponse.user
            isAuthenticated = currentUser != nil
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    /// Creates a new user account with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    /// - Throws: An `AuthError.signUpFailed` if sign-up fails
    func signUp(email: String, password: String) async throws {
        do {
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            currentUser = authResponse.user
            isAuthenticated = currentUser != nil
        } catch {
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    /// Signs out the current user
    /// - Throws: An `AuthError.signOutFailed` if sign-out fails
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }
    
    /// Sends a password reset email to the specified email address
    /// - Parameter email: The email address for which to reset the password
    /// - Throws: An `AuthError.resetPasswordFailed` if the reset fails
    func resetPassword(email: String) async throws {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            throw AuthError.resetPasswordFailed(error.localizedDescription)
        }
    }
    
    /// Gets the current user, if authenticated
    /// - Returns: The current user, or nil if not authenticated
    func getCurrentUser() -> User? {
        return currentUser
    }
} 