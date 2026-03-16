import SwiftUI
import SwiftData

struct TaskDetailViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoritesRingoSPinner]
    let task: TaskContentRingoSPinner
    @State private var currentStep = -1
    @State private var isCompleted = false

    private var isFavorited: Bool {
        favorites.contains { $0.itemId == task.id && $0.type == "task" }
    }

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: adaptyW(18), weight: .bold))
                            .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                            .frame(width: adaptyW(40), height: adaptyW(40))
                            .background(Circle().fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme)))
                    }

                    Spacer()

                    Text("Task")
                        .font(.system(size: adaptyW(18), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                            .font(.system(size: adaptyW(18)))
                            .foregroundStyle(isFavorited ? .red : ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                            .frame(width: adaptyW(40), height: adaptyW(40))
                            .background(Circle().fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme)))
                    }
                }
                .padding(.horizontal, adaptyW(16))
                .padding(.vertical, adaptyH(8))

                ScrollView {
                    VStack(spacing: adaptyH(20)) {
                        if isCompleted {
                            TaskCompletionViewRingoSPinner {
                                dismiss()
                            }
                        } else if currentStep < 0 {
                            TaskOverviewRingoSPinner(task: task) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentStep = 0
                                }
                            }
                        } else {
                            TaskStepViewRingoSPinner(
                                step: task.steps[currentStep],
                                stepNumber: currentStep + 1,
                                totalSteps: task.steps.count,
                                isLast: currentStep == task.steps.count - 1
                            ) {
                                if currentStep < task.steps.count - 1 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        currentStep += 1
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        isCompleted = true
                                        viewModel.completeTask()
                                        viewModel.addScore(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(20))
                    .contentMargins(.bottom, adaptyH(40))
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.itemId == task.id && $0.type == "task" }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoritesRingoSPinner(type: "task", itemId: task.id))
        }
        try? modelContext.save()
    }
}

struct TaskOverviewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let task: TaskContentRingoSPinner
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: adaptyH(20)) {
            Image(systemName: task.icon)
                .font(.system(size: adaptyW(56)))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                            ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.4), radius: 15)
                .padding(.top, adaptyH(20))

            Text(task.title)
                .font(.system(size: adaptyW(24), weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(task.description)
                .font(.system(size: adaptyW(15)))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            HStack(spacing: adaptyW(20)) {
                VStack {
                    Text("\(task.steps.count)")
                        .font(.system(size: adaptyW(22), weight: .bold, design: .rounded))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                    Text("Steps")
                        .font(.system(size: adaptyW(12)))
                        .foregroundStyle(.white.opacity(0.5))
                }

                VStack {
                    Text(task.difficulty)
                        .font(.system(size: adaptyW(16), weight: .bold, design: .rounded))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                    Text("Level")
                        .font(.system(size: adaptyW(12)))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.vertical, adaptyH(12))

            CustomButtonRingoSPinner(
                title: "Start Task",
                theme: viewModel.selectedTheme,
                icon: "play.fill",
                action: onStart
            )
        }
    }
}

struct TaskStepViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let step: String
    let stepNumber: Int
    let totalSteps: Int
    let isLast: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: adaptyH(24)) {
            ProgressRingViewRingoSPinner(
                progress: Double(stepNumber) / Double(totalSteps),
                theme: viewModel.selectedTheme,
                size: 80
            )

            Text("Step \(stepNumber) of \(totalSteps)")
                .font(.system(size: adaptyW(14), weight: .semibold))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

            CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                Text(step)
                    .font(.system(size: adaptyW(16), weight: .medium))
                    .foregroundStyle(.white)
                    .lineSpacing(adaptyH(4))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            CustomButtonRingoSPinner(
                title: isLast ? "Complete Task" : "Next Step",
                theme: viewModel.selectedTheme,
                icon: isLast ? "checkmark" : "arrow.right",
                action: onNext
            )
        }
        .padding(.top, adaptyH(20))
    }
}

struct TaskCompletionViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let onDone: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: adaptyH(24)) {
            Spacer()

            ZStack {
                Circle()
                    .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.1))
                    .frame(width: adaptyW(160), height: adaptyW(160))

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: adaptyW(80)))
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
                    .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.5), radius: 20)
            }
            .scaleEffect(scale)
            .opacity(opacity)

            Text("Task Complete!")
                .font(.system(size: adaptyW(28), weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .opacity(opacity)

            Text("+10 Points")
                .font(.system(size: adaptyW(18), weight: .bold, design: .rounded))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                .opacity(opacity)

            Spacer()

            CustomButtonRingoSPinner(
                title: "Done",
                theme: viewModel.selectedTheme,
                icon: "arrow.right",
                action: onDone
            )
            .opacity(opacity)
        }
        .padding(.top, adaptyH(40))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    let task = TaskContentRingoSPinner(
        id: "preview",
        title: "Test Task",
        description: "A sample task",
        steps: ["Step one", "Step two", "Step three"],
        difficulty: "Beginner",
        icon: "target"
    )
    NavigationStack {
        TaskDetailViewRingoSPinner(task: task)
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
