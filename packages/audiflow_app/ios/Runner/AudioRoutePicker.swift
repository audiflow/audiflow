import AVKit
import Flutter
import UIKit

/// Hosts a transparent `AVRoutePickerView` for the player's output button.
///
/// iOS has no API to open the route picker programmatically, so the native
/// view must receive the tap. Flutter draws the visible icon underneath;
/// this view only supplies the hit target and accessibility element.
final class AudioRoutePickerViewFactory: NSObject, FlutterPlatformViewFactory {
  static let viewType = "audiflow/audio_route_picker"

  static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(AudioRoutePickerViewFactory(), withId: viewType)
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let label = (args as? [String: Any])?["label"] as? String
    return AudioRoutePickerPlatformView(frame: frame, label: label)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

private final class AudioRoutePickerPlatformView: NSObject, FlutterPlatformView {
  private let picker: AVRoutePickerView

  init(frame: CGRect, label: String?) {
    picker = AVRoutePickerView(frame: frame)
    picker.backgroundColor = .clear
    // Clear tints hide the native glyph so only the Flutter icon shows.
    picker.tintColor = .clear
    picker.activeTintColor = .clear
    picker.prioritizesVideoDevices = false
    if let label {
      picker.accessibilityLabel = label
    }
    super.init()
  }

  func view() -> UIView {
    picker
  }
}
