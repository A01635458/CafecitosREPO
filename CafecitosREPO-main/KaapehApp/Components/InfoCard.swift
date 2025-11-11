import SwiftUI

struct InfoCard: View {
    let title: String
    let text: String
    let systemIcon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemIcon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.ka_coffee)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.ka_warn)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
