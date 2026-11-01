import CarPlay
import ImageIO
import UIKit

/// Loads list-row artwork for CarPlay, decoded at the size a row shows.
///
/// Podcast artwork is often 3000 px square; decoding it whole for a row a
/// few dozen points wide costs about 36 MB per image (#451), so it is
/// decoded straight to a thumbnail with ImageIO. Images are cached in
/// memory, and concurrent requests for one URL share a single download.
final class CarPlayArtworkLoader {
  private let cache = NSCache<NSURL, UIImage>()
  private var waiters: [URL: [(UIImage) -> Void]] = [:]
  private let session: URLSession
  private let maxPixelSize: CGFloat

  /// `displayScale` is the head unit's, from the interface controller's
  /// `carTraitCollection`.
  init(displayScale: CGFloat, session: URLSession = .shared) {
    let rowSize = CPListItem.maximumImageSize
    maxPixelSize = max(rowSize.width, rowSize.height) * max(displayScale, 1)
    self.session = session
    cache.countLimit = 200
  }

  /// The cached image for `url`, if it has been loaded.
  func cachedImage(for url: URL) -> UIImage? {
    cache.object(forKey: url as NSURL)
  }

  /// Calls `completion` on the main queue with the image for `url`. A
  /// failed load never calls it: the row keeps its placeholder.
  func loadImage(for url: URL, completion: @escaping (UIImage) -> Void) {
    if let cached = cachedImage(for: url) {
      completion(cached)
      return
    }
    if waiters[url] != nil {
      waiters[url]?.append(completion)
      return
    }
    waiters[url] = [completion]
    let maxPixelSize = maxPixelSize
    session.dataTask(with: url) { [weak self] data, _, _ in
      let image = data.flatMap { Self.thumbnail(from: $0, maxPixelSize: maxPixelSize) }
      DispatchQueue.main.async {
        guard let self else { return }
        let completions = self.waiters.removeValue(forKey: url) ?? []
        guard let image else { return }
        self.cache.setObject(image, forKey: url as NSURL)
        completions.forEach { $0(image) }
      }
    }.resume()
  }

  private static func thumbnail(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    let options: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
    ]
    guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    else { return nil }
    return UIImage(cgImage: image)
  }
}
