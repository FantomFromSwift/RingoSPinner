import SwiftUI
import SwiftData

struct AboutViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var ringRotation: Double = 0

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "About",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView {
                    VStack(spacing: adaptyH(24)) {
                        ZStack {
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                            ColorsRingoSPinner.secondary(for: viewModel.selectedTheme),
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme)
                                        ],
                                        center: .center
                                    ),
                                    lineWidth: adaptyW(4)
                                )
                                .frame(width: adaptyW(80), height: adaptyW(80))
                                .rotationEffect(.degrees(ringRotation))

                            Image(systemName: "target")
                                .font(.system(size: adaptyW(32)))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                        }
                        .padding(.top, adaptyH(20))

                        Text("RingoSPinner")
                            .font(.system(size: adaptyW(28), weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                        ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Version 1.0")
                            .font(.system(size: adaptyW(13)))
                            .foregroundStyle(.white.opacity(0.4))

                        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                            VStack(alignment: .leading, spacing: adaptyH(12)) {
                                Text("About RingoSPinner")
                                    .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text("RingoSPinner is a comprehensive ring coordination training platform designed to help athletes of all levels improve their precision, reaction time, and throwing mechanics. Whether you are a casual enthusiast or a competitive ring athlete, our curated exercises, interactive mini games, and detailed training protocols will guide your improvement journey.")
                                    .font(.system(size: adaptyW(14)))
                                    .foregroundStyle(.white.opacity(0.75))
                                    .lineSpacing(adaptyH(4))
                            }
                        }

                        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                            VStack(alignment: .leading, spacing: adaptyH(12)) {
                                Text("Training Philosophy")
                                    .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text("We believe in progressive, science-backed training. Every exercise in RingoSPinner is designed around principles from sports science, motor learning research, and biomechanics. Short, focused sessions with deliberate practice yield better results than long, unfocused training. Track your progress, challenge yourself daily, and watch your skills transform.")
                                    .font(.system(size: adaptyW(14)))
                                    .foregroundStyle(.white.opacity(0.75))
                                    .lineSpacing(adaptyH(4))
                            }
                        }

                        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                            VStack(alignment: .leading, spacing: adaptyH(8)) {
                                Text("Credits")
                                    .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                AboutCreditRowRingoSPinner(label: "Design & Development", value: "RingoSPinner Team")
                                AboutCreditRowRingoSPinner(label: "Framework", value: "SwiftUI & SwiftData")
                                AboutCreditRowRingoSPinner(label: "Icons", value: "SF Symbols")
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
    }
}

struct AboutCreditRowRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: adaptyW(13)))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: adaptyW(13), weight: .medium))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
        }
    }
}

#Preview {
    NavigationStack {
        AboutViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
