import SwiftUI
import SwiftData

struct HomeViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Query(sort: \MiniGameScoreRingoSPinner.date, order: .reverse)
    private var recentScores: [MiniGameScoreRingoSPinner]

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "RingoSPinner",
                    showSettings: true,
                    theme: viewModel.selectedTheme
                ) {} settingsAction: {
                    viewModel.selectedTab = .settings
                }

                ScrollView {
                    VStack(spacing: adaptyH(16)) {
                        HomeDailyTipSectionRingoSPinner()
                        HomeProgressSectionRingoSPinner()
                        HomeQuickStartSectionRingoSPinner()
                        HomeDailyChallengeSectionRingoSPinner()
                        HomeReactionMeterSectionRingoSPinner()
                        HomeRecentActivitySectionRingoSPinner(scores: recentScores)
                        HomeAchievementsSectionRingoSPinner()
                        HomeQuickLaunchSectionRingoSPinner()
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(8))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(for: String.self) { route in
            switch route {
            case "miniGamesHub": MiniGamesHubViewRingoSPinner()
            case "articles": ArticlesViewRingoSPinner()
            case "tasks": TasksViewRingoSPinner()
            case "simulator": TrajectorySimulatorViewRingoSPinner()
            case "stats": StatsViewRingoSPinner()
            case "coordinator": CoordinationTrainerViewRingoSPinner()
            case "dailyChallenge": DailyChallengeViewRingoSPinner()
            default: EmptyView()
            }
        }
        .navigationDestination(for: TaskContentRingoSPinner.self) { task in
            TaskDetailViewRingoSPinner(task: task)
        }
    }
}

struct HomeDailyTipSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        if let tip = viewModel.dailyTip {
            CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                HStack(spacing: adaptyW(12)) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: adaptyW(24)))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

                    VStack(alignment: .leading, spacing: adaptyH(4)) {
                        Text("Daily Tip")
                            .font(.system(size: adaptyW(11), weight: .semibold))
                            .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                            .textCase(.uppercase)

                        Text(tip.title)
                            .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(tip.content)
                            .font(.system(size: adaptyW(13)))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(3)
                    }
                }
            }
        }
    }
}

struct HomeProgressSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(spacing: adaptyH(12)) {
                HStack {
                    Text("Your Progress")
                        .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("Level \(viewModel.totalScore / 100 + 1)")
                        .font(.system(size: adaptyW(13), weight: .semibold))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                        .padding(.horizontal, adaptyW(10))
                        .padding(.vertical, adaptyH(4))
                        .background(
                            Capsule()
                                .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.15))
                        )
                }

                HStack(spacing: adaptyW(24)) {
                    ProgressRingViewRingoSPinner(
                        progress: Double(viewModel.completedTasksCount % 20) / 20.0,
                        theme: viewModel.selectedTheme,
                        size: 90
                    )

                    VStack(alignment: .leading, spacing: adaptyH(10)) {
                        HomeStatRowRingoSPinner(
                            icon: "flame.fill",
                            label: "Streak",
                            value: "\(viewModel.dailyStreak) days",
                            theme: viewModel.selectedTheme
                        )
                        HomeStatRowRingoSPinner(
                            icon: "star.fill",
                            label: "Score",
                            value: "\(viewModel.totalScore)",
                            theme: viewModel.selectedTheme
                        )
                        HomeStatRowRingoSPinner(
                            icon: "checkmark.circle.fill",
                            label: "Tasks",
                            value: "\(viewModel.completedTasksCount)",
                            theme: viewModel.selectedTheme
                        )
                    }
                }
            }
        }
    }
}

struct HomeStatRowRingoSPinner: View {
    let icon: String
    let label: String
    let value: String
    let theme: String

    var body: some View {
        HStack(spacing: adaptyW(8)) {
            Image(systemName: icon)
                .font(.system(size: adaptyW(14)))
                .foregroundStyle(ColorsRingoSPinner.accent(for: theme))

            Text(label)
                .font(.system(size: adaptyW(13)))
                .foregroundStyle(.white.opacity(0.6))

            Spacer()

            Text(value)
                .font(.system(size: adaptyW(14), weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct HomeQuickStartSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        NavigationLink(value: "miniGamesHub") {
            CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                HStack {
                    VStack(alignment: .leading, spacing: adaptyH(6)) {
                        Text("Quick Start")
                            .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Jump into a mini game")
                            .font(.system(size: adaptyW(13)))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: adaptyW(40)))
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
                        .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.5), radius: 10)
                }
            }
        }
    }
}

struct HomeDailyChallengeSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        if let challenge = viewModel.dailyChallenge {
            NavigationLink(value: challenge) {
                CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                    HStack {
                        VStack(alignment: .leading, spacing: adaptyH(4)) {
                            HStack(spacing: adaptyW(6)) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .foregroundStyle(ColorsRingoSPinner.secondary(for: viewModel.selectedTheme))
                                Text("Daily Challenge")
                                    .font(.system(size: adaptyW(11), weight: .semibold))
                                    .foregroundStyle(ColorsRingoSPinner.secondary(for: viewModel.selectedTheme))
                                    .textCase(.uppercase)
                            }

                            Text(challenge.title)
                                .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            HStack {
                                RoundedRectangle(cornerRadius: adaptyW(6))
                                    .fill(.clear)
                                    .frame(width: adaptyW(24), height: adaptyW(24))
                                    .background {
                                        Image(AssetMapperRingoSPinner.getIcon(for: challenge.id))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: adaptyW(31), height: adaptyW(31))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: adaptyW(6)))
                                
                                Text(challenge.description)
                                    .font(.system(size: adaptyW(12)))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
        }
    }
}

