import Flutter
import UIKit

/// Handles `audiflow/haptics`: plays catalog haptic tokens with UIKit
/// feedback generators.
///
/// The token-to-pattern mapping is specified in `docs/design/haptics.md`
/// section 2. Generators are cached because `prepare()` only lowers
/// latency for the instance that later fires, and an impact generator's
/// style is fixed when it is created, so each style needs its own.
final class HapticsChannel {
  static let channelName = "audiflow/haptics"

  private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
  private lazy var selectionGenerator = UISelectionFeedbackGenerator()
  private lazy var notificationGenerator = UINotificationFeedbackGenerator()

  private enum Pattern {
    case impact(UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat)
    case selection
    case notification(UINotificationFeedbackGenerator.FeedbackType)
  }

  /// The handler closure owns the instance, and the messenger owns the
  /// handler, so the cached generators live as long as the engine.
  static func register(with messenger: FlutterBinaryMessenger) {
    let instance = HapticsChannel()
    FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        instance.handle(call, result: result)
      }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "play" || call.method == "prepare" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let name = call.arguments as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Token name is required", details: nil))
      return
    }
    // An unknown token is a no-op rather than an error: a newer Dart build
    // must never crash an older native build over a missing haptic.
    if let pattern = Self.pattern(for: name) {
      if call.method == "play" { play(pattern) } else { prepare(pattern) }
    }
    result(nil)
  }

  private static func pattern(for token: String) -> Pattern? {
    switch token {
    case "selection", "dragStep": return .selection
    case "toggleOn", "tap", "dragDrop": return .impact(.light, intensity: 1.0)
    case "toggleOff": return .impact(.soft, intensity: 0.6)
    case "longPress", "thresholdCross", "dragPickUp": return .impact(.medium, intensity: 1.0)
    case "thresholdRelease": return .impact(.light, intensity: 0.5)
    case "detent": return .impact(.rigid, intensity: 0.5)
    case "success": return .notification(.success)
    case "warning": return .notification(.warning)
    case "error": return .notification(.error)
    default: return nil
    }
  }

  private func play(_ pattern: Pattern) {
    switch pattern {
    case let .impact(style, intensity):
      impactGenerator(for: style).impactOccurred(intensity: intensity)
    case .selection:
      selectionGenerator.selectionChanged()
    case let .notification(type):
      notificationGenerator.notificationOccurred(type)
    }
  }

  private func prepare(_ pattern: Pattern) {
    switch pattern {
    case let .impact(style, _): impactGenerator(for: style).prepare()
    case .selection: selectionGenerator.prepare()
    case .notification: notificationGenerator.prepare()
    }
  }

  private func impactGenerator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
    if let generator = impactGenerators[style] { return generator }
    let generator = UIImpactFeedbackGenerator(style: style)
    impactGenerators[style] = generator
    return generator
  }
}
