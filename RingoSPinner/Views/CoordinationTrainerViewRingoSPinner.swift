import SwiftUI
import SwiftData
internal import Combine

struct CoordinationTrainerViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExercise: CoordExerciseRingoSPinner = .patternTap

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Coordination Trainer",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView(.horizontal) {
                    HStack(spacing: adaptyW(8)) {
                        ForEach(CoordExerciseRingoSPinner.allCases, id: \.self) { exercise in
                            Button(exercise.rawValue) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedExercise = exercise
                                }
                            }
                            .font(.system(size: adaptyW(13), weight: selectedExercise == exercise ? .bold : .medium))
                            .foregroundStyle(selectedExercise == exercise ? .white : .white.opacity(0.5))
                            .padding(.horizontal, adaptyW(14))
                            .padding(.vertical, adaptyH(7))
                            .background(
                                Capsule()
                                    .fill(
                                        selectedExercise == exercise ?
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3) :
                                        ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.vertical, adaptyH(8))
                }
                .scrollIndicators(.hidden)

                switch selectedExercise {
                case .patternTap:
                    PatternTapExerciseRingoSPinner()
                case .visualTracking:
                    VisualTrackingExerciseRingoSPinner()
                case .handCoordination:
                    HandCoordinationExerciseRingoSPinner()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }
}

enum CoordExerciseRingoSPinner: String, CaseIterable {
    case patternTap = "Pattern Tap"
    case visualTracking = "Visual Tracking"
    case handCoordination = "Hand Coordination"
}

struct PatternTapExerciseRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @State private var pattern: [Int] = []
    @State private var userPattern: [Int] = []
    @State private var isShowing = false
    @State private var currentShow = 0
    @State private var highlightedCell: Int? = nil
    @State private var score = 0
    @State private var level = 3
    @State private var failed = false

    var body: some View {
        VStack(spacing: adaptyH(16)) {
            HStack {
                GameStatBadgeRingoSPinner(label: "Score", value: "\(score)")
                Spacer()
                GameStatBadgeRingoSPinner(label: "Level", value: "\(level)")
            }
            .padding(.horizontal, adaptyW(16))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: adaptyW(10)), count: 3), spacing: adaptyW(10)) {
                ForEach(0..<9, id: \.self) { index in
                    RoundedRectangle(cornerRadius: adaptyW(14))
                        .fill(
                            highlightedCell == index ?
                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme) :
                            ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme)
                        )
                        .frame(height: adaptyW(90))
                        .overlay {
                            if highlightedCell == index {
                                Circle()
                                    .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                    .frame(width: adaptyW(30), height: adaptyW(30))
                                    .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme), radius: 10)
                            }
                        }
                        .onTapGesture {
                            guard !isShowing, !failed else { return }
                            handleTap(index)
                        }
                }
            }
            .padding(.horizontal, adaptyW(16))

            if failed {
                VStack(spacing: adaptyH(12)) {
                    Text("Wrong pattern!")
                        .font(.system(size: adaptyW(18), weight: .bold, design: .rounded))
                        .foregroundStyle(.red)

                    CustomButtonRingoSPinner(
                        title: "Try Again",
                        theme: viewModel.selectedTheme,
                        icon: "arrow.counterclockwise"
                    ) {
                        failed = false
                        level = 3
                        score = 0
                        startPattern()
                    }
                    .padding(.horizontal, adaptyW(40))
                }
            } else if pattern.isEmpty {
                CustomButtonRingoSPinner(
                    title: "Start Training",
                    theme: viewModel.selectedTheme,
                    icon: "play.fill"
                ) {
                    startPattern()
                }
                .padding(.horizontal, adaptyW(40))
            } else if isShowing {
                Text("Watch the pattern...")
                    .font(.system(size: adaptyW(15), weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            } else {
                Text("Repeat the pattern!")
                    .font(.system(size: adaptyW(15), weight: .medium))
                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
            }

            Spacer()
        }
    }

    private func startPattern() {
        pattern = (0..<level).map { _ in Int.random(in: 0..<9) }
        userPattern = []
        showPattern()
    }

    private func showPattern() {
        isShowing = true
        currentShow = 0
        showNext()
    }

    private func showNext() {
        guard currentShow < pattern.count else {
            highlightedCell = nil
            isShowing = false
            return
        }

        highlightedCell = pattern[currentShow]
        currentShow += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            highlightedCell = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showNext()
            }
        }
    }

    private func handleTap(_ index: Int) {
        userPattern.append(index)
        highlightedCell = index

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            highlightedCell = nil
        }

        let currentIndex = userPattern.count - 1
        if userPattern[currentIndex] != pattern[currentIndex] {
            failed = true
            return
        }

        if userPattern.count == pattern.count {
            score += level
            level += 1
            viewModel.addScore(level)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startPattern()
            }
        }
    }
}