struct HomeReactionMeterSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Query(
        filter: #Predicate<MiniGameScoreRingoSPinner> { $0.gameName == "Reaction Ring" },
        sort: \MiniGameScoreRingoSPinner.date,
        order: .reverse
    )
    private var reactionScores: [MiniGameScoreRingoSPinner]

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(alignment: .leading, spacing: adaptyH(8)) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                    Text("Reaction Meter")
                        .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                let bestReaction = reactionScores.first?.bestScore ?? 0
                HStack {
                    Text("Best Time")
                        .font(.system(size: adaptyW(13)))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(bestReaction > 0 ? "\(bestReaction) ms" : "Not tested")
                        .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                }

                RoundedRectangle(cornerRadius: adaptyW(4))
                    .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.2))
                    .frame(height: adaptyH(6))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: adaptyW(4))
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                        ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: adaptyW(CGFloat(min(bestReaction, 300)) / 300.0 * 300))
                    }
            }
        }
    }
}

struct HomeRecentActivitySectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let scores: [MiniGameScoreRingoSPinner]

    var body: some View {
        if !scores.isEmpty {
            CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                VStack(alignment: .leading, spacing: adaptyH(8)) {
                    Text("Recent Activity")
                        .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    ForEach(scores.prefix(3)) { score in
                        HStack {
                            Circle()
                                .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.2))
                                .frame(width: adaptyW(32), height: adaptyW(32))
                                .overlay {
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.system(size: adaptyW(14)))
                                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                }

                            VStack(alignment: .leading) {
                                Text(score.gameName)
                                    .font(.system(size: adaptyW(13), weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(score.date, format: .dateTime.day().month().hour().minute())
                                    .font(.system(size: adaptyW(11)))
                                    .foregroundStyle(.white.opacity(0.5))
                            }

                            Spacer()

                            Text("\(score.score) pts")
                                .font(.system(size: adaptyW(14), weight: .bold, design: .rounded))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                        }
                    }
                }
            }
        }
    }
}

struct HomeAchievementsSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    private let achievements = [
        ("First Throw", "target", 1),
        ("10 Tasks", "checkmark.seal.fill", 10),
        ("50 Score", "star.fill", 50),
        ("Week Streak", "flame.fill", 7)
    ]

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(alignment: .leading, spacing: adaptyH(10)) {
                Text("Achievements")
                    .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                ScrollView(.horizontal) {
                    HStack(spacing: adaptyW(12)) {
                        ForEach(achievements, id: \.0) { ach in
                            let unlocked = isUnlocked(ach)
                            VStack(spacing: adaptyH(6)) {
                                Image(systemName: ach.1)
                                    .font(.system(size: adaptyW(24)))
                                    .foregroundStyle(
                                        unlocked ?
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme) :
                                        Color.gray.opacity(0.4)
                                    )
                                    .frame(width: adaptyW(50), height: adaptyW(50))
                                    .background(
                                        Circle()
                                            .fill(
                                                unlocked ?
                                                ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.15) :
                                                Color.gray.opacity(0.1)
                                            )
                                    )

                                Text(ach.0)
                                    .font(.system(size: adaptyW(10), weight: .medium))
                                    .foregroundStyle(unlocked ? .white : .gray)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func isUnlocked(_ achievement: (String, String, Int)) -> Bool {
        switch achievement.0 {
        case "First Throw": viewModel.completedTasksCount >= 1
        case "10 Tasks": viewModel.completedTasksCount >= 10
        case "50 Score": viewModel.totalScore >= 50
        case "Week Streak": viewModel.dailyStreak >= 7
        default: false
        }
    }
}

struct HomeQuickLaunchSectionRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    private let quickActions: [(String, String, String)] = [
        ("Articles", "book.fill", "articles"),
        ("Tasks", "list.clipboard.fill", "tasks"),
        ("Simulator", "scope", "simulator"),
        ("Stats", "chart.bar.fill", "stats")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: adaptyH(10)) {
            Text("Quick Launch")
                .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.leading, adaptyW(4))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: adaptyW(12)) {
                ForEach(quickActions, id: \.0) { action in
                    NavigationLink(value: action.2) {
                        HStack(spacing: adaptyW(10)) {
                            Image(systemName: action.1)
                                .font(.system(size: adaptyW(18)))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                .frame(width: adaptyW(36), height: adaptyW(36))
                                .background(
                                    Circle()
                                        .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.15))
                                )

                            Text(action.0)
                                .font(.system(size: adaptyW(14), weight: .semibold))
                                .foregroundStyle(.white)

                            Spacer()
                        }
                        .padding(adaptyW(12))
                        .background(
                            RoundedRectangle(cornerRadius: adaptyW(14))
                                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                                .overlay {
                                    RoundedRectangle(cornerRadius: adaptyW(14))
                                        .stroke(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.1), lineWidth: 0.5)
                                }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
