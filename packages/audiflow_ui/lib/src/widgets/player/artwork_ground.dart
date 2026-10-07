import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

/// Turns an artwork's average color into the player's ground: the hue is
/// kept, saturation is muted, and lightness is pulled down far enough that
/// white controls stay readable on any artwork.
Color groundFromArtworkColor(Color average) {
  final hsl = HSLColor.fromColor(average);
  return hsl
      .withSaturation((hsl.saturation * 0.6).clamp(0.0, 0.45))
      .withLightness(0.24)
      .toColor();
}

/// Average color of [rgba] pixels (4 bytes each), weighting saturated
/// pixels more so a colorful subject outweighs a flat white or black
/// background.
Color averageArtworkColor(List<int> rgba) {
  var r = 0.0, g = 0.0, b = 0.0, total = 0.0;
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    final alpha = rgba[i + 3] / 255;
    if (alpha == 0) continue;
    final pr = rgba[i], pg = rgba[i + 1], pb = rgba[i + 2];
    final maxC = [pr, pg, pb].reduce((a, c) => a < c ? c : a);
    final minC = [pr, pg, pb].reduce((a, c) => a < c ? a : c);
    final weight = alpha * (0.15 + (maxC - minC) / 255);
    r += pr * weight;
    g += pg * weight;
    b += pb * weight;
    total += weight;
  }
  if (total == 0) return NowPlayingColors.fallbackBackground;
  return Color.fromARGB(
    255,
    (r / total).round(),
    (g / total).round(),
    (b / total).round(),
  );
}

/// Resolves the player ground for [url] (see [groundFromArtworkColor]) and
/// rebuilds with it, cross-fading between episodes. Shows
/// [NowPlayingColors.fallbackBackground] until the artwork is sampled, or
/// when there is none.
class ArtworkGround extends StatefulWidget {
  const ArtworkGround({super.key, required this.url, required this.builder});

  final String? url;
  final Widget Function(BuildContext context, Color ground) builder;

  /// Sampled grounds by URL, so reopening the player does not flash the
  /// fallback first.
  static final LinkedHashMap<String, Color> _cache = LinkedHashMap();
  static const int _cacheSize = 32;

  @override
  State<ArtworkGround> createState() => _ArtworkGroundState();
}

class _ArtworkGroundState extends State<ArtworkGround> {
  Color _ground = NowPlayingColors.fallbackBackground;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(ArtworkGround oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _resolve();
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _detach() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  void _resolve() {
    _detach();
    final url = widget.url;
    if (url == null) {
      _ground = NowPlayingColors.fallbackBackground;
      return;
    }
    final cached = ArtworkGround._cache[url];
    if (cached != null) {
      _ground = cached;
      return;
    }
    // A tiny decode is plenty for an average and costs almost nothing.
    final provider = ResizeImage(
      ExtendedNetworkImageProvider(url, cache: true),
      width: 24,
      height: 24,
    );
    final stream = provider.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) => unawaited(_sample(url, info.image)),
      onError: (_, _) {},
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  Future<void> _sample(String url, ui.Image image) async {
    final bytes = await image.toByteData();
    if (bytes == null) return;
    final ground = groundFromArtworkColor(
      averageArtworkColor(bytes.buffer.asUint8List()),
    );
    final cache = ArtworkGround._cache
      ..remove(url)
      ..[url] = ground;
    if (ArtworkGround._cacheSize < cache.length) cache.remove(cache.keys.first);
    if (!mounted || widget.url != url) return;
    setState(() => _ground = ground);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: _ground),
      duration: const Duration(milliseconds: 400),
      builder: (context, color, _) => widget.builder(context, color ?? _ground),
    );
  }
}
