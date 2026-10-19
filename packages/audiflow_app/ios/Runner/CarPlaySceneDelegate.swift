import CarPlay
import UIKit

/// The CarPlay scene: starts the shared engine if the car launched the app
/// before the phone did, and hands the head unit to
/// `CarPlayTemplateController`.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  private var templateController: CarPlayTemplateController?

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didConnect interfaceController: CPInterfaceController
  ) {
    guard let appDelegate = AppDelegate.shared else { return }
    _ = appDelegate.startFlutterEngine()
    guard let channel = appDelegate.carPlayChannel else { return }
    let controller = CarPlayTemplateController(
      interfaceController: interfaceController, channel: channel)
    templateController = controller
    controller.connect()
  }

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didDisconnectInterfaceController interfaceController: CPInterfaceController
  ) {
    templateController?.disconnect()
    templateController = nil
  }
}
