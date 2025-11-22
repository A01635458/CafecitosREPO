import SwiftUI

struct AuthView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bienvenido")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Inicia sesión")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.ka_coffee)
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
                        // CARD PRINCIPAL
                        Card {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Tu cuenta")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.black)
                                
                                // Email
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Correo electrónico")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    TextField("usuario@ejemplo.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .textFieldStyle(.plain)
                                        .padding(10)
                                        .background(Color.ka_bg)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                // Password
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Contraseña")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    SecureField("••••••••", text: $password)
                                        .textFieldStyle(.plain)
                                        .padding(10)
                                        .background(Color.ka_bg)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                // Botón Iniciar sesión
                                Button {
                                    Task {
                                        await authViewModel.signIn(email: email, password: password)
                                    }
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Iniciar sesión")
                                            .font(.system(size: 16, weight: .bold))
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                    .background(Color.ka_coffee)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.top, 4)
                                
                                // Divider "o"
                                HStack {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundStyle(Color.ka_divider)
                                    Text("o")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundStyle(Color.ka_divider)
                                }
                                .padding(.vertical, 4)
                                
                                // Botón Crear cuenta
                                Button {
                                    Task {
                                        await authViewModel.signUp(email: email, password: password)
                                    }
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Crear cuenta")
                                            .font(.system(size: 16, weight: .bold))
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                    .background(Color.ka_surface)
                                    .foregroundStyle(Color.ka_coffee)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.ka_coffee.opacity(0.25), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // 🔔 Mensaje de estado (éxito / error)
                                if let message = authViewModel.feedbackMessage {
                                    Text(message)
                                        .font(.footnote)
                                        .foregroundStyle(authViewModel.isError ? .red : .green)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                        
                        // Texto secundario
                        VStack(spacing: 4) {
                            Text("Al continuar aceptas los términos y el uso responsable de Káapeh.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        Spacer().frame(height: 40)
                    }
                }
                .background(Color.ka_bg)
            }
        }
    }
}

