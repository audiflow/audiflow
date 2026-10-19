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
    if let windowScene = scene as? UIWindowScene, let appDelegate = AppDelegate.shared {
      let engine = appDelegate.startFlutterEngine()
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
      self.window = window
      window.makeKeyAndVisible()
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func sceneDidDisconnect(_ scene: UIScene) {
    super.sceneDidDisconnect(scene)
    // Release the view controller now: the engine outlives this scene (it
    // may be serving CarPlay), and a reconnecting window can only attach a
    // new view controller once the old one has let the engine go.
    window = nil
  }
}
