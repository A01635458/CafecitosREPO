import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Configuración de cuenta")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 40)
                .foregroundStyle(.black)

            Form {
                Section("Información del usuario") {
                    Text("Nombre: Usuario")
                    Text("Correo: usuario@ejemplo.com")
                }
                Section("Cambiar contraseña") {
                    Text("••••••••••")
                }
            }
        }
        .background(Color.brown.ignoresSafeArea())
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
