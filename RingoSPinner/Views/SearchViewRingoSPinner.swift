import SwiftUI
import SwiftData

struct SearchViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @State private var searchText = ""

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Search",
                    theme: viewModel.selectedTheme
                )

                SearchBarRingoSPinner(
                    text: $searchText,
                    theme: viewModel.selectedTheme
                )
                .padding(.horizontal, adaptyW(16))
                .padding(.top, adaptyH(8))

                ScrollView {
                    LazyVStack(spacing: adaptyH(16)) {
                        if !filteredArticles.isEmpty {
                            SearchSectionRingoSPinner(
                                title: "Articles",
                                icon: "book.fill"
                            ) {
                                ForEach(filteredArticles) { article in
                                    NavigationLink(value: article) {
                                        SearchItemCardRingoSPinner(
                                            id: article.id,
                                            title: article.title,
                                            subtitle: article.category
                                        )
                                    }
                                }
                            }
                        }

                        if !filteredTasks.isEmpty {
                            SearchSectionRingoSPinner(
                                title: "Tasks",
                                icon: "list.clipboard.fill"
                            ) {
                                ForEach(filteredTasks) { task in
                                    NavigationLink(value: task) {
                                        SearchItemCardRingoSPinner(
                                            id: task.id,
                                            title: task.title,
                                            subtitle: task.difficulty
                                        )
                                    }
                                }
                            }
                        }

                        if !filteredGames.isEmpty {
                            SearchSectionRingoSPinner(
                                title: "Mini Games",
                                icon: "gamecontroller.fill"
                            ) {
                                ForEach(filteredGames) { game in
                                    NavigationLink(value: game) {
                                        SearchItemCardRingoSPinner(
                                            id: game.id,
                                            title: game.name,
                                            subtitle: game.difficulty
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(12))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
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

    private var filteredArticles: [ArticleContentRingoSPinner] {
        if searchText.isEmpty { return viewModel.articles }
        return viewModel.articles.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredTasks: [TaskContentRingoSPinner] {
        if searchText.isEmpty { return viewModel.tasks }
        return viewModel.tasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.difficulty.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredGames: [MiniGameContentRingoSPinner] {
        if searchText.isEmpty { return viewModel.miniGames }
        return viewModel.miniGames.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.difficulty.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct SearchBarRingoSPinner: View {
    @Binding var text: String
    let theme: String

    var body: some View {
        HStack(spacing: adaptyW(10)) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ColorsRingoSPinner.accent(for: theme).opacity(0.6))

            TextField("Search articles, tasks, games...", text: $text)
                .font(.system(size: adaptyW(15)))
                .foregroundStyle(.white)
                .tint(ColorsRingoSPinner.accent(for: theme))

            if !text.isEmpty {
                Button("Clear", systemImage: "xmark.circle.fill") {
                    text = ""
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(adaptyW(12))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(14))
                .fill(ColorsRingoSPinner.cardBackground(for: theme))
                .overlay {
                    RoundedRectangle(cornerRadius: adaptyW(14))
                        .stroke(ColorsRingoSPinner.accent(for: theme).opacity(0.2), lineWidth: 0.5)
                }
        )
    }
}

struct SearchSectionRingoSPinner<Content: View>: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: adaptyH(8)) {
            HStack(spacing: adaptyW(8)) {
                Image(systemName: icon)
                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                Text(title)
                    .font(.system(size: adaptyW(17), weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            content
        }
    }
}

struct SearchItemCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let id: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: adaptyW(12)) {
            RoundedRectangle(cornerRadius: adaptyW(10))
                .fill(.clear)
                .frame(width: adaptyW(40), height: adaptyW(40))
                .background {
                    Image(AssetMapperRingoSPinner.getIcon(for: id))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: adaptyW(51), height: adaptyW(51))
                }
                .clipShape(RoundedRectangle(cornerRadius: adaptyW(10)))

            VStack(alignment: .leading, spacing: adaptyH(2)) {
                Text(title)
                    .font(.system(size: adaptyW(14), weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: adaptyW(12)))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: adaptyW(12)))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(adaptyW(12))
        .background(
            RoundedRectangle(cornerRadius: adaptyW(12))
                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
        )
    }
}

#Preview {
    NavigationStack {
        SearchViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
