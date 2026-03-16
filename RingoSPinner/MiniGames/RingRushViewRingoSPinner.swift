import SwiftUI
import SwiftData
internal import Combine

struct RingRushViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isRunning = false
    @State private var gameOver = false
    @State private var fallingRings: [FallingRingRingoSPinner] = []
    @State private var lastId = 0
    
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let frameTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    let spawnTimer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Ring Rush",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { saveAndDismiss() }
                )

                HStack {
                    GameStatBadgeRingoSPinner(label: "Score", value: "\(score)")
                    Spacer()
                    GameStatBadgeRingoSPinner(label: "Time", value: "\(timeRemaining)s")
                }
                .padding(.horizontal, adaptyW(16))
                .padding(.vertical, adaptyH(8))

                ZStack {
                    if !isRunning && !gameOver {
                        CustomButtonRingoSPinner(
                            title: "Start Catching",
                            theme: viewModel.selectedTheme,
                            icon: "play.fill"
                        ) {
                            startGame()
                        }
                        .padding(.horizontal, adaptyW(60))
                    } else if gameOver {
                        VStack(spacing: adaptyH(16)) {
                            Text("Great Catch!")
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
                                startGame()
                            }
                            .padding(.horizontal, adaptyW(40))
                        }
                    } else {
                        ForEach(fallingRings) { ring in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                            ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: adaptyW(3)
                                )
                                .frame(width: adaptyW(44), height: adaptyW(44))
                                .position(x: ring.x, y: ring.y)
                                .onTapGesture {
                                    catchRing(id: ring.id)
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .onReceive(gameTimer) { _ in
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    endGame()
                }
            }
        }
        .onReceive(frameTimer) { _ in
            if isRunning {
                updateRings()
            }
        }
        .onReceive(spawnTimer) { _ in
            if isRunning {
                spawnRing()
            }
        }
    }

    private func startGame() {
        score = 0
        timeRemaining = 30
        isRunning = true
        gameOver = false
        fallingRings = []
    }

    private func spawnRing() {
        let ring = FallingRingRingoSPinner(
            id: lastId,
            x: CGFloat.random(in: adaptyW(40)...adaptyW(350)),
            y: -50,
            speed: CGFloat.random(in: 4...8)
        )
        lastId += 1
        fallingRings.append(ring)
    }

    private func updateRings() {
        for i in 0..<fallingRings.count {
            fallingRings[i].y += fallingRings[i].speed
        }
        
        fallingRings.removeAll { $0.y > adaptyH(700) }
    }

    private func catchRing(id: Int) {
        if let index = fallingRings.firstIndex(where: { $0.id == id }) {
            score += 1
            fallingRings.remove(at: index)
        }
    }

    private func endGame() {
        isRunning = false
        gameOver = true
        saveScore()
    }

    private func saveScore() {
        modelContext.insert(MiniGameScoreRingoSPinner(
            gameName: "Ring Rush",
            score: score,
            bestScore: score,
            date: .now
        ))
        try? modelContext.save()
        viewModel.addScore(score / 4)
    }

    private func saveAndDismiss() {
        if score > 0 { saveScore() }
        dismiss()
    }
}

struct FallingRingRingoSPinner: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    let speed: CGFloat
}

#Preview {
    RingRushViewRingoSPinner()
        .environment(ViewModelRingoSPinner())
}
