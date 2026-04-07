import Flutter
import UIKit
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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
