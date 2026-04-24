import SwiftUI

struct RootViewMC: View {
    @State private var viewModel = ViewModelRingoSPinner()
    @EnvironmentObject private var vmod: LoaderViewModel
    var body: some View {
        ZStack {
            switch vmod.presented {
            case .splash:
                SplashViewRingoSPinner(){}
            case .main:
                ContentHostRingoSPinner()
                    .environment(viewModel)

            case .changed:
                LoaderPageView(
                    loaderViewModel: vmod,
                    url: vmod.mailLink ?? vmod.link
                )
                .onAppear {
                    AppDelegate.orientationLock = [
                        .portrait, .landscapeLeft, .landscapeRight,
                    ]
                }
            }
        }
        .minimumScaleFactor(0.8)
    }
}
