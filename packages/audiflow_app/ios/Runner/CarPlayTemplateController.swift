import CarPlay
import UIKit

/// Builds and refreshes the CarPlay templates for one connected head unit.
///
/// The root is a tab bar of four lists (Up Next, Stations, Library,
/// Downloads). A Stations row pushes that station's episodes and a Library
/// row that podcast's; any episode
/// row plays and shows the shared Now Playing template. Now Playing itself
/// is driven by `MPNowPlayingInfoCenter` and `MPRemoteCommandCenter`, which
/// audio_service keeps in step with the phone player; only the speed button
/// and the Up Next button are wired here.
final class CarPlayTemplateController: NSObject {
  private static let tabs: [CarPlaySection] = [.upNext, .stations, .library, .downloads]

  private let interfaceController: CPInterfaceController
  private let channel: CarPlayChannel
  private let artwork: CarPlayArtworkLoader

  /// A list template on screen and what fills it.
  private struct ShownList {
    let template: CPListTemplate
    let section: CarPlaySection
    var podcastId: Int?
    var stationId: Int?
  }

  private var tabLists: [ShownList] = []
  /// Lists pushed over the tab bar, bottom first.
  private var pushedLists: [ShownList] = []
  private var labels: CarPlayLabels?
  /// The latest `listItems` request per template. Dart answers requests
  /// concurrently, so an older reply can arrive after a newer one and must
  /// not overwrite it.
  private var requestGenerations: [ObjectIdentifier: Int] = [:]

  init(interfaceController: CPInterfaceController, channel: CarPlayChannel) {
    self.interfaceController = interfaceController
    self.channel = channel
    artwork = CarPlayArtworkLoader(
      displayScale: interfaceController.carTraitCollection.displayScale)
    super.init()
  }

  func connect() {
    interfaceController.delegate = self
    channel.delegate = self
    CPNowPlayingTemplate.shared.add(self)
    if let labels = channel.labels {
      build(with: labels)
    } else {
      showWaitingForDart()
    }
  }

  func disconnect() {
    CPNowPlayingTemplate.shared.remove(self)
    channel.delegate = nil
    channel.setConnected(false)
  }

  // MARK: - Building

  /// A placeholder root while the engine is still starting: CarPlay needs
  /// a root template before `didConnect` returns, and the localized labels
  /// only arrive with Dart's `ready`.
  private func showWaitingForDart() {
    let waiting = CPListTemplate(title: nil, sections: [])
    // The app name, which needs no translation.
    waiting.emptyViewTitleVariants = ["Audiflow"]
    interfaceController.setRootTemplate(waiting, animated: false, completion: nil)
  }

  private func build(with labels: CarPlayLabels) {
    self.labels = labels
    tabLists = Self.tabs.map { section in
      ShownList(template: makeListTemplate(section, title: labels.title(of: section)), section: section)
    }
    pushedLists = []
    requestGenerations = [:]
    let tabBar = CPTabBarTemplate(templates: tabLists.map(\.template))
    interfaceController.setRootTemplate(tabBar, animated: false, completion: nil)
    configureNowPlaying(labels)
    // After the root is set: Dart starts watching the lists' data and may
    // invalidate them at once.
    channel.setConnected(true)
    tabLists.forEach(reload)
  }

  private func makeListTemplate(_ section: CarPlaySection, title: String) -> CPListTemplate {
    let template = CPListTemplate(title: title, sections: [])
    template.tabTitle = title
    template.tabImage = UIImage(systemName: Self.tabSymbol(section))
    template.emptyViewTitleVariants = [labels?.emptyText(of: section) ?? ""]
    return template
  }

  private static func tabSymbol(_ section: CarPlaySection) -> String {
    switch section {
    case .upNext: return "list.bullet"
    case .stations, .station: return "dot.radiowaves.left.and.right"
    case .library, .podcast: return "square.stack"
    case .downloads: return "arrow.down.circle"
    }
  }

  private func configureNowPlaying(_ labels: CarPlayLabels) {
    let nowPlaying = CPNowPlayingTemplate.shared
    nowPlaying.isUpNextButtonEnabled = true
    nowPlaying.upNextTitle = labels.title(of: .upNext)
    updateSpeedButton()
  }

  /// Shows the current speed on an image button rather than
  /// `CPNowPlayingPlaybackRateButton`, which reads "0x" whatever rate is
  /// published to `MPNowPlayingInfoCenter` (Apple developer forums threads
  /// 729186 and 773106; reproduced on iOS 27.2).
  private func updateSpeedButton() {
    let image = Self.speedImage(
      channel.controls?.speed ?? 1,
      scale: interfaceController.carTraitCollection.displayScale)
    let button = CPNowPlayingImageButton(image: image) { [weak self] _ in
      self?.channel.cycleSpeed()
    }
    CPNowPlayingTemplate.shared.updateNowPlayingButtons([button])
  }

