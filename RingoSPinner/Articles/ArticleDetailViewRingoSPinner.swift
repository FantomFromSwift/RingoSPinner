import SwiftUI
import SwiftData

struct ArticleDetailViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoritesRingoSPinner]
    let article: ArticleContentRingoSPinner

    private var isFavorited: Bool {
        favorites.contains { $0.itemId == article.id && $0.type == "article" }
    }

    private var heroImage: String {
        switch article.category {
        case "Reaction Training": return "art_reaction"
        case "Motor Control": return "art_motor"
        case "Throw Physics": return "art_physics"
        case "Focus Training": return "art_focus"
        case "Dexterity": return "art_dexterity"
        default: return "art_focus"
        }
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
                            .background(
                                Circle()
                                    .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                                    .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3), radius: 5)
                            )
                    }

                    Spacer()

                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                            .font(.system(size: adaptyW(18), weight: .medium))
                            .foregroundStyle(
                                isFavorited ?
                                Color.red :
                                ColorsRingoSPinner.accent(for: viewModel.selectedTheme)
                            )
                            .frame(width: adaptyW(40), height: adaptyW(40))
                            .background(
                                Circle()
                                    .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                                    .shadow(color: isFavorited ? Color.red.opacity(0.3) : ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3), radius: 5)
                            )
                    }
                }
                .padding(.horizontal, adaptyW(20))
                .padding(.top, adaptyH(8))
                .padding(.bottom, adaptyH(12))

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .bottomLeading) {
                            Image(heroImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: adaptyH(240))
                                .clipShape(RoundedRectangle(cornerRadius: adaptyW(24)))
                                .overlay(
                                    LinearGradient(
                                        colors: [.black.opacity(0.7), .clear, .black.opacity(0.4)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: adaptyW(24)))
                                )
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)

                            VStack(alignment: .leading, spacing: adaptyH(8)) {
                                HStack(spacing: adaptyW(8)) {
                                    Image(systemName: article.icon)
                                        .font(.system(size: adaptyW(14)))
                                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))

                                    Text(article.category)
                                        .font(.system(size: adaptyW(11), weight: .bold))
                                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                        .textCase(.uppercase)
                                        
                                }
                                .padding(.horizontal, adaptyW(12))
                                .padding(.vertical, adaptyW(6))
                                .background(Capsule().fill(.black.opacity(0.6)).blur(radius: 0.5))

                                Text(article.title)
                                    .font(.system(size: adaptyW(28), weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                            }
                            .padding(adaptyW(20))
                        }
                        .padding(.horizontal, adaptyW(20))
                        .padding(.bottom, adaptyH(24))

                        
                        VStack(alignment: .leading, spacing: adaptyH(24)) {
                            
                            let paragraphs = splitIntoParagraphs(article.content)
                            
                            ForEach(0..<paragraphs.count, id: \.self) { index in
                                VStack(alignment: .leading, spacing: adaptyH(12)) {
                                    if index == 0 {
                                        Text(paragraphs[index])
                                            .font(.system(size: adaptyW(17), weight: .medium))
                                            .foregroundStyle(.white)
                                            .lineSpacing(adaptyH(4))
                                    } else {
                                        Text(paragraphs[index])
                                            .font(.system(size: adaptyW(15), weight: .regular))
                                            .foregroundStyle(.white.opacity(0.8))
                                            .lineSpacing(adaptyH(6))
                                    }
                                    
                                    if index == paragraphs.count / 2 {
                                        HStack {
                                            Rectangle()
                                                .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3))
                                                .frame(height: 1)
                                            
                                            Image(systemName: "circle.circle.fill")
                                                .font(.system(size: adaptyW(10)))
                                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                            
                                            Rectangle()
                                                .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        .padding(.vertical, adaptyH(8))
                                    }
                                }
                                .padding(.horizontal, adaptyW(4))
                            }
                        }
                        .padding(.horizontal, adaptyW(24))
                        .padding(.bottom, adaptyH(40))
                        
                        
                        VStack(spacing: adaptyH(16)) {
                            HStack {
                                Image(systemName: "quote.opening")
                                    .font(.system(size: adaptyW(24)))
                                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.4))
                                Spacer()
                            }
                            
                            Text("Apply these techniques consistently to see measurable results in your RingoSPinner performance.")
                                .font(.system(size: adaptyW(16), weight: .bold, design: .serif))
                                .italic()
                                .multilineTextAlignment(.center)
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                            
                            HStack {
                                Spacer()
                                Image(systemName: "quote.closing")
                                    .font(.system(size: adaptyW(24)))
                                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.4))
                            }
                        }
                        .padding(adaptyW(24))
                        .background(
                            RoundedRectangle(cornerRadius: adaptyW(20))
                                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme).opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptyW(20))
                                        .stroke(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, adaptyW(20))
                    }
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }

    private func splitIntoParagraphs(_ text: String) -> [String] {
        let sentences = text.components(separatedBy: ". ")
        var paragraphs: [String] = []
        var currentParagraph = ""
        
        for (index, sentence) in sentences.enumerated() {
            let s = sentence.hasSuffix(".") ? sentence : sentence + "."
            currentParagraph += (currentParagraph.isEmpty ? "" : " ") + s
            
            
            if (index + 1) % 3 == 0 || index == sentences.count - 1 {
                paragraphs.append(currentParagraph)
                currentParagraph = ""
            }
        }
        
        return paragraphs
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.itemId == article.id && $0.type == "article" }) {
            modelContext.delete(existing)
        } else {
            let fav = FavoritesRingoSPinner(type: "article", itemId: article.id)
            modelContext.insert(fav)
        }
        try? modelContext.save()
    }
}

#Preview {
    let article = ArticleContentRingoSPinner(
        id: "preview",
        title: "Preview Article",
        content: "This is a sample article for preview purposes.",
        category: "Focus",
        icon: "brain.fill"
    )
    NavigationStack {
        ArticleDetailViewRingoSPinner(article: article)
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
