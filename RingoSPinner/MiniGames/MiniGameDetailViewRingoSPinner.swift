import SwiftUI

struct GameRouteRingoSPinner: Hashable {
    let id: String
}

struct MiniGameDetailViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    let game: MiniGameContentRingoSPinner

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: game.name,
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView {
                    VStack(spacing: adaptyH(24)) {
                        
                        VStack(spacing: adaptyH(16)) {
                            ZStack {
                                Circle()
                                    .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.15))
                                    .frame(width: adaptyW(100), height: adaptyW(100))
                                
                                Image(systemName: game.icon)
                                    .font(.system(size: adaptyW(44)))
                                    .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                    .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.5), radius: 10)
                            }

                            Text(game.difficulty)
                                .font(.system(size: adaptyW(12), weight: .bold))
                                .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                                .padding(.horizontal, adaptyW(12))
                                .padding(.vertical, adaptyH(4))
                                .background(
                                    Capsule()
                                        .fill(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.12))
                                )
                        }
                        .padding(.top, adaptyH(20))

                        
                        VStack(alignment: .leading, spacing: adaptyH(12)) {
                            Text("About the Game")
                                .font(.system(size: adaptyW(18), weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text(game.description)
                                .font(.system(size: adaptyW(15)))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineSpacing(4)
                        }
                        .padding(adaptyW(20))
                        .background(
                            RoundedRectangle(cornerRadius: adaptyW(20))
                                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                        )

                        Spacer(minLength: adaptyH(40))

                        NavigationLink(value: GameRouteRingoSPinner(id: game.id)) {
                            HStack {
                                Text("Play Now")
                                Image(systemName: "play.fill")
                            }
                            .font(.system(size: adaptyW(18), weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: adaptyH(56))
                            .background(
                                LinearGradient(
                                    colors: [
                                        ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                                        ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: adaptyW(16)))
                            .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.4), radius: 10)
                        }
                    }
                    .padding(.horizontal, adaptyW(20))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
        .navigationDestination(for: GameRouteRingoSPinner.self) { route in
            switch route.id {
            case "game1": RingTossPrecisionViewRingoSPinner()
            case "game2": MovingTargetViewRingoSPinner()
            case "game3": ReactionRingViewRingoSPinner()
            case "game4": MultiTargetComboViewRingoSPinner()
            case "game5": BalanceRingViewRingoSPinner()
            case "game6": RingRushViewRingoSPinner()
            case "game9": SpeedRingsViewRingoSPinner()
            default: EmptyView()
            }
        }
    }
}
