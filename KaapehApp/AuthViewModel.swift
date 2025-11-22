
import SwiftUI
import Supabase
import Combine


@MainActor
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var feedbackMessage: String? = nil
    @Published var isError: Bool = false
    
    func getInitialSession() async {
        // Attempt to restore an existing session on app launch (e.g., from persisted credentials).
        do {
            let current = try await supabase.auth.session
            self.session = current
            self.isAuthenticated = current != nil
        } catch {
            // If no session is available, explicitly reset state.
            print("No active session: \(error.localizedDescription)")
            self.session = nil
            self.isAuthenticated = false
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let minLength = password.count >= 8
        let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
        return minLength && hasNumber
    }
    
    func signUp(email: String, password: String) async {
        guard isValidPassword(password) else {
            
            feedbackMessage = nil
            isError = false
            
            feedbackMessage = "La contraseña debe tener mínimo 8 caracteres y al menos 1 número."
            isError = true
            return
        }
        do {
            guard !isLoading else { return }
            isLoading = true
            defer { isLoading = false }

            let response = try await supabase.auth.signUp(
                email: email,
                password: password)
            
            feedbackMessage = "Cuenta creada correctamente. Revisa tu correo si es necesario confirmar."
            isError = false
            
            self.session = response.session
            self.isAuthenticated = self.session != nil
            print("SignUp: session is \(self.session == nil ? "nil" : "present")")
        } catch {
            print("Sign-up failed: \(error.localizedDescription)")
            self.session = nil
            self.isAuthenticated = false
            feedbackMessage = error.localizedDescription   // ← texto que viene del server
            isError = true
        }
    }
    
    func signIn(email: String, password: String) async {
        // Sign in an existing user with email/password and update session.
        do {
            feedbackMessage = nil
            isError = false
            // Avoid overlapping sign-in attempts.
            guard !isLoading else { return }
            isLoading = true
            defer { isLoading = false }

            // On success, Supabase returns a non-optional Session.
            let session = try await supabase.auth.signIn(
                email: email,
                password: password)
            feedbackMessage = "Sesión iniciada correctamente"
            isError = false
            // Store the active session so the UI can react.
            self.session = session
            // Mark the user as authenticated since sign-in succeeded.
            self.isAuthenticated = true
            // Keep the previous logging style for consistency (will be "present" on success).
            print("SignIn: session is \(self.session == nil ? "nil" : "present")")
            
        } catch {
            // Reset to a clean unauthenticated state if sign-in fails.
            print("Sign-in failed: \(error.localizedDescription)")
            self.session = nil
            self.isAuthenticated = false
            feedbackMessage = error.localizedDescription
            isError = true
        }
    }
    
    func signOut() async {
        // Clear the server-side session and update local state.
        do {
            try await supabase.auth.signOut()
            self.session = nil
            self.isAuthenticated = false
        } catch {
            // Log sign-out errors but keep the UI responsive.
            print("Sign-out failed: \(error.localizedDescription)")
        }
    }
}


