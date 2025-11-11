//import SwiftUI
//
//struct ProfileView: View {
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    Text("Perfil")
//                        .font(.system(size: 32, weight: .bold))
//                    Spacer()
//                    NavigationLink(destination: SettingsView()) {
//                        Image(systemName: "gearshape")
//                            .font(.system(size: 22, weight: .semibold))
//                            .foregroundStyle(Color.ka_coffee)
//                    }
//                }
//                .padding(.top, 60)
//                .padding(.bottom, 24)
//                .padding(.horizontal, 20)
//                .background(Color.ka_surface)
//                .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.ka_divider), alignment: .bottom)
//
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 24) {
//                        // Profile card
//                        Card {
//                            VStack(spacing: 16) {
//                                Circle()
//                                    .fill(Color(red: 0.95, green: 0.91, blue: 0.84))
//                                    .frame(width: 100, height: 100)
//                                    .overlay(
//                                        Image(systemName: "person.fill")
//                                            .font(.system(size: 48))
//                                            .foregroundStyle(Color.ka_coffee)
//                                    )
//                                Text("Usuario")
//                                    .font(.system(size: 24, weight: .bold))
//                                Text("usuario@ejemplo.com")
//                                    .foregroundStyle(.secondary)
//                            }
//                            .frame(maxWidth: .infinity)
//                        }
//
//                        // Navegación: Stats como botones
//                        HStack(spacing: 12) {
//                            NavigationLink(destination: ScansView()) {
//                                ProfileStatCard(icon: "camera", color: .ka_coffee, number: "0", label: "Escaneos")
//                            }
//                            NavigationLink(destination: NotesView()) {
//                                ProfileStatCard(icon: "book", color: .green, number: "0", label: "Notas")
//                            }
//                            NavigationLink(destination: AchievementsView()) {
//                                ProfileStatCard(icon: "rosette", color: .orange, number: "0", label: "Logros")
//                            }
//                        }
//                        .padding(.horizontal, 20)
//
//                        // Acerca de
//                        ProfileSectionTitle("Acerca de")
//                        Card {
//                            VStack(alignment: .leading, spacing: 12) {
//                                Text("Káapeh México")
//                                    .font(.system(size: 18, weight: .bold))
//                                Text("Aplicación educativa para aprender sobre el proceso del café, desde la planta hasta la taza.")
//                                    .foregroundStyle(.secondary)
//                                Text("Versión 1.0.0")
//                                    .font(.footnote)
//                                    .foregroundStyle(.secondary)
//                            }
//                        }
//
//                        // Logout
//                        Button {
//                            // TODO: logout
//                        } label: {
//                            Label("Cerrar sesión", systemImage: "arrow.right.square")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundStyle(.red)
//                                .frame(maxWidth: .infinity)
//                                .padding(16)
//                                .background(Color.red.opacity(0.08))
//                                .clipShape(RoundedRectangle(cornerRadius: 12))
//                        }
//                        .padding(.horizontal, 20)
//
//                        Spacer().frame(height: 40)
//                    }
//                }
//                .background(Color.ka_bg)
//            }
//        }
//    }
//}
//
//// MARK: - Components
//private struct ProfileStatCard: View {
//    let icon: String
//    let color: Color
//    let number: String
//    let label: String
//
//    var body: some View {
//        Card {
//            VStack(spacing: 12) {
//                Image(systemName: icon).foregroundStyle(color)
//                Text(number).font(.system(size: 28, weight: .bold))
//                Text(label).font(.system(size: 13)).foregroundStyle(.secondary)
//            }
//            .frame(maxWidth: .infinity)
//        }
//    }
//}
//
//private struct ProfileSectionTitle: View {
//    let title: String
//    init(_ title: String) { self.title = title }
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 24, weight: .bold))
//            Spacer()
//        }
//        .padding(.horizontal, 20)
//    }
//}
//
//#Preview {
//    ProfileView()
//}


//
//  ProfileView.swift
//  KaapehApp
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    // Traemos todas las notas existentes desde SwiftData
    @Query private var notes: [NoteEntity]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Perfil")
                        .font(.system(size: 32, weight: .bold))
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
                .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.ka_divider), alignment: .bottom)

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
                                Text("Usuario")
                                    .font(.system(size: 24, weight: .bold))
                                Text("usuario@ejemplo.com")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Stats con enlaces interactivos
                        HStack(spacing: 12) {
                            NavigationLink(destination: ScansView()) {
                                ProfileStatCard(icon: "camera", color: .ka_coffee, number: "0", label: "Escaneos")
                            }
                            NavigationLink(destination: NotesView()) {
                                ProfileStatCard(icon: "book", color: .green, number: "\(notes.count)", label: "Notas")
                            }
                            NavigationLink(destination: AchievementsView()) {
                                ProfileStatCard(icon: "rosette", color: .orange, number: "0", label: "Logros")
                            }
                        }
                        .padding(.horizontal, 20)

                        // Acerca de
                        ProfileSectionTitle("Acerca de")
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Káapeh México")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Aplicación educativa para aprender sobre el proceso del café, desde la planta hasta la taza.")
                                    .foregroundStyle(.secondary)
                                Text("Versión 1.0.0")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Logout
                        Button {
                            // TODO: logout
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
                Text(number).font(.system(size: 28, weight: .bold))
                Text(label).font(.system(size: 13)).foregroundStyle(.secondary)
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

#Preview {
    ProfileView()
        .modelContainer(for: NoteEntity.self)
}
