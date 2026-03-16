import SwiftUI
import SwiftData

struct SettingsViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Settings",
                    theme: viewModel.selectedTheme
                )

                ScrollView {
                    VStack(spacing: adaptyH(16)) {
                        SettingsThemeSectionRingoSPinner()
                        SettingsNavigationSectionRingoSPinner()
                        SettingsInfoSectionRingoSPinner()
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(8))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SettingsProfileSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            HStack(spacing: adaptyW(14)) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                    ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: adaptyW(56), height: adaptyW(56))

                    Text(String(viewModel.userName.prefix(1)))
                        .font(.system(size: adaptyW(24), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: adaptyH(4)) {
                    TextField("Your Name", text: $vm.userName)
                        .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .tint(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

                    Text("Level \(viewModel.totalScore / 100 + 1) • \(viewModel.totalScore) points")
                        .font(.system(size: adaptyW(13)))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }
}

struct SettingsThemeSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    private let themes: [(String, String, [Color])] = [
        ("default", "Cosmic Blue", [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)]),
        ("neon", "Neon Glow", [Color(red: 0.0, green: 1.0, blue: 0.8), Color(red: 0.6, green: 0.0, blue: 1.0)]),
        ("sunrise", "Sunrise", [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.3, blue: 0.4)])
    ]

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(alignment: .leading, spacing: adaptyH(10)) {
                Text("Theme")
                    .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                ForEach(themes, id: \.0) { theme in
                    let isLocked = theme.0 != "default" && !IAPManagerVE.shared.isPurchased(productIdFor(theme.0))
                    let isCurrentTheme = viewModel.selectedTheme == theme.0

                    Button {
                        if !isLocked {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedTheme = theme.0
                            }
                        }
                    } label: {
                        HStack(spacing: adaptyW(12)) {
                            Circle()
                                .fill(
                                    LinearGradient(colors: theme.2, startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: adaptyW(36), height: adaptyW(36))
                                .overlay {
                                    if isLocked {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: adaptyW(14)))
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                }

                            Text(theme.1)
                                .font(.system(size: adaptyW(14), weight: .medium))
                                .foregroundStyle(.white)

                            Spacer()

                            if isLocked {
                                Text("PRO")
                                    .font(.system(size: adaptyW(10), weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, adaptyW(8))
                                    .padding(.vertical, adaptyH(3))
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(colors: theme.2, startPoint: .leading, endPoint: .trailing)
                                            )
                                    )
                            } else if isCurrentTheme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                            }
                        }
                    }
                }
            }
        }
    }

    private func productIdFor(_ theme: String) -> String {
        switch theme {
        case "neon": "com.ringospinner.theme.neon"
        case "sunrise": "com.ringospinner.theme.sunrise"
        default: ""
        }
    }
}

struct SettingsNavigationSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        VStack(spacing: adaptyH(8)) {
            let allThemesBought = IAPManagerVE.shared.isPurchased("com.ringospinner.theme.neon") && IAPManagerVE.shared.isPurchased("com.ringospinner.theme.sunrise")
            
            if !allThemesBought {
                NavigationLink(value: "store") {
                    SettingsRowRingoSPinner(icon: "crown.fill", title: "Premium Store", theme: viewModel.selectedTheme)
                }
            }

            NavigationLink(value: "stats") {
                SettingsRowRingoSPinner(icon: "chart.bar.fill", title: "Statistics", theme: viewModel.selectedTheme)
            }

            NavigationLink(value: "about") {
                SettingsRowRingoSPinner(icon: "info.circle.fill", title: "About", theme: viewModel.selectedTheme)
            }
        }
        .navigationDestination(for: String.self) { route in
            switch route {
            case "store": StoreViewRingoSPinner()
            case "stats": StatsViewRingoSPinner()
            case "about": AboutViewRingoSPinner()
            default: EmptyView()
            }
        }
    }
}

struct SettingsInfoSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(spacing: adaptyH(8)) {
                Button("Restore Purchases", systemImage: "arrow.clockwise") {
                    IAPManagerVE.shared.restorePurchases()
                }
                .font(.system(size: adaptyW(14), weight: .medium))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, adaptyH(10))

                Text("RingoSPinner v1.0")
                    .font(.system(size: adaptyW(12)))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }
}

struct SettingsRowRingoSPinner: View {
    let icon: String
    let title: String
    let theme: String

    var body: some View {
        HStack(spacing: adaptyW(12)) {
            Image(systemName: icon)
                .font(.system(size: adaptyW(16)))
                .foregroundStyle(ColorsRingoSPinner.accent(for: theme))
                .frame(width: adaptyW(36), height: adaptyW(36))
                .background(
                    RoundedRectangle(cornerRadius: adaptyW(10))
                        .fill(ColorsRingoSPinner.accent(for: theme).opacity(0.12))
                )

            Text(title)
                .font(.system(size: adaptyW(15), weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: adaptyW(12)))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(adaptyW(14))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(14))
                .fill(ColorsRingoSPinner.cardBackground(for: theme))
        )
    }
}

#Preview {
    NavigationStack {
        SettingsViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
