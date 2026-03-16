import SwiftUI

struct CustomCardRingoSPinner<Content: View>: View {
    let theme: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: adaptyH(8)) {
            content
        }
        .padding(adaptyW(16))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(16))
                .fill(ColorsRingoSPinner.cardBackground(for: theme))
                .overlay {
                    RoundedRectangle(cornerRadius: adaptyW(16))
                        .stroke(
                            ColorsRingoSPinner.accent(for: theme).opacity(0.15),
                            lineWidth: 0.5
                        )
                }
                .shadow(
                    color: ColorsRingoSPinner.glow(for: theme).opacity(0.1),
                    radius: 10
                )
        )
    }
}

#Preview {
    CustomCardRingoSPinner(theme: "default") {
        Text("Card Content")
            .foregroundStyle(.white)
    }
    .padding()
    .background(Color.black)
}
