import SwiftUI

struct ScansView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Escaneos")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)
                .foregroundStyle(.black)
            Spacer()
            Text("No se han tomado escaneos todavía.")
                .foregroundStyle(.secondary)
                .foregroundStyle(.black)
            Spacer()
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .navigationTitle("Escaneos")
    }
}

#Preview {
    ScansView()
}
