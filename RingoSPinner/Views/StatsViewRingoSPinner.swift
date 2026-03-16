import SwiftUI
import SwiftData
import Charts

struct StatsViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MiniGameScoreRingoSPinner.date)
    private var gameScores: [MiniGameScoreRingoSPinner]
    @Query(sort: \SimulatorSessionRingoSPinner.date)
    private var simSessions: [SimulatorSessionRingoSPinner]

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Statistics",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView {
                    VStack(spacing: adaptyH(16)) {
                        StatsOverviewCardRingoSPinner(
                            totalGames: gameScores.count,
                            totalSims: simSessions.count,
                            totalTasks: viewModel.completedTasksCount,
                            totalScore: viewModel.totalScore
                        )

                        if !gameScores.isEmpty {
                            StatsChartCardRingoSPinner(
                                title: "Game Scores",
                                scores: gameScores
                            )
                        }

                        if !simSessions.isEmpty {
                            SimStatsCardRingoSPinner(sessions: simSessions)
                        }

                        StatsStreakCardRingoSPinner()
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(8))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }
}

struct StatsOverviewCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let totalGames: Int
    let totalSims: Int
    let totalTasks: Int
    let totalScore: Int

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: adaptyH(16)) {
                StatsMetricRingoSPinner(value: "\(totalGames)", label: "Games Played", icon: "gamecontroller.fill")
                StatsMetricRingoSPinner(value: "\(totalSims)", label: "Simulations", icon: "scope")
                StatsMetricRingoSPinner(value: "\(totalTasks)", label: "Tasks Done", icon: "checkmark.circle.fill")
                StatsMetricRingoSPinner(value: "\(totalScore)", label: "Total Score", icon: "star.fill")
            }
        }
    }
}

struct StatsMetricRingoSPinner: View {
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
                .font(.system(size: adaptyW(22), weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: adaptyW(11)))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatsChartCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let title: String
    let scores: [MiniGameScoreRingoSPinner]

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(alignment: .leading, spacing: adaptyH(10)) {
                Text(title)
                    .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Chart(scores.suffix(15)) { score in
                    BarMark(
                        x: .value("Date", score.date, unit: .day),
                        y: .value("Score", score.score)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .frame(height: adaptyH(180))
            }
        }
    }
}

struct SimStatsCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let sessions: [SimulatorSessionRingoSPinner]

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(alignment: .leading, spacing: adaptyH(10)) {
                Text("Simulator Performance")
                    .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                let avgSuccess = sessions.isEmpty ? 0 : sessions.map(\.successRate).reduce(0, +) / Double(sessions.count)

                HStack {
                    Text("Avg Success Rate")
                        .font(.system(size: adaptyW(13)))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("\(Int(avgSuccess))%")
                        .font(.system(size: adaptyW(16), weight: .bold, design: .rounded))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                }

                Chart(sessions.suffix(10)) { session in
                    LineMark(
                        x: .value("Date", session.date, unit: .day),
                        y: .value("Success", session.successRate)
                    )
                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", session.date, unit: .day),
                        y: .value("Success", session.successRate)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: adaptyH(140))
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
            }
        }
    }
}

struct StatsStreakCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            HStack {
                VStack(alignment: .leading, spacing: adaptyH(4)) {
                    Text("Current Streak")
                        .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Keep training daily to build your streak")
                        .font(.system(size: adaptyW(12)))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                VStack {
                    Text("\(viewModel.dailyStreak)")
                        .font(.system(size: adaptyW(36), weight: .black, design: .rounded))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                    Text("days")
                        .font(.system(size: adaptyW(12)))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StatsViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
