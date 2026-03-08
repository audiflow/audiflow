// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PodcastDetailViewState {

 ParsedFeed get feed; PodcastViewMode get viewMode; EpisodeFilter get episodeFilter; SortOrder get episodeSortOrder; List<PodcastItem> get filteredEpisodes; EpisodeProgressMap get progressMap; List<SmartPlaylist> get smartPlaylists; bool get isSubscribed; bool get hasSmartPlaylistView; SmartPlaylist? get activePlaylist; String? get feedImageUrl; int? get subscriptionId; SmartPlaylistPatternConfig? get pattern;
/// Create a copy of PodcastDetailViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PodcastDetailViewStateCopyWith<PodcastDetailViewState> get copyWith => _$PodcastDetailViewStateCopyWithImpl<PodcastDetailViewState>(this as PodcastDetailViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PodcastDetailViewState&&(identical(other.feed, feed) || other.feed == feed)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.episodeFilter, episodeFilter) || other.episodeFilter == episodeFilter)&&(identical(other.episodeSortOrder, episodeSortOrder) || other.episodeSortOrder == episodeSortOrder)&&const DeepCollectionEquality().equals(other.filteredEpisodes, filteredEpisodes)&&const DeepCollectionEquality().equals(other.progressMap, progressMap)&&const DeepCollectionEquality().equals(other.smartPlaylists, smartPlaylists)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&(identical(other.hasSmartPlaylistView, hasSmartPlaylistView) || other.hasSmartPlaylistView == hasSmartPlaylistView)&&(identical(other.activePlaylist, activePlaylist) || other.activePlaylist == activePlaylist)&&(identical(other.feedImageUrl, feedImageUrl) || other.feedImageUrl == feedImageUrl)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.pattern, pattern) || other.pattern == pattern));
}


@override
int get hashCode => Object.hash(runtimeType,feed,viewMode,episodeFilter,episodeSortOrder,const DeepCollectionEquality().hash(filteredEpisodes),const DeepCollectionEquality().hash(progressMap),const DeepCollectionEquality().hash(smartPlaylists),isSubscribed,hasSmartPlaylistView,activePlaylist,feedImageUrl,subscriptionId,pattern);

@override
String toString() {
  return 'PodcastDetailViewState(feed: $feed, viewMode: $viewMode, episodeFilter: $episodeFilter, episodeSortOrder: $episodeSortOrder, filteredEpisodes: $filteredEpisodes, progressMap: $progressMap, smartPlaylists: $smartPlaylists, isSubscribed: $isSubscribed, hasSmartPlaylistView: $hasSmartPlaylistView, activePlaylist: $activePlaylist, feedImageUrl: $feedImageUrl, subscriptionId: $subscriptionId, pattern: $pattern)';
}


}

