import SwiftUI
import UIKit


extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

private struct SwipeBackControllerSetup: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SwipeBackSetupViewController {
        SwipeBackSetupViewController()
    }

    func updateUIViewController(_ uiViewController: SwipeBackSetupViewController, context: Context) {}
}

private final class SwipeBackSetupViewController: UIViewController {
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if let nc = findNavigationController() {
            nc.interactivePopGestureRecognizer?.isEnabled = true
            nc.interactivePopGestureRecognizer?.delegate = nc
        }
    }

    private func findNavigationController() -> UINavigationController? {
        var current: UIViewController? = self
        while let vc = current {
            if let nc = vc.navigationController { return nc }
            current = vc.parent
        }
        return nil
    }
}

struct NavigationBackWithSwipeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .background(SwipeBackControllerSetup())
    }
}

extension View {
    func navigationBackWithSwipe() -> some View {
        modifier(NavigationBackWithSwipeModifier())
    }
}

