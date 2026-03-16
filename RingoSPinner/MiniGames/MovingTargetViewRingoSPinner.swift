import SwiftUI
import SwiftData
internal import Combine

struct MovingTargetViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var targetX: CGFloat = 100
    @State private var movingRight = true
    @State private var score = 0
    @State private var taps = 0
    @State private var isRunning = false
    @State private var showHit = false

    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Moving Target",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { saveAndDismiss() }
                )

                HStack {
                    GameStatBadgeRingoSPinner(label: "Score", value: "\(score)")
                    Spacer()
                    GameStatBadgeRingoSPinner(label: "Taps", value: "\(taps)/15")
                }
                .padding(.horizontal, adaptyW(16))
                .padding(.vertical, adaptyH(8))

                ZStack {
                    if isRunning && taps < 15 {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: adaptyW(25)
                                )
                            )
                            .frame(width: adaptyW(50), height: adaptyW(50))
                            .position(x: targetX, y: adaptyH(300))
                            .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.6), radius: 12)
                            .onTapGesture {
                                handleTap()
                            }

                        Circle()
                            .stroke(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.15), lineWidth: 1)
                            .frame(width: adaptyW(80), height: adaptyW(80))
                            .position(x: targetX, y: adaptyH(300))
                    }

                    if showHit {
                        Text("+1")
                            .font(.system(size: adaptyW(28), weight: .black, design: .rounded))
                            .foregroundStyle(.green)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if !isRunning && taps == 0 {
                        CustomButtonRingoSPinner(
                            title: "Start Game",
                            theme: viewModel.selectedTheme,
                            icon: "play.fill"
                        ) {
                            isRunning = true
                        }
                        .padding(.horizontal, adaptyW(60))
                    }

                    if taps >= 15 {
                        VStack(spacing: adaptyH(16)) {
                            Text("Game Over!")
                                .font(.system(size: adaptyW(28), weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Score: \(score)/15")
                                .font(.system(size: adaptyW(20), weight: .bold, design: .rounded))
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
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .onReceive(timer) { _ in
            guard isRunning, taps < 15 else { return }
            let speed: CGFloat = adaptyW(3)
            if movingRight {
                targetX += speed
                if targetX > adaptyW(340) { movingRight = false }
            } else {
                targetX -= speed
                if targetX < adaptyW(50) { movingRight = true }
            }
        }
    }

    private func handleTap() {
        taps += 1
        score += 1

        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            showHit = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showHit = false }
        }

        if taps >= 15 { saveScore() }
    }

    private func resetGame() {
        score = 0
        taps = 0
        isRunning = true
        targetX = adaptyW(100)
    }

    private func saveScore() {
        let existing = try? modelContext.fetch(
            FetchDescriptor<MiniGameScoreRingoSPinner>(
                predicate: #Predicate { $0.gameName == "Moving Target" },
                sortBy: [SortDescriptor(\MiniGameScoreRingoSPinner.bestScore, order: .reverse)]
            )
        )
        let best = max(existing?.first?.bestScore ?? 0, score)

        modelContext.insert(MiniGameScoreRingoSPinner(
            gameName: "Moving Target",
            score: score,
            bestScore: best,
            date: .now
        ))
        try? modelContext.save()
        viewModel.addScore(score)
    }

    private func saveAndDismiss() {
        if taps > 0 { saveScore() }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MovingTargetViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
