import Flutter
import UIKit
import UserNotifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // BGTaskScheduler requires handler registration during app launch.
    // With FlutterImplicitEngineDelegate, plugin setup happens after this
    // method returns, so we must register the handler explicitly here.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "com.audiflow.backgroundRefresh",
      frequency: nil
    )
    WorkmanagerPlugin.registerBGProcessingTask(
      withIdentifier: "com.audiflow.backgroundDownload"
    )

    // Register all plugins with the Workmanager background Flutter engine.
    // Without this, plugins like flutter_local_notifications are not
    // available in the background isolate (MissingPluginException).
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Claim the UNUserNotificationCenter delegate slot. With the
    // FlutterImplicitEngineDelegate pattern, super.didFinishLaunching does
    // not auto-claim this because no plugins have been added to the
    // application-delegate chain yet (that happens later in
    // didInitializeImplicitFlutterEngine). Without a delegate, iOS still
    // displays banners for background-delivered notifications but never
    // calls userNotificationCenter(_:didReceive:withCompletionHandler:)
    // on anyone, so taps never reach Dart's
    // onDidReceiveNotificationResponse and notification deep-links fail
    // silently. FlutterAppDelegate (our superclass) conforms to
    // UNUserNotificationCenterDelegate and forwards didReceive/willPresent
    // to every plugin registered via addApplicationDelegate: --
    // including flutter_local_notifications once the implicit engine
    // finishes registering plugins.
    UNUserNotificationCenter.current().delegate = self

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
