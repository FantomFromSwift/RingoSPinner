import SwiftUI
import SwiftData
internal import StoreKit

@main
struct RingoSPinnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        createApplicationSupportDirectory()
    }
    
    var body: some Scene {
        WindowGroup {
            MainViewRingoSPinner()
        }
        .modelContainer(for: [
            MiniGameScoreRingoSPinner.self,
            SimulatorSessionRingoSPinner.self,
            FavoritesRingoSPinner.self
        ])
    }
    
    private func createApplicationSupportDirectory() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        
        if !fileManager.fileExists(atPath: appSupportURL.path) {
            do {
                try fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("CoreData: Error creating Application Support directory: \(error)")
            }
        }
    }
}


@MainActor
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        SKPaymentQueue.default().add(IAPManagerVE.shared)
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(IAPManagerVE.shared)
    }
}
