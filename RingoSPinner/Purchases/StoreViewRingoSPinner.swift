import SwiftUI
import SwiftData
internal import StoreKit

struct StoreViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(IAPManagerVE.self) private var iapManager
    @Environment(\.dismiss) private var dismiss
//    @State private var iapManager = IAPManagerVE.shared

    private let themes: [(id: String, name: String, colors: [Color])] = [
        ("com.ringospinner.theme.default", "Cosmic Blue", [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)]),
        ("com.ringospinner.theme.neon", "Neon Glow", [Color(red: 0.0, green: 1.0, blue: 0.8), Color(red: 0.6, green: 0.0, blue: 1.0)]),
        ("com.ringospinner.theme.sunrise", "Sunrise", [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.3, blue: 0.4)])
    ]

    private func priceString(for themeId: String) -> String {
        if themeId == "com.ringospinner.theme.default" { return "Free" }
        guard let product = iapManager.products.first(where: { $0.productIdentifier == themeId }) else {
            return iapManager.isLoading ? "..." : "—"
        }
        return product.localizedPriceVE
    }

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Premium Store",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView {
                    VStack(spacing: adaptyH(16)) {
                        StoreBannerRingoSPinner()

                        ForEach(themes, id: \.id) { theme in
                            StoreThemeCardRingoSPinner(
                                themeId: theme.id,
                                name: theme.name,
                                price: priceString(for: theme.id),
                                colors: theme.colors,
                                isPurchased: theme.id == "com.ringospinner.theme.default" || iapManager.isPurchased(theme.id)
                            ) {
                                purchaseTheme(theme.id)
                            }
                        }

                        Button("Restore Purchases") {
                            iapManager.restorePurchases()
                        }
                        .font(.system(size: adaptyW(14), weight: .medium))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                        .padding(.top, adaptyH(8))
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(8))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .task {
            iapManager.fetchProducts()
        }
    }

    private func purchaseTheme(_ themeId: String) {
        if let product = iapManager.products.first(where: { $0.productIdentifier == themeId }) {
            iapManager.purchase(product)
        }
    }
}

struct StoreBannerRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @State private var glowPhase: CGFloat = 0

    var body: some View {
        VStack(spacing: adaptyH(12)) {
            Image(systemName: "crown.fill")
                .font(.system(size: adaptyW(40)))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .orange.opacity(0.4 + glowPhase * 0.2), radius: 15)

            Text("Unlock Premium Themes")
                .font(.system(size: adaptyW(22), weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Customize your training experience with beautiful color themes")
                .font(.system(size: adaptyW(13)))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(adaptyW(24))
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: adaptyW(20))
                .fill(
                    LinearGradient(
                        colors: ColorsRingoSPinner.gradientColors(for: viewModel.selectedTheme).map { $0.opacity(0.4) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: adaptyW(20))
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                }
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                glowPhase = 1
            }
        }
    }
}

struct StoreThemeCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let themeId: String
    let name: String
    let price: String
    let colors: [Color]
    let isPurchased: Bool
    let onPurchase: () -> Void

    var body: some View {
        VStack(spacing: adaptyH(12)) {
            HStack {
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: adaptyW(48), height: adaptyW(48))
                    .overlay {
                        if !isPurchased {
                            Image(systemName: "lock.fill")
                                .font(.system(size: adaptyW(18)))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }

                VStack(alignment: .leading, spacing: adaptyH(4)) {
                    HStack {
                        Text(name)
                            .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if !isPurchased {
                            Text("PRO")
                                .font(.system(size: adaptyW(10), weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, adaptyW(6))
                                .padding(.vertical, adaptyH(2))
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                                )
                        }
                    }

                    Text(price)
                        .font(.system(size: adaptyW(14), weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                if isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: adaptyW(24)))
                        .foregroundStyle(.green)
                } else {
                    Button("Buy", action: onPurchase)
                        .font(.system(size: adaptyW(13), weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, adaptyW(16))
                        .padding(.vertical, adaptyH(8))
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        )
                }
            }

            if !isPurchased {
                RoundedRectangle(cornerRadius: adaptyW(8))
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(height: adaptyH(40))
                    .overlay {
                        Text("Preview")
                            .font(.system(size: adaptyW(13), weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .blur(radius: 3)
                    .clipShape(RoundedRectangle(cornerRadius: adaptyW(8)))
            }
        }
        .padding(adaptyW(16))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(16))
                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                .overlay {
                    RoundedRectangle(cornerRadius: adaptyW(16))
                        .stroke(colors[0].opacity(0.2), lineWidth: 1)
                }
        )
    }
}

#Preview {
    NavigationStack {
        StoreViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