/// @nodoc
abstract mixin class $PodcastDetailViewStateCopyWith<$Res>  {
  factory $PodcastDetailViewStateCopyWith(PodcastDetailViewState value, $Res Function(PodcastDetailViewState) _then) = _$PodcastDetailViewStateCopyWithImpl;
@useResult
$Res call({
 ParsedFeed feed, PodcastViewMode viewMode, EpisodeFilter episodeFilter, SortOrder episodeSortOrder, List<PodcastItem> filteredEpisodes, EpisodeProgressMap progressMap, List<SmartPlaylist> smartPlaylists, bool isSubscribed, bool hasSmartPlaylistView, SmartPlaylist? activePlaylist, String? feedImageUrl, int? subscriptionId, SmartPlaylistPatternConfig? pattern
});




}
/// @nodoc
class _$PodcastDetailViewStateCopyWithImpl<$Res>
    implements $PodcastDetailViewStateCopyWith<$Res> {
  _$PodcastDetailViewStateCopyWithImpl(this._self, this._then);

  final PodcastDetailViewState _self;
  final $Res Function(PodcastDetailViewState) _then;

/// Create a copy of PodcastDetailViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? feed = null,Object? viewMode = null,Object? episodeFilter = null,Object? episodeSortOrder = null,Object? filteredEpisodes = null,Object? progressMap = null,Object? smartPlaylists = null,Object? isSubscribed = null,Object? hasSmartPlaylistView = null,Object? activePlaylist = freezed,Object? feedImageUrl = freezed,Object? subscriptionId = freezed,Object? pattern = freezed,}) {
  return _then(_self.copyWith(
feed: null == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as ParsedFeed,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as PodcastViewMode,episodeFilter: null == episodeFilter ? _self.episodeFilter : episodeFilter // ignore: cast_nullable_to_non_nullable
as EpisodeFilter,episodeSortOrder: null == episodeSortOrder ? _self.episodeSortOrder : episodeSortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,filteredEpisodes: null == filteredEpisodes ? _self.filteredEpisodes : filteredEpisodes // ignore: cast_nullable_to_non_nullable
as List<PodcastItem>,progressMap: null == progressMap ? _self.progressMap : progressMap // ignore: cast_nullable_to_non_nullable
as EpisodeProgressMap,smartPlaylists: null == smartPlaylists ? _self.smartPlaylists : smartPlaylists // ignore: cast_nullable_to_non_nullable
as List<SmartPlaylist>,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,hasSmartPlaylistView: null == hasSmartPlaylistView ? _self.hasSmartPlaylistView : hasSmartPlaylistView // ignore: cast_nullable_to_non_nullable
as bool,activePlaylist: freezed == activePlaylist ? _self.activePlaylist : activePlaylist // ignore: cast_nullable_to_non_nullable
as SmartPlaylist?,feedImageUrl: freezed == feedImageUrl ? _self.feedImageUrl : feedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as int?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as SmartPlaylistPatternConfig?,
  ));
}

}


/// Adds pattern-matching-related methods to [PodcastDetailViewState].
extension PodcastDetailViewStatePatterns on PodcastDetailViewState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PodcastDetailViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PodcastDetailViewState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PodcastDetailViewState value)  $default,){
final _that = this;
switch (_that) {
case _PodcastDetailViewState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PodcastDetailViewState value)?  $default,){
final _that = this;
switch (_that) {
case _PodcastDetailViewState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ParsedFeed feed,  PodcastViewMode viewMode,  EpisodeFilter episodeFilter,  SortOrder episodeSortOrder,  List<PodcastItem> filteredEpisodes,  EpisodeProgressMap progressMap,  List<SmartPlaylist> smartPlaylists,  bool isSubscribed,  bool hasSmartPlaylistView,  SmartPlaylist? activePlaylist,  String? feedImageUrl,  int? subscriptionId,  SmartPlaylistPatternConfig? pattern)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PodcastDetailViewState() when $default != null:
return $default(_that.feed,_that.viewMode,_that.episodeFilter,_that.episodeSortOrder,_that.filteredEpisodes,_that.progressMap,_that.smartPlaylists,_that.isSubscribed,_that.hasSmartPlaylistView,_that.activePlaylist,_that.feedImageUrl,_that.subscriptionId,_that.pattern);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ParsedFeed feed,  PodcastViewMode viewMode,  EpisodeFilter episodeFilter,  SortOrder episodeSortOrder,  List<PodcastItem> filteredEpisodes,  EpisodeProgressMap progressMap,  List<SmartPlaylist> smartPlaylists,  bool isSubscribed,  bool hasSmartPlaylistView,  SmartPlaylist? activePlaylist,  String? feedImageUrl,  int? subscriptionId,  SmartPlaylistPatternConfig? pattern)  $default,) {final _that = this;
switch (_that) {
case _PodcastDetailViewState():
return $default(_that.feed,_that.viewMode,_that.episodeFilter,_that.episodeSortOrder,_that.filteredEpisodes,_that.progressMap,_that.smartPlaylists,_that.isSubscribed,_that.hasSmartPlaylistView,_that.activePlaylist,_that.feedImageUrl,_that.subscriptionId,_that.pattern);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ParsedFeed feed,  PodcastViewMode viewMode,  EpisodeFilter episodeFilter,  SortOrder episodeSortOrder,  List<PodcastItem> filteredEpisodes,  EpisodeProgressMap progressMap,  List<SmartPlaylist> smartPlaylists,  bool isSubscribed,  bool hasSmartPlaylistView,  SmartPlaylist? activePlaylist,  String? feedImageUrl,  int? subscriptionId,  SmartPlaylistPatternConfig? pattern)?  $default,) {final _that = this;
switch (_that) {
case _PodcastDetailViewState() when $default != null:
return $default(_that.feed,_that.viewMode,_that.episodeFilter,_that.episodeSortOrder,_that.filteredEpisodes,_that.progressMap,_that.smartPlaylists,_that.isSubscribed,_that.hasSmartPlaylistView,_that.activePlaylist,_that.feedImageUrl,_that.subscriptionId,_that.pattern);case _:
  return null;

}
}

}

