import SwiftUI
import SwiftData
internal import Combine


struct BalanceRingViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var ringOffset: CGSize = .zero
    @State private var driftX: CGFloat = 1
    @State private var driftY: CGFloat = 0.7
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isRunning = false
    @State private var gameOver = false

    let gameTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var isBalanced: Bool {
        abs(ringOffset.width) < adaptyW(40) && abs(ringOffset.height) < adaptyH(40)
    }

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Balance Ring",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                HStack {
                    GameStatBadgeRingoSPinner(label: "Score", value: "\(score)")
                    Spacer()
                    GameStatBadgeRingoSPinner(label: "Time", value: "\(timeRemaining)s")
                }
                .padding(.horizontal, adaptyW(16))
                .padding(.vertical, adaptyH(8))

                ZStack {
                    Circle()
                        .stroke(
                            isBalanced ?
                            Color.green.opacity(0.3) :
                            Color.red.opacity(0.3),
                            lineWidth: adaptyW(2)
                        )
                        .frame(width: adaptyW(80), height: adaptyW(80))

                    Circle()
                        .fill(
                            isBalanced ?
                            Color.green.opacity(0.1) :
                            Color.red.opacity(0.1)
                        )
                        .frame(width: adaptyW(80), height: adaptyW(80))

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
                        .frame(width: adaptyW(50), height: adaptyW(50))
                        .offset(ringOffset)
                        .shadow(
                            color: isBalanced ?
                            Color.green.opacity(0.5) :
                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3),
                            radius: 10
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    ringOffset = CGSize(
                                        width: value.translation.width,
                                        height: value.translation.height
                                    )
                                }
                        )

                    if !isRunning && !gameOver {
                        VStack(spacing: adaptyH(16)) {
                            Text("Keep the ring centered!")
                                .font(.system(size: adaptyW(15), weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))

                            CustomButtonRingoSPinner(
                                title: "Start",
                                theme: viewModel.selectedTheme,
                                icon: "play.fill"
                            ) {
                                isRunning = true
                            }
                        }
                        .padding(.horizontal, adaptyW(40))
                        .offset(y: adaptyH(120))
                    }

                    if gameOver {
                        VStack(spacing: adaptyH(16)) {
                            Text("Time's Up!")
                                .font(.system(size: adaptyW(24), weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Score: \(score)")
                                .font(.system(size: adaptyW(36), weight: .black, design: .rounded))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

                            CustomButtonRingoSPinner(
                                title: "Play Again",
                                theme: viewModel.selectedTheme,
                                icon: "arrow.counterclockwise"
                            ) {
                                resetGame()
                            }
                        }
                        .padding(.horizontal, adaptyW(40))
                        .offset(y: adaptyH(120))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .onReceive(gameTimer) { _ in
            guard isRunning, !gameOver else { return }
            ringOffset.width += driftX
            ringOffset.height += driftY

            if abs(ringOffset.width) > adaptyW(150) { driftX *= -1 }
            if abs(ringOffset.height) > adaptyH(150) { driftY *= -1 }

            driftX += CGFloat.random(in: -0.3...0.3)
            driftY += CGFloat.random(in: -0.2...0.2)
            driftX = min(max(driftX, -3), 3)
            driftY = min(max(driftY, -3), 3)

            if isBalanced { score += 1 }
        }
        .onReceive(countdownTimer) { _ in
            guard isRunning, !gameOver else { return }
            timeRemaining -= 1
            if timeRemaining <= 0 {
                gameOver = true
                isRunning = false
                saveScore()
            }
        }
    }

    private func resetGame() {
        score = 0
        timeRemaining = 30
        ringOffset = .zero
        driftX = 1
        driftY = 0.7
        gameOver = false
        isRunning = true
    }

    private func saveScore() {
        modelContext.insert(MiniGameScoreRingoSPinner(
            gameName: "Balance Ring",
            score: score,
            bestScore: score,
            date: .now
        ))
        try? modelContext.save()
        viewModel.addScore(score / 100)
    }
}

#Preview {
    NavigationStack {
        BalanceRingViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
