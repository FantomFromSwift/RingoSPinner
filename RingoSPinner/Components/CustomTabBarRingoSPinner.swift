import SwiftUI

struct CustomTabBarRingoSPinner: View {
    @Binding var selectedTab: TabItemRingoSPinner
    let theme: String
    @State private var pressedTab: TabItemRingoSPinner?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItemRingoSPinner.allCases, id: \.self) { tab in
                TabBarItemRingoSPinner(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    isPressed: pressedTab == tab,
                    theme: theme
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in pressedTab = tab }
                        .onEnded { _ in pressedTab = nil }
                )
            }
        }
        .padding(.horizontal, adaptyW(8))
        .padding(.top, adaptyH(8))
        .padding(.bottom, adaptyH(4))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(24))
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: adaptyW(24))
                        .stroke(
                            ColorsRingoSPinner.accent(for: theme).opacity(0.2),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: ColorsRingoSPinner.accent(for: theme).opacity(0.15),
                    radius: 20,
                    y: -5
                )
        )
        .padding(.horizontal, adaptyW(12))
    }
}

struct TabBarItemRingoSPinner: View {
    let tab: TabItemRingoSPinner
    let isSelected: Bool
    let isPressed: Bool
    let theme: String
    let action: () -> Void

    var body: some View {
        Button(tab.rawValue, systemImage: tab.icon, action: action)
            .labelStyle(.verticalLabelStyle)
            .font(.system(size: adaptyW(10), weight: .medium))
            .foregroundStyle(isSelected ? ColorsRingoSPinner.accent(for: theme) : .gray.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, adaptyH(6))
            .background(
                isSelected ?
                    Capsule()
                        .fill(ColorsRingoSPinner.accent(for: theme).opacity(0.12))
                        .shadow(
                            color: ColorsRingoSPinner.accent(for: theme).opacity(0.3),
                            radius: 8
                        )
                    : nil
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: adaptyH(4)) {
            configuration.icon
                .font(.system(size: adaptyW(20)))
            configuration.title
        }
    }
}

extension LabelStyle where Self == VerticalLabelStyle {
    static var verticalLabelStyle: VerticalLabelStyle { VerticalLabelStyle() }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBarRingoSPinner(
            selectedTab: .constant(.home),
            theme: "default"
        )
    }
    .background(Color.black)
}
