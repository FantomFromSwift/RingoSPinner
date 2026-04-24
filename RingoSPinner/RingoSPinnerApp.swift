import FirebaseCore
import FirebaseMessaging
internal import StoreKit
import SwiftData
import SwiftUI
import UserNotifications

@main
struct RingoSPinnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var loaderVM = LoaderViewModel()
    @State private var iapManager = IAPManagerVE.shared
    init() {
        createApplicationSupportDirectory()
    }
    
    var body: some Scene {
        WindowGroup {
//            MainViewRingoSPinner()
            RootViewMC()
                .environment(iapManager)
                .environmentObject(loaderVM)
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


final class AppDelegate: NSObject,
    UIApplicationDelegate
{

    private let appsFlyerDevKey = "AppsFlyer Dev Key"  // ИЗМЕНИТЬ
    private let appleAppID = "6760655386"  // ИЗМЕНИТЬ

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(IAPManagerVE.shared)
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        log("🚀 didFinishLaunching")

        SKPaymentQueue.default().add(IAPManagerVE.shared)

        UserDefaults.standard.set(false, forKey: "apnsReady")
        UserDefaults.standard.removeObject(forKey: "apnsTokenHex")

        //        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        log("✅ Firebase configured")

        //        let af = AppsFlyerLib.shared()
        //        af.appsFlyerDevKey = appsFlyerDevKey
        //        af.appleAppID      = appleAppID
        //        af.delegate        = self
        //        af.isDebug         = false

        UNUserNotificationCenter.current().delegate = self
        //        requestPushPermissions()

        return true
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        //        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        //        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        print("🎯 AppsFlyer Conversion Data: \(data)")
    }

    func onConversionDataFail(_ error: Error) {
        print("❌ AppsFlyer error: \(error.localizedDescription)")
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken

        log("✅ APNs token set")

        Messaging.messaging().token { token, error in
            if let token = token {
                UserDefaults.standard.set(token, forKey: "fcmToken")
                NotificationCenter.default.post(
                    name: .fcmTokenDidUpdate,
                    object: nil,
                    userInfo: ["token": token]
                )
                self.log("🔥 FCM token: \(token)")
            } else if let error = error {
                self.log("❌ FCM token error: \(error)")
            }
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        log("❌ APNs register failed: \(error)")
        UserDefaults.standard.set(false, forKey: "apnsReady")
    }

    fileprivate func log(_ message: String) {
        print("[AppDelegate] \(message)")
    }

    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(
                            .iOS(interfaceOrientations: orientationLock)
                        )
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock == .landscape {
                    UIDevice.current.setValue(
                        UIInterfaceOrientation.landscapeRight.rawValue,
                        forKey: "orient"
                    )
                } else {
                    UIDevice.current.setValue(
                        UIInterfaceOrientation.portrait.rawValue,
                        forKey: "orient"
                    )
                }
            }
        }
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken, !token.isEmpty else {
            log("⚠️ didReceiveRegistrationToken empty")
            return
        }
        UserDefaults.standard.set(token, forKey: "fcmToken")
        log("🔥 FCM token (delegate): \(token)")
        NotificationCenter.default.post(
            name: .fcmTokenDidUpdate,
            object: nil,
            userInfo: ["token": token]
        )
    }
}

extension Notification.Name {
    static let fcmTokenDidUpdate = Notification.Name("fcmTokenDidUpdate")
    static let pushPermissionGranted = Notification.Name(
        "pushPermissionGranted"
    )
    static let pushPermissionDenied = Notification.Name("pushPermissionDenied")
    static let apnsTokenDidUpdate = Notification.Name("apnsTokenDidUpdate")
}

extension AppDelegate {

    func requestPushPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .badge, .sound,
        ]) { granted, error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: "apnsReady")
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.log("✅ Push permission granted")
                    NotificationCenter.default.post(
                        name: .pushPermissionGranted,
                        object: nil
                    )
                } else {
                    self.log(
                        "❌ Push permission denied: \(error?.localizedDescription ?? "none")"
                    )
                    NotificationCenter.default.post(
                        name: .pushPermissionDenied,
                        object: nil
                    )
                }
            }
        }
    }
}
