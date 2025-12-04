
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
    @Published var fullname: String = ""
    
    let voiceService = VoiceOverService()
    @Published var isVoiceOverActive: Bool = UserDefaults.standard.bool(forKey: "isVoiceOverActive")
    @Published var hasAskedForVoiceOver: Bool = UserDefaults.standard.bool(forKey: "hasAskedForVoiceOver")
    
    func setVoiceOverPreference(isEnabled: Bool) {
        self.isVoiceOverActive = isEnabled
        self.hasAskedForVoiceOver = true
        
        UserDefaults.standard.set(isEnabled, forKey: "isVoiceOverActive")
        UserDefaults.standard.set(true, forKey: "hasAskedForVoiceOver")
        
        voiceService.setIsEnabled(isEnabled)
        
        if isEnabled {
            voiceService.speak("La narración de la aplicación ha sido activada. ¡Bienvenido a KaapehApp!")
        } else {
            voiceService.stopSpeaking()
        }
    }

    func getInitialSession() async {
        do {
            let current = try await supabase.auth.session
            self.session = current
            let currentUser = current.user
            self.isAuthenticated = current != nil
            
            let profile: Profile = try await supabase
                                     .from("profiles")
                                     .select()
                                     .eq("id", value: currentUser.id)
                                     .single()
                                     .execute()
                                     .value
            self.fullname = profile.full_name ?? ""
            
            self.voiceService.setIsEnabled(self.isVoiceOverActive)

        } catch {
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
            feedbackMessage = error.localizedDescription
            isError = true
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            feedbackMessage = nil
            isError = false
            guard !isLoading else { return }
            isLoading = true
            defer { isLoading = false }

            let session = try await supabase.auth.signIn(
                email: email,
                password: password)

            let profile: Profile = try await supabase
                                     .from("profiles")
                                     .select()
                                     .eq("id", value: session.user.id)
                                     .single()
                                     .execute()
                                     .value
            self.fullname = profile.full_name ?? ""

            feedbackMessage = "Sesión iniciada correctamente"
            isError = false
            self.session = session
            self.isAuthenticated = true
            print("SignIn: session is \(self.session == nil ? "nil" : "present")")
            
        } catch {
            print("Sign-in failed: \(error.localizedDescription)")
            self.session = nil
            self.isAuthenticated = false
            feedbackMessage = error.localizedDescription
            isError = true
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.session = nil
            self.isAuthenticated = false
            
        } catch {
            print("Sign-out failed: \(error.localizedDescription)")
        }
    }
}
