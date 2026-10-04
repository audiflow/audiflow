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

/// Route picker whose inner button carries the app's accessibility label.
///
/// VoiceOver focuses the private UIButton inside `AVRoutePickerView`, not
/// the container, so the label must go on that button. It is created
/// lazily, hence the assignment on every layout pass.
private final class LabeledRoutePickerView: AVRoutePickerView {
  var buttonAccessibilityLabel: String?

  override func layoutSubviews() {
    super.layoutSubviews()
    guard let label = buttonAccessibilityLabel else { return }
    subviews.compactMap { $0 as? UIButton }.first?.accessibilityLabel = label
  }
}

private final class AudioRoutePickerPlatformView: NSObject, FlutterPlatformView {
  private let picker: LabeledRoutePickerView

  init(frame: CGRect, label: String?) {
    picker = LabeledRoutePickerView(frame: frame)
    picker.backgroundColor = .clear
    // Clear tints hide the native glyph so only the Flutter icon shows.
    picker.tintColor = .clear
    picker.activeTintColor = .clear
    picker.prioritizesVideoDevices = false
    picker.buttonAccessibilityLabel = label
    super.init()
  }

  func view() -> UIView {
    picker
  }
}
