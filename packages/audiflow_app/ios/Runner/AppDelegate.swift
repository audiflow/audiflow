import Flutter
import UIKit
import UserNotifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// The one Flutter engine, shared by the phone window and the CarPlay
  /// scene.
  ///
  /// Owned here rather than created by the storyboard's view controller
  /// (the implicit engine) because CarPlay can launch the app with no phone
  /// window at all; Dart must still run to fill the CarPlay lists. Started
  /// by whichever scene connects first, the same moment the implicit engine
  /// started, so a launch that connects no scene still never runs `main`.
  private lazy var flutterEngine = FlutterEngine(name: "audiflow")
  private var isFlutterEngineRunning = false

  /// The CarPlay end of `audiflow/carplay`, available once the engine runs.
  private(set) var carPlayChannel: CarPlayChannel?

  static var shared: AppDelegate? { UIApplication.shared.delegate as? AppDelegate }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // BGTaskScheduler requires handler registration during app launch.
    // The engine and its plugins start later (on the first scene), so the
    // handler must be registered explicitly here.
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

    // Claim the UNUserNotificationCenter delegate slot. super.didFinishLaunching
    // does not auto-claim this because no plugins have been added to the
    // application-delegate chain yet (that happens later, in
    // startFlutterEngine). Without a delegate, iOS still
    // displays banners for background-delivered notifications but never
    // calls userNotificationCenter(_:didReceive:withCompletionHandler:)
    // on anyone, so taps never reach Dart's
    // onDidReceiveNotificationResponse and notification deep-links fail
    // silently. FlutterAppDelegate (our superclass) conforms to
    // UNUserNotificationCenterDelegate and forwards didReceive/willPresent
    // to every plugin registered via addApplicationDelegate: --
    // including flutter_local_notifications once the engine finishes
    // registering plugins.
    UNUserNotificationCenter.current().delegate = self

    return result
  }

  /// Runs the shared engine on first use and returns it, or nil when it
  /// failed to start.
  ///
  /// A failed `run()` is not remembered, so a caller can try again later
  /// instead of attaching to a dead engine.
  func startFlutterEngine() -> FlutterEngine? {
    if isFlutterEngineRunning { return flutterEngine }
    guard flutterEngine.run() else {
      NSLog("[AppDelegate] Flutter engine failed to start")
      return nil
    }
    isFlutterEngineRunning = true
    GeneratedPluginRegistrant.register(with: flutterEngine)
    if let registrar = flutterEngine.registrar(forPlugin: "AudioRoutePicker") {
      AudioRoutePickerViewFactory.register(with: registrar)
    }
    HapticsChannel.register(with: flutterEngine.binaryMessenger)
    carPlayChannel = CarPlayChannel(messenger: flutterEngine.binaryMessenger)
    return flutterEngine
  }
}
