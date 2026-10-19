import Flutter
import Foundation

/// A CarPlay list. Raw values are the wire names shared with
/// `CarSection` in `lib/features/car/models/car_list_item.dart`.
enum CarPlaySection: String, CaseIterable {
  case upNext
  case inProgress
  case library
  case downloads
  /// The episodes of one podcast, opened from `library`.
  case podcast
}

/// One row of a CarPlay list, decoded from Dart's `CarListItem.toMap`.
struct CarPlayItem {
  /// Queue item id in `upNext`, podcast id in `library`, episode id elsewhere.
  let id: Int
  let title: String
  let detail: String?
  let artworkURL: URL?
  let progress: Double?
  let isPlaying: Bool

  init?(_ value: Any) {
    guard let map = value as? [String: Any],
      let id = (map["id"] as? NSNumber)?.intValue,
      let title = map["title"] as? String
    else { return nil }
    self.id = id
    self.title = title
    detail = map["detail"] as? String
    artworkURL = (map["artworkUrl"] as? String).flatMap(URL.init(string:))
    progress = (map["progress"] as? NSNumber)?.doubleValue
    isPlaying = (map["isPlaying"] as? Bool) ?? false
  }
}

/// The localized CarPlay strings, sent by Dart with `ready`; keys match
/// `carPlayLabels` in `carplay_providers.dart`.
struct CarPlayLabels {
  let values: [String: String]

  func title(of section: CarPlaySection) -> String { values[section.rawValue] ?? "" }

  func emptyText(of section: CarPlaySection) -> String {
    values["\(section.rawValue)Empty"] ?? ""
  }

  var loadFailed: String { values["loadFailed"] ?? "" }
}

/// Receives what Dart sends on `audiflow/carplay`.
protocol CarPlayChannelDelegate: AnyObject {
  /// Dart started (or restarted, or changed language) with these labels.
  func carPlayChannel(_ channel: CarPlayChannel, didBecomeReadyWith labels: CarPlayLabels)
  /// The data behind these lists changed.
  func carPlayChannel(_ channel: CarPlayChannel, didInvalidate sections: Set<CarPlaySection>)
}

/// Native end of `audiflow/carplay`; the Dart end is `CarPlayBridge`.
///
/// Lives as long as the engine (owned by `AppDelegate`), while a CarPlay
/// scene comes and goes, so it remembers the last labels: a scene that
/// connects after Dart started can build its templates at once.
final class CarPlayChannel {
  static let channelName = "audiflow/carplay"

  private let channel: FlutterMethodChannel

  /// The labels from Dart's last `ready`; nil until Dart is running.
  private(set) var labels: CarPlayLabels?

  weak var delegate: CarPlayChannelDelegate?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  /// Tells Dart whether a head unit is showing the CarPlay scene, so it
  /// watches list data only while one is.
  func setConnected(_ connected: Bool) {
    channel.invokeMethod(connected ? "connected" : "disconnected", arguments: nil)
  }

  /// Fetches the rows of `section`; nil on failure. Rows Dart sends in a
  /// shape this build cannot read are skipped.
  func listItems(
    _ section: CarPlaySection,
    podcastId: Int? = nil,
    completion: @escaping ([CarPlayItem]?) -> Void
  ) {
    var arguments: [String: Any] = ["section": section.rawValue]
    if let podcastId { arguments["podcastId"] = podcastId }
    channel.invokeMethod("listItems", arguments: arguments) { reply in
      guard let rows = reply as? [Any] else {
        completion(nil)
        return
      }
      completion(rows.compactMap(CarPlayItem.init))
    }
  }

  /// Plays the row `id` of `section`; reports whether playback started.
  func playItem(_ section: CarPlaySection, id: Int, completion: @escaping (Bool) -> Void) {
    channel.invokeMethod(
      "playItem", arguments: ["section": section.rawValue, "id": id]
    ) { reply in
      completion(!(reply is FlutterError) && !Self.isNotImplemented(reply))
    }
  }

  /// Steps the playback speed. The Now Playing rate button reads the new
  /// rate from `MPNowPlayingInfoCenter`, which audio_service updates.
  func cycleSpeed() {
    channel.invokeMethod("cycleSpeed", arguments: nil)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any]
    switch call.method {
    case "ready":
      let ready = CarPlayLabels(values: arguments?["labels"] as? [String: String] ?? [:])
      labels = ready
      delegate?.carPlayChannel(self, didBecomeReadyWith: ready)
      result(nil)
    case "invalidate":
      let names = arguments?["sections"] as? [String] ?? []
      // An unknown name comes from a newer Dart build; it has no list here.
      let sections = Set(names.compactMap(CarPlaySection.init(rawValue:)))
      delegate?.carPlayChannel(self, didInvalidate: sections)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func isNotImplemented(_ reply: Any?) -> Bool {
    (reply as AnyObject?) === (FlutterMethodNotImplemented as AnyObject)
  }
}
