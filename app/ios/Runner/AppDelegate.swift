import UIKit
import Flutter
import Firebase
import AppTrackingTransparency
import flutter_downloader

import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
//    requestPermission()
    // if #available(iOS 10.0, *) {
    //   UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    // }
    if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
      } else {
        let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }

    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "in.wealthy.advisor",
                                              binaryMessenger: controller.binaryMessenger)

    
    // Below code is implementation for user interaction listener support
      // FreshchatSdkPluginWindow needs to be initialised in the target application's 
      // app delegate for the user interaction listener to work
      // @property (nonatomic, strong) FreshchatSdkPluginWindow *window; should be added in the header file as well
      // let viewController = UIApplication.shared.windows.first!.rootViewController as! UIViewController
      // window = FreshchatSdkPluginWindow(frame: UIScreen.main.bounds)
      // window.rootViewController = viewController

    
    // To enable the sending of events to Facebook App Events 
    // on iOS 14+ app MUST request user for tracking:
    // NSTimeInterval delayInSeconds = 1.0;
    // dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    // dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //     [self requestTracking];
    //     });
    
    methodChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in


    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {   
        // application.registerForRemoteNotifications();
        Messaging.messaging().setAPNSToken(deviceToken , type: .unknown)
        NSLog("didRegisterForRemoteNotificationsWithDeviceToken **")
        
        let freshchatSdkPlugin = FreshchatSdkPlugin()
        print("Device Token \(deviceToken)")
        freshchatSdkPlugin.setPushRegistrationToken(deviceToken)
        NSLog("Device token is set")

    }

  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // to handle remote notification, when it received.
    NSLog("didReceiveRemoteNotification **")

    let freshchatSdkPlugin = FreshchatSdkPlugin()
    if freshchatSdkPlugin.isFreshchatNotification(userInfo) {
        freshchatSdkPlugin.handlePushNotification(userInfo)
    }
  }

  // @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
          willPresent: UNNotification,
          withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
    
    NSLog("userNotificationCenter willPresent **")
    let freshchatSdkPlugin = FreshchatSdkPlugin()

    if freshchatSdkPlugin.isFreshchatNotification(willPresent.request.content.userInfo) {

        NSLog("Notification Handled inside IF")
        freshchatSdkPlugin.handlePushNotification(willPresent.request.content.userInfo) 
        //Handled for freshchat notifications

    } else {

        NSLog("Notification Handled inside ELSE")
        super.userNotificationCenter(center, willPresent: willPresent, withCompletionHandler: withCompletionHandler)
        // withCompletionHandler([.alert, .sound, .badge]) 
        // For other notifications
    }
  }

  // @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
          didReceive: UNNotificationResponse,
          withCompletionHandler: @escaping ()->()) {
    
    NSLog("userNotificationCenter didReceive **")
    let freshchatSdkPlugin = FreshchatSdkPlugin()

    if freshchatSdkPlugin.isFreshchatNotification(didReceive.notification.request.content.userInfo) {
      
      NSLog("Notification Handled inside IF")
      freshchatSdkPlugin.handlePushNotification(didReceive.notification.request.content.userInfo) 
      //Handled for freshchat notifications
      withCompletionHandler()

    } else {

      NSLog("Notification Handled inside ELSE")
      // withCompletionHandler() 
      //For other notifications
      super.userNotificationCenter(center, didReceive: didReceive, withCompletionHandler: withCompletionHandler)

    }
  } 

  override func applicationDidEnterBackground(_ application: UIApplication){
    application.applicationIconBadgeNumber = 0
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // Tracking authorization dialog was shown
                // and we are authorized
                print("Authorized")
            case .denied:
                // Tracking authorization dialog was
                // shown and permission is denied
                print("Denied")
            case .notDetermined:
                // Tracking authorization dialog has not been shown
                print("Not Determined")
            case .restricted:
                print("Restricted")
            @unknown default:
                print("Unknown")
            }
        }
    }
}

}


private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}