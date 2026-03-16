import SwiftUI
import SwiftData

struct DailyChallengeViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var challengeCompleted = false

    private var challenge: TaskContentRingoSPinner? {
        viewModel.dailyChallenge
    }

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Daily Challenge",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView {
                    VStack(spacing: adaptyH(20)) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: adaptyW(80)
                                    )
                                )
                                .frame(width: adaptyW(160), height: adaptyW(160))

                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: adaptyW(48)))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                            ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.5), radius: 15)
                        }
                        .padding(.top, adaptyH(20))

                        Text("Today's Challenge")
                            .font(.system(size: adaptyW(24), weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(Date.now, format: .dateTime.day().month().year())
                            .font(.system(size: adaptyW(14)))
                            .foregroundStyle(.white.opacity(0.5))

                        if let challenge {
                            CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                                VStack(alignment: .leading, spacing: adaptyH(10)) {
                                    HStack {
                                        Image(systemName: challenge.icon)
                                            .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                        Text(challenge.title)
                                            .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                    }

                                    Text(challenge.description)
                                        .font(.system(size: adaptyW(14)))
                                        .foregroundStyle(.white.opacity(0.7))

                                    Text("Difficulty: \(challenge.difficulty)")
                                        .font(.system(size: adaptyW(12), weight: .semibold))
                                        .foregroundStyle(ColorsRingoSPinner.secondary(for: viewModel.selectedTheme))
                                }
                            }

                            CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                                VStack(alignment: .leading, spacing: adaptyH(8)) {
                                    Text("Steps")
                                        .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)

                                    ForEach(challenge.steps.indices, id: \.self) { index in
                                        HStack(alignment: .top, spacing: adaptyW(10)) {
                                            Text("\(index + 1)")
                                                .font(.system(size: adaptyW(12), weight: .bold, design: .rounded))
                                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                                .frame(width: adaptyW(24), height: adaptyW(24))
                                                .background(
                                                    Circle()
                                                        .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.15))
                                                )

                                            Text(challenge.steps[index])
                                                .font(.system(size: adaptyW(13)))
                                                .foregroundStyle(.white.opacity(0.75))
                                        }
                                    }
                                }
                            }

                            if !challengeCompleted {
                                CustomButtonRingoSPinner(
                                    title: "Mark Complete",
                                    theme: viewModel.selectedTheme,
                                    icon: "checkmark"
                                ) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        challengeCompleted = true
                                        viewModel.completeTask()
                                        viewModel.addScore(15)
                                    }
                                }
                            } else {
                                HStack(spacing: adaptyW(8)) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Challenge Complete! +15 points")
                                        .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                                        .foregroundStyle(.green)
                                }
                                .padding(.vertical, adaptyH(12))
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .contentMargins(.bottom, adaptyH(40))
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }
}

#Preview {
    NavigationStack {
        DailyChallengeViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