  /// Draws [speed] as "1.5×", sized to fit a Now Playing button.
  private static func speedImage(_ speed: Double, scale: CGFloat) -> UIImage {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    let text = (formatter.string(from: NSNumber(value: speed)) ?? "1") + "×"
    let size = CPNowPlayingButtonMaximumImageSize
    var font = UIFont.systemFont(ofSize: size.height * 0.6, weight: .semibold)
    // Long values like "1.25×" would overflow the square at full size.
    let fullWidth = (text as NSString).size(withAttributes: [.font: font]).width
    if size.width < fullWidth {
      font = font.withSize(font.pointSize * size.width / fullWidth)
    }
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
    let textSize = (text as NSString).size(withAttributes: attributes)
    let format = UIGraphicsImageRendererFormat()
    format.scale = scale
    let image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
      (text as NSString).draw(
        at: CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2),
        withAttributes: attributes)
    }
    // Template rendering lets CarPlay tint it like the system buttons.
    return image.withRenderingMode(.alwaysTemplate)
  }

  // MARK: - Loading rows

  private func reload(_ list: ShownList) {
    let key = ObjectIdentifier(list.template)
    let generation = (requestGenerations[key] ?? 0) + 1
    requestGenerations[key] = generation
    channel.listItems(list.section, podcastId: list.podcastId, stationId: list.stationId) {
      [weak self] items in
      guard let self, self.requestGenerations[key] == generation else { return }
      guard let items else {
        list.template.emptyViewTitleVariants = [self.labels?.loadFailed ?? ""]
        list.template.updateSections([])
        return
      }
      list.template.emptyViewTitleVariants = [self.labels?.emptyText(of: list.section) ?? ""]
      let rows = items.prefix(CPListTemplate.maximumItemCount).map {
        self.makeListItem($0, in: list)
      }
      list.template.updateSections([CPListSection(items: Array(rows))])
    }
  }

  private func makeListItem(_ item: CarPlayItem, in list: ShownList) -> CPListItem {
    let row = CPListItem(
      text: item.title,
      detailText: item.detail,
      image: item.artworkURL.flatMap(artwork.cachedImage(for:)))
    row.isPlaying = item.isPlaying
    if let progress = item.progress {
      row.playbackProgress = CGFloat(min(max(progress, 0), 1))
    }
    if list.section == .library || list.section == .stations {
      row.accessoryType = .disclosureIndicator
    }
    if let url = item.artworkURL, artwork.cachedImage(for: url) == nil {
      artwork.loadImage(for: url) { [weak row] image in row?.setImage(image) }
    }
    row.handler = { [weak self] _, completion in
      self?.select(item, in: list)
      completion()
    }
    return row
  }

  // MARK: - Selection

  private func select(_ item: CarPlayItem, in list: ShownList) {
    switch list.section {
    case .library:
      push(.podcast, title: item.title, podcastId: item.id)
      return
    case .stations:
      push(.station, title: item.title, stationId: item.id)
      return
    default:
      break
    }
    channel.playItem(list.section, id: item.id, stationId: list.stationId) {
      [weak self] started in
      if started { self?.showNowPlaying() }
    }
  }

  private func push(
    _ section: CarPlaySection, title: String, podcastId: Int? = nil, stationId: Int? = nil
  ) {
    let shown = ShownList(
      template: makeListTemplate(section, title: title), section: section,
      podcastId: podcastId, stationId: stationId)
    pushedLists.append(shown)
    interfaceController.pushTemplate(shown.template, animated: true, completion: nil)
    reload(shown)
  }

  private func showNowPlaying() {
    let nowPlaying = CPNowPlayingTemplate.shared
    if interfaceController.topTemplate === nowPlaying { return }
    // Now Playing may already sit under a list opened from its Up Next
    // button; CarPlay rejects pushing a template that is in the stack.
    if interfaceController.templates.contains(where: { $0 === nowPlaying }) {
      interfaceController.pop(to: nowPlaying, animated: true, completion: nil)
      return
    }
    interfaceController.pushTemplate(nowPlaying, animated: true, completion: nil)
  }
}

// MARK: - CarPlayChannelDelegate

extension CarPlayTemplateController: CarPlayChannelDelegate {
  func carPlayChannel(_ channel: CarPlayChannel, didBecomeReadyWith labels: CarPlayLabels) {
    // Dart restarted or changed language: rebuild with the new labels and
    // tell the new isolate a head unit is connected.
    build(with: labels)
  }

  func carPlayChannel(_ channel: CarPlayChannel, didInvalidate sections: Set<CarPlaySection>) {
    (tabLists + pushedLists).filter { sections.contains($0.section) }.forEach(reload)
  }

  func carPlayChannel(_ channel: CarPlayChannel, didUpdate controls: NowPlayingControls) {
    updateSpeedButton()
  }
}

// MARK: - CPInterfaceControllerDelegate

extension CarPlayTemplateController: CPInterfaceControllerDelegate {
  func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
    // Stop refreshing lists the driver has popped.
    let onScreen = interfaceController.templates
    let popped = pushedLists.filter { shown in !onScreen.contains { $0 === shown.template } }
    popped.forEach { requestGenerations[ObjectIdentifier($0.template)] = nil }
    pushedLists.removeAll { shown in popped.contains { $0.template === shown.template } }
  }
}

// MARK: - CPNowPlayingTemplateObserver

extension CarPlayTemplateController: CPNowPlayingTemplateObserver {
  func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
    push(.upNext, title: labels?.title(of: .upNext) ?? "")
  }
}
