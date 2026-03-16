import SwiftUI
import SwiftData

struct TasksViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDifficulty: String = "All"

    private let difficulties = ["All", "Beginner", "Intermediate", "Advanced"]

    private var filtered: [TaskContentRingoSPinner] {
        if selectedDifficulty == "All" { return viewModel.tasks }
        return viewModel.tasks.filter { $0.difficulty == selectedDifficulty }
    }

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Training Tasks",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView(.horizontal) {
                    HStack(spacing: adaptyW(8)) {
                        ForEach(difficulties, id: \.self) { diff in
                            Button(diff) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDifficulty = diff
                                }
                            }
                            .font(.system(size: adaptyW(13), weight: selectedDifficulty == diff ? .bold : .medium))
                            .foregroundStyle(selectedDifficulty == diff ? .white : .white.opacity(0.5))
                            .padding(.horizontal, adaptyW(14))
                            .padding(.vertical, adaptyH(7))
                            .background(
                                Capsule()
                                    .fill(
                                        selectedDifficulty == diff ?
                                        difficultyColor(diff).opacity(0.3) :
                                        ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.vertical, adaptyH(8))
                }
                .scrollIndicators(.hidden)

                ScrollView {
                    LazyVStack(spacing: adaptyH(10)) {
                        ForEach(filtered) { task in
                            NavigationLink(value: task) {
                                TaskCardRingoSPinner(task: task)
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .navigationDestination(for: TaskContentRingoSPinner.self) { task in
            TaskDetailViewRingoSPinner(task: task)
        }
    }

    private func difficultyColor(_ diff: String) -> Color {
        switch diff {
        case "Beginner": .green
        case "Intermediate": .orange
        case "Advanced": .red
        default: ColorsRingoSPinner.accent(for: viewModel.selectedTheme)
        }
    }
}

struct TaskCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let task: TaskContentRingoSPinner

    var body: some View {
        HStack(spacing: adaptyW(12)) {
            RoundedRectangle(cornerRadius: adaptyW(12))
                .fill(.clear)
                .frame(width: adaptyW(44), height: adaptyW(44))
                .background {
                    Image(AssetMapperRingoSPinner.getIcon(for: task.id))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: adaptyW(56), height: adaptyW(56))
                }
                .clipShape(RoundedRectangle(cornerRadius: adaptyW(12)))

            VStack(alignment: .leading, spacing: adaptyH(4)) {
                Text(task.title)
                    .font(.system(size: adaptyW(14), weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(task.steps.count) steps • \(task.difficulty)")
                    .font(.system(size: adaptyW(12)))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: adaptyW(12)))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(adaptyW(14))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(14))
                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
        )
    }
}

#Preview {
    NavigationStack {
        TasksViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