/// @nodoc


class _PodcastDetailViewState implements PodcastDetailViewState {
  const _PodcastDetailViewState({required this.feed, required this.viewMode, required this.episodeFilter, required this.episodeSortOrder, required final  List<PodcastItem> filteredEpisodes, required final  EpisodeProgressMap progressMap, required final  List<SmartPlaylist> smartPlaylists, required this.isSubscribed, required this.hasSmartPlaylistView, this.activePlaylist, this.feedImageUrl, this.subscriptionId, this.pattern}): _filteredEpisodes = filteredEpisodes,_progressMap = progressMap,_smartPlaylists = smartPlaylists;


@override final  ParsedFeed feed;
@override final  PodcastViewMode viewMode;
@override final  EpisodeFilter episodeFilter;
@override final  SortOrder episodeSortOrder;
 final  List<PodcastItem> _filteredEpisodes;
@override List<PodcastItem> get filteredEpisodes {
  if (_filteredEpisodes is EqualUnmodifiableListView) return _filteredEpisodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filteredEpisodes);
}

 final  EpisodeProgressMap _progressMap;
@override EpisodeProgressMap get progressMap {
  if (_progressMap is EqualUnmodifiableMapView) return _progressMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_progressMap);
}

 final  List<SmartPlaylist> _smartPlaylists;
@override List<SmartPlaylist> get smartPlaylists {
  if (_smartPlaylists is EqualUnmodifiableListView) return _smartPlaylists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_smartPlaylists);
}

@override final  bool isSubscribed;
@override final  bool hasSmartPlaylistView;
@override final  SmartPlaylist? activePlaylist;
@override final  String? feedImageUrl;
@override final  int? subscriptionId;
@override final  SmartPlaylistPatternConfig? pattern;

/// Create a copy of PodcastDetailViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PodcastDetailViewStateCopyWith<_PodcastDetailViewState> get copyWith => __$PodcastDetailViewStateCopyWithImpl<_PodcastDetailViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PodcastDetailViewState&&(identical(other.feed, feed) || other.feed == feed)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.episodeFilter, episodeFilter) || other.episodeFilter == episodeFilter)&&(identical(other.episodeSortOrder, episodeSortOrder) || other.episodeSortOrder == episodeSortOrder)&&const DeepCollectionEquality().equals(other._filteredEpisodes, _filteredEpisodes)&&const DeepCollectionEquality().equals(other._progressMap, _progressMap)&&const DeepCollectionEquality().equals(other._smartPlaylists, _smartPlaylists)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&(identical(other.hasSmartPlaylistView, hasSmartPlaylistView) || other.hasSmartPlaylistView == hasSmartPlaylistView)&&(identical(other.activePlaylist, activePlaylist) || other.activePlaylist == activePlaylist)&&(identical(other.feedImageUrl, feedImageUrl) || other.feedImageUrl == feedImageUrl)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.pattern, pattern) || other.pattern == pattern));
}


