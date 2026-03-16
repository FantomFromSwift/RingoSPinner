import SwiftUI
import SwiftData

struct MainViewRingoSPinner: View {
    @State private var viewModel = ViewModelRingoSPinner()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashViewRingoSPinner {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            } else if !viewModel.hasSeenOnboarding {
                OnboardingViewRingoSPinner {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.hasSeenOnboarding = true
                    }
                }
                .transition(.opacity)
            } else {
                ContentHostRingoSPinner()
                    .environment(viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: viewModel.hasSeenOnboarding)
    }
}

struct ContentHostRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        ZStack(alignment: .bottom) {
            ZStack {
                switch viewModel.selectedTab {
                case .home:
                    NavigationStack {
                        HomeViewRingoSPinner()
                    }
                case .journal:
                    NavigationStack {
                        JournalViewRingoSPinner()
                    }
                case .search:
                    NavigationStack {
                        SearchViewRingoSPinner()
                    }
                case .favorites:
                    NavigationStack {
                        FavoritesViewRingoSPinner()
                    }
                case .settings:
                    NavigationStack {
                        SettingsViewRingoSPinner()
                    }
                }
            }

            CustomTabBarRingoSPinner(
                selectedTab: $vm.selectedTab,
                theme: viewModel.selectedTheme
            )
        }
    }
}

#Preview {
    MainViewRingoSPinner()
        .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
