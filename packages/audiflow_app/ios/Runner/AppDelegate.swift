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

    excludeDownloadsFromBackup()

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

  /// Keeps downloaded audio out of iCloud backups and device migration.
  ///
  /// The audio is re-downloadable and can be gigabytes, which inflates the
  /// user's backup; a restored copy would also not match the download rows
  /// (see docs/architecture/user-data-sync.md). The flag on the directory
  /// covers every file inside it. This runs on every launch, before Dart
  /// starts, so the directory is excluded before the first download lands.
  /// The path must match `DownloadFileService.getDownloadsDirectory`.
  private func excludeDownloadsFromBackup() {
    let fileManager = FileManager.default
    guard
      let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    else { return }
    var downloads = documents.appendingPathComponent("downloads", isDirectory: true)
    do {
      try fileManager.createDirectory(at: downloads, withIntermediateDirectories: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try downloads.setResourceValues(values)
    } catch {
      // Not fatal: downloads still work, they are only backed up.
      NSLog("[AppDelegate] Failed to exclude downloads from backup: \(error)")
    }
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
    DeviceOnlyStoreChannel.register(with: flutterEngine.binaryMessenger)
    BackupExclusionChannel.register(with: flutterEngine.binaryMessenger)
    carPlayChannel = CarPlayChannel(messenger: flutterEngine.binaryMessenger)
    return flutterEngine
  }
}

/// Native end of `audiflow/backup_exclusion` (Dart `DatabaseBackupExclusion`).
///
/// Marks the Isar database files `isExcludedFromBackup` (decision C1 in
/// docs/architecture/user-data-sync.md): the continuity snapshot in
/// Application Support carries the user data to a new device instead.
/// Dart sends the paths after it opens the database, because Isar creates
/// the files on first open and schema recovery re-creates them; fixed paths
/// set here at launch would miss both until the next launch.
private enum BackupExclusionChannel {
  static let channelName = "audiflow/backup_exclusion"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "exclude" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let paths = call.arguments as? [String] else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "paths are required", details: nil))
        return
      }
      exclude(paths: paths, result: result)
    }
  }

  private static func exclude(paths: [String], result: FlutterResult) {
    // Only files of this app: the channel must not become a way to flag
    // arbitrary paths.
    let home = URL(fileURLWithPath: NSHomeDirectory()).standardizedFileURL.path + "/"
    for path in paths {
      var url = URL(fileURLWithPath: path).standardizedFileURL
      guard url.path.hasPrefix(home) else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "path outside the app container", details: nil))
        return
      }
      do {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
      } catch {
        result(FlutterError(code: "IO", message: error.localizedDescription, details: nil))
        return
      }
    }
    result(nil)
  }
}

/// Native end of `audiflow/device_only_store` (Dart `MethodChannelDeviceOnlyStore`).
///
/// Values live in the Keychain with `AfterFirstUnlockThisDeviceOnly`: they
/// are excluded from iCloud Keychain, encrypted backups, and device
/// migration, so a restored or new device never inherits them (see
/// docs/architecture/user-data-sync.md). They do survive an app uninstall;
/// the Dart side detects that with a marker in preferences.
private enum DeviceOnlyStoreChannel {
  static let channelName = "audiflow/device_only_store"
  static let service = "com.reedom.audiflow.device_only"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard
        let args = call.arguments as? [String: Any],
        let key = args["key"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "key is required", details: nil))
        return
      }
      switch call.method {
      case "read":
        read(key: key, result: result)
      case "write":
        guard let value = args["value"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "value is required", details: nil))
          return
        }
        write(key: key, value: value, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func baseQuery(key: String) -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key,
    ]
  }

  private static func read(key: String, result: FlutterResult) {
    var query = baseQuery(key: key)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    switch status {
    case errSecSuccess:
      guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
        result(nil)
        return
      }
      result(value)
    case errSecItemNotFound:
      result(nil)
    default:
      result(keychainError(status))
    }
  }

  private static func write(key: String, value: String, result: FlutterResult) {
    let data = Data(value.utf8)
    let attributes: [String: Any] = [
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    ]
    var status = SecItemUpdate(baseQuery(key: key) as CFDictionary, attributes as CFDictionary)
    if status == errSecItemNotFound {
      var add = baseQuery(key: key)
      add.merge(attributes) { _, new in new }
      status = SecItemAdd(add as CFDictionary, nil)
    }
    result(status == errSecSuccess ? nil : keychainError(status))
  }

  private static func keychainError(_ status: OSStatus) -> FlutterError {
    let message = SecCopyErrorMessageString(status, nil) as String? ?? "OSStatus \(status)"
    return FlutterError(code: "KEYCHAIN", message: message, details: Int(status))
  }
}
