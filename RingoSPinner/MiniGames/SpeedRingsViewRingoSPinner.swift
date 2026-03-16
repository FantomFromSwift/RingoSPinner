import SwiftUI
import SwiftData
internal import Combine


struct SpeedRingsViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var rings: [SpeedRingRingoSPinner] = []
    @State private var lastId = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let ringTimer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Speed Rings",
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
                    if !gameStarted && !gameOver {
                        CustomButtonRingoSPinner(
                            title: "Start Game",
                            theme: viewModel.selectedTheme,
                            icon: "play.fill"
                        ) {
                            startGame()
                        }
                        .padding(.horizontal, adaptyW(60))
                    } else if gameOver {
                        VStack(spacing: adaptyH(16)) {
                            Text("Fast Finger!")
                                .font(.system(size: adaptyW(24), weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Final Score: \(score)")
                                .font(.system(size: adaptyW(36), weight: .black, design: .rounded))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

                            CustomButtonRingoSPinner(
                                title: "Try Again",
                                theme: viewModel.selectedTheme,
                                icon: "arrow.counterclockwise"
                            ) {
                                startGame()
                            }
                            .padding(.horizontal, adaptyW(40))
                        }
                    } else {
                        ForEach(rings) { ring in
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.8),
                                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.2)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: adaptyH(30)
                                    )
                                )
                                .frame(width: adaptyW(60), height: adaptyW(60))
                                .position(ring.position)
                                .onTapGesture {
                                    handleTap(id: ring.id)
                                }
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .onReceive(timer) { _ in
            if gameStarted && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    endGame()
                }
            }
        }
        .onReceive(ringTimer) { _ in
            if gameStarted {
                spawnRing()
            }
        }
    }

    private func startGame() {
        score = 0
        timeRemaining = 30
        gameStarted = true
        gameOver = false
        rings = []
        spawnRing()
    }

    private func spawnRing() {
        let newRing = SpeedRingRingoSPinner(
            id: lastId,
            position: CGPoint(
                x: CGFloat.random(in: adaptyW(50)...adaptyW(340)),
                y: CGFloat.random(in: adaptyH(100)...adaptyH(450))
            )
        )
        lastId += 1
        withAnimation(.spring(response: 0.2)) {
            rings.append(newRing)
        }
        
        
        let idToRemove = newRing.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                rings.removeAll { $0.id == idToRemove }
            }
        }
    }

    private func handleTap(id: Int) {
        if let index = rings.firstIndex(where: { $0.id == id }) {
            score += 1
            rings.remove(at: index)
        }
    }

    private func endGame() {
        gameStarted = false
        gameOver = true
        saveScore()
    }

    private func saveScore() {
        let existing = try? modelContext.fetch(
            FetchDescriptor<MiniGameScoreRingoSPinner>(
                predicate: #Predicate { $0.gameName == "Speed Rings" },
                sortBy: [SortDescriptor(\MiniGameScoreRingoSPinner.bestScore, order: .reverse)]
            )
        )
        let best = max(existing?.first?.bestScore ?? 0, score)

        modelContext.insert(MiniGameScoreRingoSPinner(
            gameName: "Speed Rings",
            score: score,
            bestScore: best,
            date: .now
        ))
        try? modelContext.save()
        viewModel.addScore(score / 5)
    }

    private func saveAndDismiss() {
        if score > 0 { saveScore() }
        dismiss()
    }
}

struct SpeedRingRingoSPinner: Identifiable {
    let id: Int
    let position: CGPoint
}

#Preview {
    SpeedRingsViewRingoSPinner()
        .environment(ViewModelRingoSPinner())
}