@override
int get hashCode => Object.hash(runtimeType,feed,viewMode,episodeFilter,episodeSortOrder,const DeepCollectionEquality().hash(_filteredEpisodes),const DeepCollectionEquality().hash(_progressMap),const DeepCollectionEquality().hash(_smartPlaylists),isSubscribed,hasSmartPlaylistView,activePlaylist,feedImageUrl,subscriptionId,pattern);

@override
String toString() {
  return 'PodcastDetailViewState(feed: $feed, viewMode: $viewMode, episodeFilter: $episodeFilter, episodeSortOrder: $episodeSortOrder, filteredEpisodes: $filteredEpisodes, progressMap: $progressMap, smartPlaylists: $smartPlaylists, isSubscribed: $isSubscribed, hasSmartPlaylistView: $hasSmartPlaylistView, activePlaylist: $activePlaylist, feedImageUrl: $feedImageUrl, subscriptionId: $subscriptionId, pattern: $pattern)';
}


}

/// @nodoc
abstract mixin class _$PodcastDetailViewStateCopyWith<$Res> implements $PodcastDetailViewStateCopyWith<$Res> {
  factory _$PodcastDetailViewStateCopyWith(_PodcastDetailViewState value, $Res Function(_PodcastDetailViewState) _then) = __$PodcastDetailViewStateCopyWithImpl;
@override @useResult
$Res call({
 ParsedFeed feed, PodcastViewMode viewMode, EpisodeFilter episodeFilter, SortOrder episodeSortOrder, List<PodcastItem> filteredEpisodes, EpisodeProgressMap progressMap, List<SmartPlaylist> smartPlaylists, bool isSubscribed, bool hasSmartPlaylistView, SmartPlaylist? activePlaylist, String? feedImageUrl, int? subscriptionId, SmartPlaylistPatternConfig? pattern
});




}
/// @nodoc
class __$PodcastDetailViewStateCopyWithImpl<$Res>
    implements _$PodcastDetailViewStateCopyWith<$Res> {
  __$PodcastDetailViewStateCopyWithImpl(this._self, this._then);

  final _PodcastDetailViewState _self;
  final $Res Function(_PodcastDetailViewState) _then;

/// Create a copy of PodcastDetailViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? feed = null,Object? viewMode = null,Object? episodeFilter = null,Object? episodeSortOrder = null,Object? filteredEpisodes = null,Object? progressMap = null,Object? smartPlaylists = null,Object? isSubscribed = null,Object? hasSmartPlaylistView = null,Object? activePlaylist = freezed,Object? feedImageUrl = freezed,Object? subscriptionId = freezed,Object? pattern = freezed,}) {
  return _then(_PodcastDetailViewState(
feed: null == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as ParsedFeed,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as PodcastViewMode,episodeFilter: null == episodeFilter ? _self.episodeFilter : episodeFilter // ignore: cast_nullable_to_non_nullable
as EpisodeFilter,episodeSortOrder: null == episodeSortOrder ? _self.episodeSortOrder : episodeSortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,filteredEpisodes: null == filteredEpisodes ? _self._filteredEpisodes : filteredEpisodes // ignore: cast_nullable_to_non_nullable
as List<PodcastItem>,progressMap: null == progressMap ? _self._progressMap : progressMap // ignore: cast_nullable_to_non_nullable
as EpisodeProgressMap,smartPlaylists: null == smartPlaylists ? _self._smartPlaylists : smartPlaylists // ignore: cast_nullable_to_non_nullable
as List<SmartPlaylist>,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,hasSmartPlaylistView: null == hasSmartPlaylistView ? _self.hasSmartPlaylistView : hasSmartPlaylistView // ignore: cast_nullable_to_non_nullable
as bool,activePlaylist: freezed == activePlaylist ? _self.activePlaylist : activePlaylist // ignore: cast_nullable_to_non_nullable
as SmartPlaylist?,feedImageUrl: freezed == feedImageUrl ? _self.feedImageUrl : feedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as int?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as SmartPlaylistPatternConfig?,
  ));
}


}

// dart format on
