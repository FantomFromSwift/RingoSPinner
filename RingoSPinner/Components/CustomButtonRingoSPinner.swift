import SwiftUI

struct CustomButtonRingoSPinner: View {
    let title: String
    let theme: String
    var icon: String? = nil
    var isSecondary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: adaptyW(8)) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: adaptyW(16), weight: .semibold))
                }
                Text(title)
                    .font(.system(size: adaptyW(16), weight: .bold, design: .rounded))
            }
            .foregroundStyle(isSecondary ? ColorsRingoSPinner.accent(for: theme) : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, adaptyH(14))
            .background(
                RoundedRectangle(cornerRadius: adaptyW(14))
                    .fill(
                        isSecondary ?
                            AnyShapeStyle(ColorsRingoSPinner.accent(for: theme).opacity(0.15)) :
                            AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        ColorsRingoSPinner.accent(for: theme),
                                        ColorsRingoSPinner.secondary(for: theme)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(
                        color: isSecondary ? .clear : ColorsRingoSPinner.accent(for: theme).opacity(0.4),
                        radius: 12,
                        y: 4
                    )
            )
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: title)
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomButtonRingoSPinner(title: "Start Training", theme: "default", icon: "play.fill") {}
        CustomButtonRingoSPinner(title: "View Details", theme: "default", isSecondary: true) {}
    }
    .padding()
    .background(Color.black)
}
