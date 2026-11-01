import CarPlay
import UIKit

/// The CarPlay scene: starts the shared engine if the car launched the app
/// before the phone did, and hands the head unit to
/// `CarPlayTemplateController`.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  private var templateController: CarPlayTemplateController?

  /// The head unit while connected, kept so a setup that failed because
  /// the engine did not start can be retried.
  private var interfaceController: CPInterfaceController?

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didConnect interfaceController: CPInterfaceController
  ) {
    self.interfaceController = interfaceController
    connectIfNeeded()
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Retries a setup whose engine start failed at connect.
    connectIfNeeded()
  }

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didDisconnectInterfaceController interfaceController: CPInterfaceController
  ) {
    templateController?.disconnect()
    templateController = nil
    self.interfaceController = nil
  }

  private func connectIfNeeded() {
    guard templateController == nil,
      let interfaceController,
      let appDelegate = AppDelegate.shared,
      appDelegate.startFlutterEngine() != nil,
      let channel = appDelegate.carPlayChannel
    else { return }
    let controller = CarPlayTemplateController(
      interfaceController: interfaceController, channel: channel)
    templateController = controller
    controller.connect()
  }
}
