import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Scrollable mock of a podcast detail screen for reviewing the floating
/// navigation, collapsing hero, and in-navigation search on a device.
///
/// Fixture strings mirror the design mockups and are not user-facing copy.
class DesignGalleryFloatingNavDemo extends StatefulWidget {
  const DesignGalleryFloatingNavDemo({super.key});

  @override
  State<DesignGalleryFloatingNavDemo> createState() =>
      _DesignGalleryFloatingNavDemoState();
}

class _DesignGalleryFloatingNavDemoState
    extends State<DesignGalleryFloatingNavDemo> {
  static const double _heroExtent = 330;

  // The hero is gone once its bottom passes under the navigation bar.
  static const double _collapseExtent =
      _heroExtent - FloatingNavigationBar.barHeight;
  static const _title = '歴史を面白く学ぶコテンラジオ（COTEN RADIO）';
  static final _episodes = [
    for (var number = 1; number <= 40; number++)
      '#$number ${number.isEven ? 'モンゴル帝国' : '宗教改革'}編 その$number',
  ];

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  var _scroll = FloatingNavScroll.at(offset: 0, heroExtent: _collapseExtent);
  var _searching = false;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final next = FloatingNavScroll.at(
      offset: _scrollController.offset,
      heroExtent: _searching ? 0 : _collapseExtent,
    );
    setState(() => _scroll = next);
  }

  void _setSearching(bool searching) {
    setState(() {
      _searching = searching;
      _query = '';
      _scroll = FloatingNavScroll.at(
        offset: 0,
        heroExtent: searching ? 0 : _collapseExtent,
      );
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  List<String> get _visibleEpisodes => _query.isEmpty
      ? _episodes
      : _episodes.where((title) => title.contains(_query)).toList();

  @override
  Widget build(BuildContext context) {
    final navHeight = FloatingNavigationBar.heightOf(context);
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: _searching ? navHeight : 0),
              ),
              if (!_searching)
                SliverToBoxAdapter(
                  child: CollapsingHero(
                    progress: _scroll.hero,
                    child: _DemoHero(height: _heroExtent, title: _title),
                  ),
                ),
              if (_searching) SliverToBoxAdapter(child: _countLine()),
              SliverToBoxAdapter(
                child: GroupedSection(
                  children: [
                    for (final title in _visibleEpisodes)
                      SettingsRow(title: title, onTap: () {}),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          Positioned(top: 0, left: 0, right: 0, child: _navigation(context)),
        ],
      ),
    );
  }

  Widget _countLine() {
    final colors = AppColors.of(context);
    final text = _query.isEmpty
        ? '${_episodes.length} 件'
        : '「$_query」 ${_visibleEpisodes.length} 件';
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 12, 36, 8),
      child: Text(
        text,
        style: AppTextStyles.meta.copyWith(color: colors.inkTertiary),
      ),
    );
  }

  Widget _navigation(BuildContext context) {
    return FloatingNavigationBar(
      leading: FloatingNavButton(
        icon: Icons.arrow_back_ios_new_rounded,
        tooltip: '戻る',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: _title,
      titleOpacity: _searching ? 0 : _scroll.title,
      backgroundOpacity: _searching ? 1 : _scroll.background,
      trailing: FloatingNavActions(
        actions: [
          FloatingNavAction(
            icon: Icons.search_rounded,
            tooltip: '検索',
            onPressed: () => _setSearching(true),
          ),
          FloatingNavAction(
            icon: Icons.tune_rounded,
            tooltip: '設定',
            onPressed: () {},
          ),
          FloatingNavAction(
            icon: Icons.more_horiz_rounded,
            tooltip: 'その他',
            onPressed: () {},
          ),
        ],
      ),
      search: _searching
          ? NavigationSearchField(
              controller: _searchController,
              hintText: 'エピソードを検索',
              cancelLabel: 'キャンセル',
              onChanged: (value) => setState(() => _query = value.trim()),
              onCancel: () => _setSearching(false),
            )
          : null,
    );
  }
}

class _DemoHero extends StatelessWidget {
  const _DemoHero({required this.height, required this.title});

  final double height;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final top = FloatingNavigationBar.heightOf(context);
    return SizedBox(
      height: top + height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(32, top, 32, Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox.square(
              dimension: 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceSunken,
                  borderRadius: AppBorders.artworkHero,
                ),
                child: Icon(
                  Icons.podcasts,
                  size: 64,
                  color: colors.inkTertiary,
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heroTitle.copyWith(color: colors.ink),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'COTEN inc. · 歴史',
              style: AppTextStyles.meta.copyWith(color: colors.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
