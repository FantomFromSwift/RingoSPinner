import SwiftUI
import SwiftData

struct FavoritesViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoritesRingoSPinner]
    @Query private var gameScores: [MiniGameScoreRingoSPinner]
    @State private var selectedFilter: FavFilterRingoSPinner = .all

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Favorites",
                    theme: viewModel.selectedTheme
                )

                FavoritesFilterBarRingoSPinner(
                    selected: $selectedFilter,
                    theme: viewModel.selectedTheme
                )

                ScrollView {
                    LazyVStack(spacing: adaptyH(10)) {
                        FavoritesStatsRingoSPinner(
                            totalFavs: favorites.count,
                            articles: favoriteArticles.count,
                            tasks: favoriteTasks.count
                        )

                        if filteredItems.isEmpty {
                            FavoritesEmptyRingoSPinner()
                        } else {
                            ForEach(filteredItems, id: \.id) { fav in
                                Group {
                                    if fav.type == "article",
                                       let article = viewModel.articles.first(where: { $0.id == fav.itemId }) {
                                        NavigationLink(value: article) {
                                            FavoriteItemRowRingoSPinner(favorite: fav) {
                                                removeFavorite(fav)
                                            }
                                        }
                                    } else if fav.type == "task",
                                              let task = viewModel.tasks.first(where: { $0.id == fav.itemId }) {
                                        NavigationLink(value: task) {
                                            FavoriteItemRowRingoSPinner(favorite: fav) {
                                                removeFavorite(fav)
                                            }
                                        }
                                    } else if fav.type == "game",
                                              let game = viewModel.miniGames.first(where: { $0.id == fav.itemId }) {
                                        NavigationLink(value: game) {
                                            FavoriteItemRowRingoSPinner(favorite: fav) {
                                                removeFavorite(fav)
                                            }
                                        }
                                    } else {
                                        FavoriteItemRowRingoSPinner(favorite: fav) {
                                            removeFavorite(fav)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(8))
                    .contentMargins(.bottom, adaptyH(100))
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(for: ArticleContentRingoSPinner.self) { article in
            ArticleDetailViewRingoSPinner(article: article)
        }
        .navigationDestination(for: TaskContentRingoSPinner.self) { task in
            TaskDetailViewRingoSPinner(task: task)
        }
        .navigationDestination(for: MiniGameContentRingoSPinner.self) { game in
            MiniGameDetailViewRingoSPinner(game: game)
        }
    }

    private var favoriteArticles: [FavoritesRingoSPinner] {
        favorites.filter { $0.type == "article" }
    }

    private var favoriteTasks: [FavoritesRingoSPinner] {
        favorites.filter { $0.type == "task" }
    }

    private var filteredItems: [FavoritesRingoSPinner] {
        switch selectedFilter {
        case .all: favorites
        case .articles: favoriteArticles
        case .tasks: favoriteTasks
        case .games: favorites.filter { $0.type == "game" }
        }
    }

    private func removeFavorite(_ fav: FavoritesRingoSPinner) {
        modelContext.delete(fav)
        try? modelContext.save()
    }
}

enum FavFilterRingoSPinner: String, CaseIterable {
    case all = "All"
    case articles = "Articles"
    case tasks = "Tasks"
    case games = "Games"
}

struct FavoritesFilterBarRingoSPinner: View {
    @Binding var selected: FavFilterRingoSPinner
    let theme: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: adaptyW(8)) {
                ForEach(FavFilterRingoSPinner.allCases, id: \.self) { filter in
                    Button(filter.rawValue) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = filter
                        }
                    }
                    .font(.system(size: adaptyW(13), weight: selected == filter ? .bold : .medium))
                    .foregroundStyle(selected == filter ? .white : .white.opacity(0.5))
                    .padding(.horizontal, adaptyW(16))
                    .padding(.vertical, adaptyH(8))
                    .background(
                        Capsule()
                            .fill(
                                selected == filter ?
                                ColorsRingoSPinner.accent(for: theme).opacity(0.3) :
                                ColorsRingoSPinner.cardBackground(for: theme)
                            )
                    )
                }
            }
            .padding(.horizontal, adaptyW(16))
            .padding(.vertical, adaptyH(8))
        }
        .scrollIndicators(.hidden)
    }
}

struct FavoritesStatsRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let totalFavs: Int
    let articles: Int
    let tasks: Int

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            HStack {
                FavStatItemRingoSPinner(value: "\(totalFavs)", label: "Total")
                Spacer()
                FavStatItemRingoSPinner(value: "\(articles)", label: "Articles")
                Spacer()
                FavStatItemRingoSPinner(value: "\(tasks)", label: "Tasks")
            }
        }
    }
}

struct FavStatItemRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: adaptyH(4)) {
            Text(value)
                .font(.system(size: adaptyW(22), weight: .bold, design: .rounded))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
            Text(label)
                .font(.system(size: adaptyW(11)))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

struct FavoriteItemRowRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let favorite: FavoritesRingoSPinner
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: adaptyW(12)) {
            Image(systemName: iconForType)
                .font(.system(size: adaptyW(18)))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                .frame(width: adaptyW(40), height: adaptyW(40))
                .background(
                    RoundedRectangle(cornerRadius: adaptyW(10))
                        .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.12))
                )

            VStack(alignment: .leading, spacing: adaptyH(2)) {
                Text(displayTitle)
                    .font(.system(size: adaptyW(14), weight: .semibold))
                    .foregroundStyle(.white)

                Text(favorite.type.capitalized)
                    .font(.system(size: adaptyW(12)))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Button("Remove", systemImage: "heart.fill") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    onRemove()
                }
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
        }
        .padding(adaptyW(12))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(12))
                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
        )
    }

    private var iconForType: String {
        switch favorite.type {
        case "article": "book.fill"
        case "task": "list.clipboard.fill"
        case "game": "gamecontroller.fill"
        default: "heart.fill"
        }
    }

    private var displayTitle: String {
        if let article = viewModel.articles.first(where: { $0.id == favorite.itemId }) {
            return article.title
        }
        if let task = viewModel.tasks.first(where: { $0.id == favorite.itemId }) {
            return task.title
        }
        if let game = viewModel.miniGames.first(where: { $0.id == favorite.itemId }) {
            return game.name
        }
        return favorite.itemId.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

struct FavoritesEmptyRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        VStack(spacing: adaptyH(16)) {
            Image(systemName: "heart.slash")
                .font(.system(size: adaptyW(48)))
                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3))

            Text("No favorites yet")
                .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))

            Text("Tap the heart icon on articles and tasks to add them here")
                .font(.system(size: adaptyW(13)))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, adaptyH(60))
    }
}

#Preview {
    NavigationStack {
        FavoritesViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
