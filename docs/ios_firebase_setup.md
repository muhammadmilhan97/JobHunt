# iOS Firebase Setup Instructions

## Prerequisites
- Xcode installed
- Apple Developer account (for push notifications)
- GoogleService-Info.plist file from Firebase Console

## Setup Steps

### 1. Add GoogleService-Info.plist
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` directory in Xcode
3. Ensure it's added to the Runner target

### 2. Update Info.plist
Add the following to `ios/Runner/Info.plist`:

```xml
<!-- Firebase Configuration -->
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>

<!-- Push Notification Permissions -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>

<!-- Required for Firebase Analytics -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

### 3. Update AppDelegate.swift
Replace the contents of `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import Firebase
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Configure Firebase
    FirebaseApp.configure()
    
    // Configure FCM
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle FCM token refresh
  override func application(_ application: UIApplication, 
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    
    let dataDict:[String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
  
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    // Print full message.
    print(userInfo)
    
    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound]])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    // Print full message.
    print(userInfo)
    
    completionHandler()
  }
}
```

### 4. Update Podfile
Ensure your `ios/Podfile` has the correct platform version:

```ruby
platform :ios, '11.0'

# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

# Add this if you're using Firebase
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Analytics'
```

### 5. Enable Push Notifications Capability
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Click "+" and add "Push Notifications"
5. Add "Background Modes" and enable:
   - Background fetch
   - Remote notifications

### 6. APNs Configuration
1. Go to Apple Developer Console
2. Create APNs key or certificate
3. Upload to Firebase Console under Project Settings > Cloud Messaging > iOS app configuration

## Testing
1. Run the app on a physical iOS device (push notifications don't work on simulator)
2. Check logs for FCM token
3. Send test notification from Firebase Console

## Troubleshooting
- Ensure bundle ID matches Firebase configuration
- Verify APNs key/certificate is correctly configured
- Check that the app is in foreground/background as needed for testing
- Review Firebase Console logs for delivery status
