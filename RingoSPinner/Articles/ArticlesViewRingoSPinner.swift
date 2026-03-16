import SwiftUI
import SwiftData

struct ArticlesViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String = "All"

    private var categories: [String] {
        var cats = ["All"]
        let unique = Set(viewModel.articles.map(\.category))
        cats.append(contentsOf: unique.sorted())
        return cats
    }

    private var filtered: [ArticleContentRingoSPinner] {
        if selectedCategory == "All" { return viewModel.articles }
        return viewModel.articles.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Articles",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView(.horizontal) {
                    HStack(spacing: adaptyW(8)) {
                        ForEach(categories, id: \.self) { cat in
                            Button(cat) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCategory = cat
                                }
                            }
                            .font(.system(size: adaptyW(13), weight: selectedCategory == cat ? .bold : .medium))
                            .foregroundStyle(selectedCategory == cat ? .white : .white.opacity(0.5))
                            .padding(.horizontal, adaptyW(14))
                            .padding(.vertical, adaptyH(7))
                            .background(
                                Capsule()
                                    .fill(
                                        selectedCategory == cat ?
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

                ScrollView {
                    LazyVStack(spacing: adaptyH(10)) {
                        ForEach(filtered) { article in
                            NavigationLink(value: article) {
                                ArticleCardRingoSPinner(article: article)
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
        .navigationDestination(for: ArticleContentRingoSPinner.self) { article in
            ArticleDetailViewRingoSPinner(article: article)
        }
    }
}

struct ArticleCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let article: ArticleContentRingoSPinner

    var body: some View {
        HStack(spacing: adaptyW(12)) {
            RoundedRectangle(cornerRadius: adaptyW(12))
                .fill(.clear)
                .frame(width: adaptyW(44), height: adaptyW(44))
                .background {
                    Image(AssetMapperRingoSPinner.getIcon(for: article.id, category: article.category))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: adaptyW(56), height: adaptyW(56))
                }
                .clipShape(RoundedRectangle(cornerRadius: adaptyW(12)))

            VStack(alignment: .leading, spacing: adaptyH(4)) {
                Text(article.title)
                    .font(.system(size: adaptyW(14), weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(article.category)
                    .font(.system(size: adaptyW(11), weight: .medium))
                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.7))
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
                .overlay {
                    RoundedRectangle(cornerRadius: adaptyW(14))
                        .stroke(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.08), lineWidth: 0.5)
                }
        )
    }
}

#Preview {
    NavigationStack {
        ArticlesViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