struct VisualTrackingExerciseRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @State private var targetPosition: CGPoint = CGPoint(x: 195, y: 300)
    @State private var phase: CGFloat = 0
    @State private var isTracking = false
    @State private var trackScore = 0

    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                GameStatBadgeRingoSPinner(label: "Track Score", value: "\(trackScore)")
            }
            .padding(.horizontal, adaptyW(16))

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: adaptyW(20)
                        )
                    )
                    .frame(width: adaptyW(40), height: adaptyW(40))
                    .position(targetPosition)
                    .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.5), radius: 10)

                if !isTracking {
                    CustomButtonRingoSPinner(
                        title: "Start Tracking",
                        theme: viewModel.selectedTheme,
                        icon: "eye.fill"
                    ) {
                        isTracking = true
                    }
                    .padding(.horizontal, adaptyW(60))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture(coordinateSpace: .local) { location in
                guard isTracking else { return }
                let dist = hypot(location.x - targetPosition.x, location.y - targetPosition.y)
                if dist < adaptyW(30) {
                    trackScore += 1
                    viewModel.addScore(1)
                }
            }
        }
        .onReceive(timer) { _ in
            guard isTracking else { return }
            phase += 0.02
            targetPosition = CGPoint(
                x: adaptyW(195) + sin(phase * 2) * adaptyW(120),
                y: adaptyH(300) + cos(phase * 3) * adaptyH(100)
            )
        }
    }
}

struct HandCoordinationExerciseRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @State private var leftOffset: CGSize = .zero
    @State private var rightOffset: CGSize = .zero
    @State private var matchCount = 0
    @State private var isActive = false

    var body: some View {
        VStack(spacing: adaptyH(16)) {
            HStack {
                Spacer()
                GameStatBadgeRingoSPinner(label: "Matches", value: "\(matchCount)")
            }
            .padding(.horizontal, adaptyW(16))

            Text("Move both rings to overlap")
                .font(.system(size: adaptyW(14), weight: .medium))
                .foregroundStyle(.white.opacity(0.5))

            ZStack {
                Circle()
                    .stroke(ColorsRingoSPinner.accent(for: viewModel.selectedTheme), lineWidth: adaptyW(3))
                    .frame(width: adaptyW(60), height: adaptyW(60))
                    .offset(leftOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { v in
                                leftOffset = v.translation
                                checkOverlap()
                            }
                    )

                Circle()
                    .stroke(ColorsRingoSPinner.secondary(for: viewModel.selectedTheme), lineWidth: adaptyW(3))
                    .frame(width: adaptyW(60), height: adaptyW(60))
                    .offset(rightOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { v in
                                rightOffset = v.translation
                                checkOverlap()
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func checkOverlap() {
        let dist = hypot(leftOffset.width - rightOffset.width, leftOffset.height - rightOffset.height)
        if dist < adaptyW(20) {
            matchCount += 1
            viewModel.addScore(2)
            leftOffset = CGSize(
                width: CGFloat.random(in: -adaptyW(100)...adaptyW(100)),
                height: CGFloat.random(in: -adaptyH(100)...adaptyH(100))
            )
            rightOffset = CGSize(
                width: CGFloat.random(in: -adaptyW(100)...adaptyW(100)),
                height: CGFloat.random(in: -adaptyH(100)...adaptyH(100))
            )
        }
    }
}

#Preview {
    NavigationStack {
        CoordinationTrainerViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
