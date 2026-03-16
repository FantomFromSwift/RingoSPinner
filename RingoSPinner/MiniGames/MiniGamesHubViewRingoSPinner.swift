import SwiftUI
import SwiftData

struct MiniGamesHubViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Mini Games",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: adaptyW(12)
                    ) {
                        ForEach(viewModel.miniGames) { game in
                            NavigationLink(value: game) {
                                MiniGameCardRingoSPinner(
                                    id: game.id,
                                    name: game.name,
                                    difficulty: game.difficulty,
                                    color: gameColor(for: game.difficulty)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(12))
                    .contentMargins(.bottom, adaptyH(40))
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .navigationDestination(for: MiniGameContentRingoSPinner.self) { game in
            MiniGameDetailViewRingoSPinner(game: game)
        }
    }

    private func gameColor(for difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .blue
        case "Medium": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
}

struct MiniGameCardRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let id: String
    let name: String
    let difficulty: String
    let color: Color

    var body: some View {
        VStack(spacing: adaptyH(10)) {
            Circle()
                .fill(.clear)
                .frame(width: adaptyW(56), height: adaptyW(56))
                .background {
                    Image(AssetMapperRingoSPinner.getIcon(for: id))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: adaptyW(72), height: adaptyW(72))
                }
                .clipShape(Circle())
                .shadow(color: color.opacity(0.4), radius: 8)

            Text(name)
                .font(.system(size: adaptyW(13), weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(difficulty)
                .font(.system(size: adaptyW(10), weight: .semibold))
                .foregroundStyle(color)
                .padding(.horizontal, adaptyW(8))
                .padding(.vertical, adaptyH(3))
                .background(
                    Capsule()
                        .fill(color.opacity(0.12))
                )
        }
        .padding(adaptyW(16))
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: adaptyW(18))
                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                .overlay {
                    RoundedRectangle(cornerRadius: adaptyW(18))
                        .stroke(color.opacity(0.15), lineWidth: 1)
                }
        )
    }
}

#Preview {
    NavigationStack {
        MiniGamesHubViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
