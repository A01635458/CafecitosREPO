import SwiftUI

struct ScansView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Escaneos")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)
            Spacer()
            Text("No se han tomado escaneos todavía.")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .navigationTitle("Escaneos")
    }
}
