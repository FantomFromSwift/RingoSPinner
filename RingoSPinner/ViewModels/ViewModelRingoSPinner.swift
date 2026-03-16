import Foundation
import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class ViewModelRingoSPinner {

    var hasSeenOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasSeenOnboardingRingo") {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboardingRingo") }
    }

    var selectedTab: TabItemRingoSPinner = .home
    
    var selectedTheme: String = UserDefaults.standard.string(forKey: "selectedThemeRingo") ?? "default" {
        didSet { UserDefaults.standard.set(selectedTheme, forKey: "selectedThemeRingo") }
    }

    var userName: String = UserDefaults.standard.string(forKey: "userNameRingo") ?? "Athlete" {
        didSet { UserDefaults.standard.set(userName, forKey: "userNameRingo") }
    }

    var totalScore: Int = UserDefaults.standard.integer(forKey: "totalScoreRingo") {
        didSet { UserDefaults.standard.set(totalScore, forKey: "totalScoreRingo") }
    }

    var completedTasksCount: Int = UserDefaults.standard.integer(forKey: "completedTasksRingo") {
        didSet { UserDefaults.standard.set(completedTasksCount, forKey: "completedTasksRingo") }
    }

    var dailyStreak: Int = UserDefaults.standard.integer(forKey: "dailyStreakRingo") {
        didSet { UserDefaults.standard.set(dailyStreak, forKey: "dailyStreakRingo") }
    }

    var lastTrainingDate: Date = UserDefaults.standard.object(forKey: "lastTrainingDateRingo") as? Date ?? .distantPast {
        didSet { UserDefaults.standard.set(lastTrainingDate, forKey: "lastTrainingDateRingo") }
    }

    var articles: [ArticleContentRingoSPinner] = []
    var tasks: [TaskContentRingoSPinner] = []
    var miniGames: [MiniGameContentRingoSPinner] = []
    var tips: [TipContentRingoSPinner] = []

    var dailyTip: TipContentRingoSPinner? {
        guard !tips.isEmpty else { return nil }
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return tips[dayIndex % tips.count]
    }

    var dailyChallenge: TaskContentRingoSPinner? {
        guard !tasks.isEmpty else { return nil }
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return tasks[dayIndex % tasks.count]
    }

    init() {
        loadContent()
    }

    func loadContent() {
        articles = JSONLoaderRingoSPinner.load("articles")
        tasks = JSONLoaderRingoSPinner.load("tasks")
        miniGames = JSONLoaderRingoSPinner.load("miniGames")
        tips = JSONLoaderRingoSPinner.load("tips")
    }

    func addScore(_ points: Int) {
        totalScore += points
    }

    func completeTask() {
        completedTasksCount += 1
        recordTrainingDay()
    }

    func recordTrainingDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let lastDay = calendar.startOfDay(for: lastTrainingDate)

        if calendar.isDate(today, inSameDayAs: lastDay) {
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastDay, inSameDayAs: yesterday) {
            dailyStreak += 1
        } else {
            dailyStreak = 1
        }

        lastTrainingDate = .now
    }

    func isFavorited(_ itemId: String, favorites: [FavoritesRingoSPinner]) -> Bool {
        favorites.contains { $0.itemId == itemId }
    }
}

enum TabItemRingoSPinner: String, CaseIterable {
    case home = "Home"
    case journal = "Journal"
    case search = "Search"
    case favorites = "Favorites"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .journal: "book.fill"
        case .search: "magnifyingglass"
        case .favorites: "heart.fill"
        case .settings: "gearshape.fill"
        }
    }
}
