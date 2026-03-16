import SwiftUI
import SwiftData

struct MultiTargetComboViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var targets: [(id: Int, position: CGPoint, hit: Bool)] = []
    @State private var currentTarget = 0
    @State private var score = 0
    @State private var startTime: Date = .now
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var elapsed: Double = 0

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Multi Target Combo",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                HStack {
                    GameStatBadgeRingoSPinner(label: "Targets", value: "\(score)/\(targets.count)")
                    Spacer()
                    GameStatBadgeRingoSPinner(label: "Time", value: String(format: "%.1fs", elapsed))
                }
                .padding(.horizontal, adaptyW(16))
                .padding(.vertical, adaptyH(8))

                ZStack {
                    if !gameStarted {
                        CustomButtonRingoSPinner(
                            title: "Start",
                            theme: viewModel.selectedTheme,
                            icon: "play.fill"
                        ) {
                            startGame()
                        }
                        .padding(.horizontal, adaptyW(60))
                    } else if gameOver {
                        VStack(spacing: adaptyH(16)) {
                            Text("Combo Complete!")
                                .font(.system(size: adaptyW(24), weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text(String(format: "%.1f seconds", elapsed))
                                .font(.system(size: adaptyW(36), weight: .black, design: .rounded))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

                            CustomButtonRingoSPinner(
                                title: "Play Again",
                                theme: viewModel.selectedTheme,
                                icon: "arrow.counterclockwise"
                            ) {
                                startGame()
                            }
                            .padding(.horizontal, adaptyW(40))
                        }
                    } else {
                        ForEach(targets, id: \.id) { target in
                            ZStack {
                                Circle()
                                    .fill(
                                        target.hit ?
                                        Color.green.opacity(0.3) :
                                        (target.id == currentTarget ?
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.8) :
                                            Color.gray.opacity(0.3))
                                    )
                                    .frame(width: adaptyW(50), height: adaptyW(50))
                                    .shadow(
                                        color: target.id == currentTarget ?
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.6) :
                                            .clear,
                                        radius: 12
                                    )

                                Text("\(target.id + 1)")
                                    .font(.system(size: adaptyW(18), weight: .bold, design: .rounded))
                                    .foregroundStyle(target.hit ? .green : .white)
                            }
                            .position(target.position)
                            .onTapGesture {
                                handleTargetTap(target.id)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }

    private func startGame() {
        targets = (0..<6).map { i in
            (
                id: i,
                position: CGPoint(
                    x: CGFloat.random(in: adaptyW(50)...adaptyW(340)),
                    y: CGFloat.random(in: adaptyH(100)...adaptyH(450))
                ),
                hit: false
            )
        }
        currentTarget = 0
        score = 0
        gameStarted = true
        gameOver = false
        startTime = .now
        elapsed = 0
    }

    private func handleTargetTap(_ id: Int) {
        guard id == currentTarget else { return }

        if let index = targets.firstIndex(where: { $0.id == id }) {
            targets[index].hit = true
        }

        score += 1
        currentTarget += 1

        if score >= targets.count {
            elapsed = Date.now.timeIntervalSince(startTime)
            gameOver = true
            saveScore()
        }
    }

    private func saveScore() {
        let timeScore = max(0, 100 - Int(elapsed * 10))
        modelContext.insert(MiniGameScoreRingoSPinner(
            gameName: "Multi Target Combo",
            score: timeScore,
            bestScore: timeScore,
            date: .now
        ))
        try? modelContext.save()
        viewModel.addScore(timeScore / 10)
    }
}

#Preview {
    NavigationStack {
        MultiTargetComboViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
