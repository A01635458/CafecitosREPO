import SwiftUI
import SwiftData
import Supabase
import Foundation

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    // SwiftData: notas
    @Query private var notes: [NoteEntity]

    // Supabase: campos de perfil
    @State private var username: String = ""
    @State private var full_name: String = ""
    @State private var email: String = ""
    @State private var scans: [ScanModel] = []

    @State private var plants: Int = 0
    
    //NUEVA PROPIEDAD: Contar lecciones completadas para el logro
    @State private var completedLessonsCount: Int = 0

    @State private var isLoadingProfile = false
    @State private var isUpdatingProfile = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Perfil")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.ka_coffee)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
                .background(Color.ka_surface)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.ka_divider),
                    alignment: .bottom
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile card
                        Card {
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color(red: 0.95, green: 0.91, blue: 0.84))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 48))
                                            .foregroundStyle(Color.ka_coffee)
                                    )

                                Text(full_name.isEmpty ? "Usuario" : full_name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.black)
                                Text(username.isEmpty ? "Nombre de usuario" : username)
                                    .foregroundStyle(.secondary)
                                Text(email.isEmpty ? "usuario@ejemplo.com" : email)
                                    .foregroundStyle(.secondary)

                                if isLoadingProfile {
                                    ProgressView()
                                        .padding(.top, 4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Stats con enlaces interactivos
                        HStack(spacing: 12) {
                            NavigationLink(destination: ScansView()) {
                                ProfileStatCard(
                                    icon: "camera",
                                    color: .ka_coffee,
                                    number: "\(scans.count)",
                                    label: "Escaneos"
                                )
                            }
                            
                            ProfileStatCard(
                                icon: "leaf",
                                color: .green,
                                number: "\(plants)",
                                label: "Plantas"
                            )
                            
                            NavigationLink(destination: AchievementsView().environmentObject(authViewModel)) {
                                ProfileStatCard(
                                    icon: "rosette",
                                    color: .orange,
                                    number: "\(completedLessonsCount)",
                                    label: "Logros"
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Sección para editar perfil (equivalente al Form de Supabase)
                        ProfileSectionTitle("Información de perfil")
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                Group {
                                    Text("Username")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    TextField("Username", text: $username)
                                        .textContentType(.username)
                                        .textInputAutocapitalization(.never)
                                        .padding(10)
                                        .background(Color.ka_bg)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }

                                Group {
                                    Text("Nombre completo")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    TextField("Nombre completo", text: $full_name)
                                        .textContentType(.name)
                                        .padding(10)
                                        .background(Color.ka_bg)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }

                                Button {
                                    updateProfileButtonTapped()
                                } label: {
                                    HStack {
                                        if isUpdatingProfile {
                                            ProgressView()
                                                .tint(.white)
                                        }
                                        Text("Actualizar perfil")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.ka_coffee)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .disabled(isUpdatingProfile)
                                .padding(.top, 8)
                            }
                        }
                        

                        ProfileSectionTitle("Accesibilidad (Narración)")
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $authViewModel.isVoiceOverActive) {
                                    Label(
                                        authViewModel.isVoiceOverActive ?
                                            "Narración de App (Activada)" :
                                            "Narración de App (Desactivada)",
                                        systemImage: authViewModel.isVoiceOverActive ? "speaker.wave.3.fill" : "speaker.slash.fill"
                                    )
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.black)
                                }
                                .tint(Color.ka_coffee)
                                .onChange(of: authViewModel.isVoiceOverActive) { newValue in
                                    authViewModel.setVoiceOverPreference(isEnabled: newValue)
                                }
                                    
                                Text("Controla si la aplicación debe narrar automáticamente datos curiosos, logros y mensajes de bienvenida. Esto no afecta el VoiceOver nativo de iOS.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        // --- FIN: Botón/Toggle de VoiceOver ---

                        // Acerca de
                        ProfileSectionTitle("Acerca de")
                            .foregroundStyle(.black)
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Káapeh México")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.black)
                                Text("Aplicación educativa para aprender sobre el proceso del café, desde la planta hasta la taza.")
                                    .foregroundStyle(.secondary)
                                    .foregroundStyle(.black)
                                Text("Versión 1.0.0")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .foregroundStyle(.black)
                            }
                        }

                        // Logout -> Supabase signOut
                        Button {
                            Task {
                                await authViewModel.signOut()
                            }
                        } label: {
                            Label("Cerrar sesión", systemImage: "arrow.right.square")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Color.red.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 40)
                    }
                }
                .background(Color.ka_bg)
            }
        }
        .task {
            await getInitialProfile()
            await loadScans()
            await fetchCompletedLessonsCount()
        }
    }

    // MARK: - Supabase logic

    func getInitialProfile() async {
        isLoadingProfile = true
        defer { isLoadingProfile = false }

        do {
            let session = try await supabase.auth.session
            let currentUser = session.user

            email = currentUser.email ?? ""

            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value

            self.username = profile.username ?? ""
            self.full_name = profile.full_name ?? ""
            self.email = profile.email ?? ""
            
            let plantResp = try await supabase
                .from("coffee_plants")
                .select("id", count: .exact)
                .eq("user_id", value: currentUser.id)
                .execute()

            self.plants = plantResp.count ?? 0

        } catch {
            debugPrint("Error fetching profile:", error)
        }
    }
    
    func fetchCompletedLessonsCount() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id

            let response = try await supabase
                .from("lesson_progress")
                .select("id", count: .exact) // Contamos las filas
                .eq("user_id", value: userId)
                .eq("completed", value: true) // Solo las que están completadas
                .execute()

            await MainActor.run {
                self.completedLessonsCount = response.count ?? 0
            }
        } catch {
            debugPrint("Error fetching completed lessons count:", error)

        }
    }
    

    func loadScans() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id

            let response: [ScanModel] = try await supabase
                .from("scans")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value

            await MainActor.run {
                self.scans = response
            }
        } catch {
            debugPrint("Error loading scans:", error)
        }
    }

    func updateProfileButtonTapped() {
        Task {
            isUpdatingProfile = true
            defer { isUpdatingProfile = false }

            do {
                let session = try await supabase.auth.session
                let currentUser = session.user

                try await supabase
                    .from("profiles")
                    .update(
                        UpdateProfileParams(
                            username: username,
                            full_name: full_name
                            
                        )
                    )
                    .eq("id", value: currentUser.id)
                    .execute()
            } catch {
                debugPrint("Error updating profile:", error)
            }
        }
    }
}

// MARK: - Components

private struct ProfileStatCard: View {
    let icon: String
    let color: Color
    let number: String
    let label: String

    var body: some View {
        Card {
            VStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(color)
                Text(number)
                    .font(.system(size: 28, weight: .bold))
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ProfileSectionTitle: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
