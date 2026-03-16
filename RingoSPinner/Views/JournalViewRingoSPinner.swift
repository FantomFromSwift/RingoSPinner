import SwiftUI
import SwiftData

struct JournalViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Query(sort: \MiniGameScoreRingoSPinner.date, order: .reverse)
    private var gameScores: [MiniGameScoreRingoSPinner]
    @Query(sort: \SimulatorSessionRingoSPinner.date, order: .reverse)
    private var simSessions: [SimulatorSessionRingoSPinner]

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Journal",
                    theme: viewModel.selectedTheme
                )

                ScrollView {
                    LazyVStack(spacing: adaptyH(12)) {
                        JournalStatsCardRingoSPinner(
                            gamesPlayed: gameScores.count,
                            simRuns: simSessions.count,
                            tasksCompleted: viewModel.completedTasksCount
                        )

                        if gameScores.isEmpty && simSessions.isEmpty {
                            JournalEmptyStateRingoSPinner()
                        } else {
                            ForEach(mergedEntries) { entry in
                                JournalEntryCardRingoSPinner(entry: entry)
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(8))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var mergedEntries: [JournalEntryRingoSPinner] {
        var entries: [JournalEntryRingoSPinner] = []

        for score in gameScores {
            entries.append(JournalEntryRingoSPinner(
                id: score.id,
                type: .game,
                title: score.gameName,
                subtitle: "Score: \(score.score) | Best: \(score.bestScore)",
                date: score.date,
                icon: "gamecontroller.fill"
            ))
        }

        for session in simSessions {
            entries.append(JournalEntryRingoSPinner(
                id: session.id,
                type: .simulator,
                title: "Trajectory Simulation",
                subtitle: "Angle: \(Int(session.angle))° | Power: \(Int(session.power))%",
                date: session.date,
                icon: "scope"
            ))
        }

        return entries.sorted { $0.date > $1.date }
    }
}

struct JournalEntryRingoSPinner: Identifiable {
    let id: UUID
    let type: JournalEntryTypeRingoSPinner
    let title: String
    let subtitle: String
    let date: Date
    let icon: String
}

enum JournalEntryTypeRingoSPinner {
    case game, simulator, task
}

struct JournalStatsCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let gamesPlayed: Int
    let simRuns: Int
    let tasksCompleted: Int

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            HStack(spacing: adaptyW(16)) {
                JournalStatItemRingoSPinner(value: "\(gamesPlayed)", label: "Games", icon: "gamecontroller.fill")
                JournalStatItemRingoSPinner(value: "\(simRuns)", label: "Simulations", icon: "scope")
                JournalStatItemRingoSPinner(value: "\(tasksCompleted)", label: "Tasks", icon: "checkmark.circle.fill")
            }
        }
    }
}

struct JournalStatItemRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: adaptyH(6)) {
            Image(systemName: icon)
                .font(.system(size: adaptyW(20)))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

            Text(value)
                .font(.system(size: adaptyW(20), weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: adaptyW(11)))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

struct JournalEntryCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let entry: JournalEntryRingoSPinner

    var body: some View {
        HStack(spacing: adaptyW(12)) {
            VStack {
                Circle()
                    .fill(entryColor.opacity(0.15))
                    .frame(width: adaptyW(40), height: adaptyW(40))
                    .overlay {
                        Image(systemName: entry.icon)
                            .font(.system(size: adaptyW(16)))
                            .foregroundStyle(entryColor)
                    }

                Rectangle()
                    .fill(entryColor.opacity(0.2))
                    .frame(width: 2)
            }

            VStack(alignment: .leading, spacing: adaptyH(4)) {
                Text(entry.title)
                    .font(.system(size: adaptyW(15), weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(entry.subtitle)
                    .font(.system(size: adaptyW(13)))
                    .foregroundStyle(.white.opacity(0.6))

                Text(entry.date, format: .dateTime.day().month().year().hour().minute())
                    .font(.system(size: adaptyW(11)))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()
        }
        .padding(.vertical, adaptyH(4))
    }

    private var entryColor: Color {
        switch entry.type {
        case .game: ColorsRingoSPinner.accent(for: viewModel.selectedTheme)
        case .simulator: ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
        case .task: Color.green
        }
    }
}

struct JournalEmptyStateRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        VStack(spacing: adaptyH(16)) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: adaptyW(48)))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3))

            Text("No entries yet")
                .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))

            Text("Complete tasks and play mini games to fill your journal")
                .font(.system(size: adaptyW(13)))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, adaptyH(60))
    }
}

#Preview {
    NavigationStack {
        JournalViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
