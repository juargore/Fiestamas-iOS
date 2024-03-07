//
//  FiestakiApp.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 01/05/23.
//

import SwiftUI
import Firebase
import GooglePlaces
import UserNotifications
import FirebaseMessaging

@main
struct FiestakiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyBbRfDwhAuDAelogC963zih53amg97Y_io")
        
        let appStorageManager = AppStorageManager()
        appStorageManager.storeValue(true, for: StorageKeys.appFirstLaunch)
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabScreen()
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
        
        var authViewModel: AuthViewModel = AuthViewModel()
        
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self
            
            return true
        }
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken
        }
        
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            if let fcm = Messaging.messaging().fcmToken {
                authViewModel.updateTokenPushNotificationIfPossible(newToken: fcm)
            }
        }
    }
}
