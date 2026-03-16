import SwiftUI
import SwiftData

struct RingTossPrecisionViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var ringPosition: CGPoint = .zero
    @State private var targetPosition: CGPoint = CGPoint(x: 195, y: 300)
    @State private var isDragging = false
    @State private var score = 0
    @State private var throws_ = 0
    @State private var showResult = false
    @State private var lastHit = false
    @State private var ringOffset: CGSize = .zero

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Ring Toss Precision",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { saveAndDismiss() }
                )

                HStack {
                    GameStatBadgeRingoSPinner(label: "Score", value: "\(score)")
                    Spacer()
                    GameStatBadgeRingoSPinner(label: "Throws", value: "\(throws_)/10")
                }
                .padding(.horizontal, adaptyW(16))
                .padding(.vertical, adaptyH(8))

                ZStack {
                    Circle()
                        .stroke(
                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3),
                            lineWidth: adaptyW(3)
                        )
                        .frame(width: adaptyW(60), height: adaptyW(60))
                        .position(targetPosition)
                        .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.5), radius: 10)

                    Circle()
                        .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                        .frame(width: adaptyW(12), height: adaptyW(12))
                        .position(targetPosition)

                    if throws_ < 10 {
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
                                lineWidth: adaptyW(4)
                            )
                            .frame(width: adaptyW(36), height: adaptyW(36))
                            .position(
                                x: adaptyW(195) + ringOffset.width,
                                y: adaptyH(550) + ringOffset.height
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        isDragging = true
                                        ringOffset = value.translation
                                    }
                                    .onEnded { value in
                                        isDragging = false
                                        evaluateThrow(offset: value.translation)
                                    }
                            )
                    }

                    if showResult {
                        Text(lastHit ? "HIT!" : "MISS")
                            .font(.system(size: adaptyW(32), weight: .black, design: .rounded))
                            .foregroundStyle(lastHit ? .green : .red)
                            .shadow(color: lastHit ? .green.opacity(0.5) : .red.opacity(0.5), radius: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if throws_ >= 10 {
                    VStack(spacing: adaptyH(12)) {
                        Text("Final Score: \(score)/10")
                            .font(.system(size: adaptyW(22), weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        CustomButtonRingoSPinner(
                            title: "Play Again",
                            theme: viewModel.selectedTheme,
                            icon: "arrow.counterclockwise"
                        ) {
                            resetGame()
                        }
                    }
                    .padding(.horizontal, adaptyW(20))
                    .padding(.bottom, adaptyH(20))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }

    private func evaluateThrow(offset: CGSize) {
        let throwX = adaptyW(195) + offset.width
        let throwY = adaptyH(550) + offset.height
        let dist = hypot(throwX - targetPosition.x, throwY - targetPosition.y)

        throws_ += 1
        lastHit = dist < adaptyW(40)
        if lastHit { score += 1 }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            showResult = true
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            ringOffset = .zero
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showResult = false
            }
        }

        if throws_ >= 10 {
            saveScore()
        }
    }

    private func resetGame() {
        score = 0
        throws_ = 0
        showResult = false
        ringOffset = .zero
    }

    private func saveScore() {
        let existing = try? modelContext.fetch(
            FetchDescriptor<MiniGameScoreRingoSPinner>(
                predicate: #Predicate { $0.gameName == "Ring Toss Precision" },
                sortBy: [SortDescriptor(\MiniGameScoreRingoSPinner.bestScore, order: .reverse)]
            )
        )
        let best = max(existing?.first?.bestScore ?? 0, score)

        let entry = MiniGameScoreRingoSPinner(
            gameName: "Ring Toss Precision",
            score: score,
            bestScore: best,
            date: .now
        )
        modelContext.insert(entry)
        try? modelContext.save()
        viewModel.addScore(score)
    }

    private func saveAndDismiss() {
        if throws_ > 0 { saveScore() }
        dismiss()
    }
}

struct GameStatBadgeRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: adaptyH(2)) {
            Text(label)
                .font(.system(size: adaptyW(11)))
                .foregroundStyle(.white.opacity(0.5))
            Text(value)
                .font(.system(size: adaptyW(18), weight: .bold, design: .rounded))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
        }
        .padding(.horizontal, adaptyW(16))
        .padding(.vertical, adaptyH(8))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(12))
                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
        )
    }
}

#Preview {
    NavigationStack {
        RingTossPrecisionViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
