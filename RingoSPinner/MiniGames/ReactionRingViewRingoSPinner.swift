import SwiftUI
import SwiftData

struct ReactionRingViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var ringVisible = false
    @State private var ringPosition: CGPoint = .zero
    @State private var round = 0
    @State private var totalTime: Double = 0
    @State private var appearTime: Date = .now
    @State private var lastReaction: Int = 0
    @State private var isWaiting = false
    @State private var gameOver = false
    @State private var ringScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Reaction Ring",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                HStack {
                    GameStatBadgeRingoSPinner(label: "Round", value: "\(round)/10")
                    Spacer()
                    GameStatBadgeRingoSPinner(label: "Last", value: lastReaction > 0 ? "\(lastReaction)ms" : "—")
                }
                .padding(.horizontal, adaptyW(16))
                .padding(.vertical, adaptyH(8))

                ZStack {
                    if gameOver {
                        VStack(spacing: adaptyH(16)) {
                            Text("Average Reaction")
                                .font(.system(size: adaptyW(17), weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))

                            Text("\(Int(totalTime / 10))ms")
                                .font(.system(size: adaptyW(48), weight: .black, design: .rounded))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

                            CustomButtonRingoSPinner(
                                title: "Play Again",
                                theme: viewModel.selectedTheme,
                                icon: "arrow.counterclockwise"
                            ) {
                                resetGame()
                            }
                            .padding(.horizontal, adaptyW(40))
                        }
                    } else if ringVisible {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.2)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: adaptyW(40)
                                )
                            )
                            .frame(width: adaptyW(80), height: adaptyW(80))
                            .scaleEffect(ringScale)
                            .shadow(
                                color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.6),
                                radius: 20
                            )
                            .position(ringPosition)
                            .onTapGesture {
                                handleTap()
                            }
                            .transition(.scale.combined(with: .opacity))
                    } else if isWaiting {
                        Text("Wait...")
                            .font(.system(size: adaptyW(24), weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                    } else if round == 0 {
                        CustomButtonRingoSPinner(
                            title: "Start",
                            theme: viewModel.selectedTheme,
                            icon: "bolt.fill"
                        ) {
                            startRound()
                        }
                        .padding(.horizontal, adaptyW(60))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }

    private func startRound() {
        isWaiting = true
        let delay = Double.random(in: 1.0...3.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            ringPosition = CGPoint(
                x: CGFloat.random(in: adaptyW(60)...adaptyW(330)),
                y: CGFloat.random(in: adaptyH(200)...adaptyH(500))
            )
            appearTime = .now
            isWaiting = false

            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                ringVisible = true
                ringScale = 1.0
            }

            withAnimation(.linear(duration: 1.5)) {
                ringScale = 0.3
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if ringVisible {
                    ringVisible = false
                    round += 1
                    totalTime += 1500

                    if round >= 10 {
                        gameOver = true
                        saveScore()
                    } else {
                        startRound()
                    }
                }
            }
        }
    }

    private func handleTap() {
        let reaction = Date.now.timeIntervalSince(appearTime) * 1000
        lastReaction = Int(reaction)
        totalTime += reaction
        round += 1

        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            ringVisible = false
        }

        if round >= 10 {
            gameOver = true
            saveScore()
        } else {
            startRound()
        }
    }

    private func resetGame() {
        round = 0
        totalTime = 0
        lastReaction = 0
        gameOver = false
        ringVisible = false
        isWaiting = false
        startRound()
    }

    private func saveScore() {
        let avgMs = Int(totalTime / 10)
        let existing = try? modelContext.fetch(
            FetchDescriptor<MiniGameScoreRingoSPinner>(
                predicate: #Predicate { $0.gameName == "Reaction Ring" },
                sortBy: [SortDescriptor(\MiniGameScoreRingoSPinner.bestScore, order: .forward)]
            )
        )
        let best = min(existing?.first?.bestScore ?? avgMs, avgMs)

        modelContext.insert(MiniGameScoreRingoSPinner(
            gameName: "Reaction Ring",
            score: avgMs,
            bestScore: best,
            date: .now
        ))
        try? modelContext.save()
        viewModel.addScore(max(0, 500 - avgMs) / 50)
    }
}

#Preview {
    NavigationStack {
        ReactionRingViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
