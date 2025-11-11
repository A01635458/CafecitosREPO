import SwiftUI

struct AchievementsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(" Logros")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)
            Spacer()
            Text("Aún no inicias una leccion")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .navigationTitle("Logros")
    }
}
