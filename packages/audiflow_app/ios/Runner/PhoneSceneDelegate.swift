import Flutter
import UIKit

/// The phone window's scene delegate: hosts the shared engine from
/// `AppDelegate` instead of a storyboard view controller with its own.
///
/// The root view controller is set before `super` runs, so
/// `FlutterSceneDelegate` finds the engine and forwards the connection
/// options (deep links, notification launches) to its plugins.
final class PhoneSceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    attachEngineIfNeeded(to: scene)
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    // An engine that failed to start at connect left no window; try again
    // each time the user returns to the app.
    attachEngineIfNeeded(to: scene)
    super.sceneDidBecomeActive(scene)
  }

  override func sceneDidDisconnect(_ scene: UIScene) {
    super.sceneDidDisconnect(scene)
    // Release the view controller now: the engine outlives this scene (it
    // may be serving CarPlay), and a reconnecting window can only attach a
    // new view controller once the old one has let the engine go.
    window = nil
  }

  /// Shows the shared engine in a new window, once it runs. Attaching an
  /// engine that failed to start would show a blank window for good.
  private func attachEngineIfNeeded(to scene: UIScene) {
    guard window == nil,
      let windowScene = scene as? UIWindowScene,
      let engine = AppDelegate.shared?.startFlutterEngine()
    else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    self.window = window
    window.makeKeyAndVisible()
  }
}
