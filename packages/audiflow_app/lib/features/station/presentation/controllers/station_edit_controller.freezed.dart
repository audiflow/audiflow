// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station_edit_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StationEditState {

 String get name; Set<int> get selectedPodcastIds; StationPlaybackState get playbackState; bool get filterDownloaded; bool get filterFavorited; StationDurationFilter? get durationFilter; int? get publishedWithinDays; StationEpisodeSort get episodeSort; bool get isSaving; String? get error;
/// Create a copy of StationEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StationEditStateCopyWith<StationEditState> get copyWith => _$StationEditStateCopyWithImpl<StationEditState>(this as StationEditState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StationEditState&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.selectedPodcastIds, selectedPodcastIds)&&(identical(other.playbackState, playbackState) || other.playbackState == playbackState)&&(identical(other.filterDownloaded, filterDownloaded) || other.filterDownloaded == filterDownloaded)&&(identical(other.filterFavorited, filterFavorited) || other.filterFavorited == filterFavorited)&&(identical(other.durationFilter, durationFilter) || other.durationFilter == durationFilter)&&(identical(other.publishedWithinDays, publishedWithinDays) || other.publishedWithinDays == publishedWithinDays)&&(identical(other.episodeSort, episodeSort) || other.episodeSort == episodeSort)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(selectedPodcastIds),playbackState,filterDownloaded,filterFavorited,durationFilter,publishedWithinDays,episodeSort,isSaving,error);

@override
String toString() {
  return 'StationEditState(name: $name, selectedPodcastIds: $selectedPodcastIds, playbackState: $playbackState, filterDownloaded: $filterDownloaded, filterFavorited: $filterFavorited, durationFilter: $durationFilter, publishedWithinDays: $publishedWithinDays, episodeSort: $episodeSort, isSaving: $isSaving, error: $error)';
}


}

/// @nodoc
abstract mixin class $StationEditStateCopyWith<$Res>  {
  factory $StationEditStateCopyWith(StationEditState value, $Res Function(StationEditState) _then) = _$StationEditStateCopyWithImpl;
@useResult
$Res call({
 String name, Set<int> selectedPodcastIds, StationPlaybackState playbackState, bool filterDownloaded, bool filterFavorited, StationDurationFilter? durationFilter, int? publishedWithinDays, StationEpisodeSort episodeSort, bool isSaving, String? error
});




}
/// @nodoc
class _$StationEditStateCopyWithImpl<$Res>
    implements $StationEditStateCopyWith<$Res> {
  _$StationEditStateCopyWithImpl(this._self, this._then);

  final StationEditState _self;
  final $Res Function(StationEditState) _then;

/// Create a copy of StationEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? selectedPodcastIds = null,Object? playbackState = null,Object? filterDownloaded = null,Object? filterFavorited = null,Object? durationFilter = freezed,Object? publishedWithinDays = freezed,Object? episodeSort = null,Object? isSaving = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selectedPodcastIds: null == selectedPodcastIds ? _self.selectedPodcastIds : selectedPodcastIds // ignore: cast_nullable_to_non_nullable
as Set<int>,playbackState: null == playbackState ? _self.playbackState : playbackState // ignore: cast_nullable_to_non_nullable
as StationPlaybackState,filterDownloaded: null == filterDownloaded ? _self.filterDownloaded : filterDownloaded // ignore: cast_nullable_to_non_nullable
as bool,filterFavorited: null == filterFavorited ? _self.filterFavorited : filterFavorited // ignore: cast_nullable_to_non_nullable
as bool,durationFilter: freezed == durationFilter ? _self.durationFilter : durationFilter // ignore: cast_nullable_to_non_nullable
as StationDurationFilter?,publishedWithinDays: freezed == publishedWithinDays ? _self.publishedWithinDays : publishedWithinDays // ignore: cast_nullable_to_non_nullable
as int?,episodeSort: null == episodeSort ? _self.episodeSort : episodeSort // ignore: cast_nullable_to_non_nullable
as StationEpisodeSort,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StationEditState].
extension StationEditStatePatterns on StationEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StationEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StationEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StationEditState value)  $default,){
final _that = this;
switch (_that) {
case _StationEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StationEditState value)?  $default,){
final _that = this;
switch (_that) {
case _StationEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Set<int> selectedPodcastIds,  StationPlaybackState playbackState,  bool filterDownloaded,  bool filterFavorited,  StationDurationFilter? durationFilter,  int? publishedWithinDays,  StationEpisodeSort episodeSort,  bool isSaving,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StationEditState() when $default != null:
return $default(_that.name,_that.selectedPodcastIds,_that.playbackState,_that.filterDownloaded,_that.filterFavorited,_that.durationFilter,_that.publishedWithinDays,_that.episodeSort,_that.isSaving,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Set<int> selectedPodcastIds,  StationPlaybackState playbackState,  bool filterDownloaded,  bool filterFavorited,  StationDurationFilter? durationFilter,  int? publishedWithinDays,  StationEpisodeSort episodeSort,  bool isSaving,  String? error)  $default,) {final _that = this;
switch (_that) {
case _StationEditState():
return $default(_that.name,_that.selectedPodcastIds,_that.playbackState,_that.filterDownloaded,_that.filterFavorited,_that.durationFilter,_that.publishedWithinDays,_that.episodeSort,_that.isSaving,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Set<int> selectedPodcastIds,  StationPlaybackState playbackState,  bool filterDownloaded,  bool filterFavorited,  StationDurationFilter? durationFilter,  int? publishedWithinDays,  StationEpisodeSort episodeSort,  bool isSaving,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _StationEditState() when $default != null:
return $default(_that.name,_that.selectedPodcastIds,_that.playbackState,_that.filterDownloaded,_that.filterFavorited,_that.durationFilter,_that.publishedWithinDays,_that.episodeSort,_that.isSaving,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _StationEditState implements StationEditState {
  const _StationEditState({this.name = '', final  Set<int> selectedPodcastIds = const {}, this.playbackState = StationPlaybackState.all, this.filterDownloaded = false, this.filterFavorited = false, this.durationFilter, this.publishedWithinDays, this.episodeSort = StationEpisodeSort.newest, this.isSaving = false, this.error}): _selectedPodcastIds = selectedPodcastIds;
  

@override@JsonKey() final  String name;
 final  Set<int> _selectedPodcastIds;
@override@JsonKey() Set<int> get selectedPodcastIds {
  if (_selectedPodcastIds is EqualUnmodifiableSetView) return _selectedPodcastIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedPodcastIds);
}

@override@JsonKey() final  StationPlaybackState playbackState;
@override@JsonKey() final  bool filterDownloaded;
@override@JsonKey() final  bool filterFavorited;
@override final  StationDurationFilter? durationFilter;
@override final  int? publishedWithinDays;
@override@JsonKey() final  StationEpisodeSort episodeSort;
@override@JsonKey() final  bool isSaving;
@override final  String? error;

/// Create a copy of StationEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StationEditStateCopyWith<_StationEditState> get copyWith => __$StationEditStateCopyWithImpl<_StationEditState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StationEditState&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._selectedPodcastIds, _selectedPodcastIds)&&(identical(other.playbackState, playbackState) || other.playbackState == playbackState)&&(identical(other.filterDownloaded, filterDownloaded) || other.filterDownloaded == filterDownloaded)&&(identical(other.filterFavorited, filterFavorited) || other.filterFavorited == filterFavorited)&&(identical(other.durationFilter, durationFilter) || other.durationFilter == durationFilter)&&(identical(other.publishedWithinDays, publishedWithinDays) || other.publishedWithinDays == publishedWithinDays)&&(identical(other.episodeSort, episodeSort) || other.episodeSort == episodeSort)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_selectedPodcastIds),playbackState,filterDownloaded,filterFavorited,durationFilter,publishedWithinDays,episodeSort,isSaving,error);

@override
String toString() {
  return 'StationEditState(name: $name, selectedPodcastIds: $selectedPodcastIds, playbackState: $playbackState, filterDownloaded: $filterDownloaded, filterFavorited: $filterFavorited, durationFilter: $durationFilter, publishedWithinDays: $publishedWithinDays, episodeSort: $episodeSort, isSaving: $isSaving, error: $error)';
}


}

/// @nodoc
abstract mixin class _$StationEditStateCopyWith<$Res> implements $StationEditStateCopyWith<$Res> {
  factory _$StationEditStateCopyWith(_StationEditState value, $Res Function(_StationEditState) _then) = __$StationEditStateCopyWithImpl;
@override @useResult
$Res call({
 String name, Set<int> selectedPodcastIds, StationPlaybackState playbackState, bool filterDownloaded, bool filterFavorited, StationDurationFilter? durationFilter, int? publishedWithinDays, StationEpisodeSort episodeSort, bool isSaving, String? error
});




}
/// @nodoc
class __$StationEditStateCopyWithImpl<$Res>
    implements _$StationEditStateCopyWith<$Res> {
  __$StationEditStateCopyWithImpl(this._self, this._then);

  final _StationEditState _self;
  final $Res Function(_StationEditState) _then;

/// Create a copy of StationEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? selectedPodcastIds = null,Object? playbackState = null,Object? filterDownloaded = null,Object? filterFavorited = null,Object? durationFilter = freezed,Object? publishedWithinDays = freezed,Object? episodeSort = null,Object? isSaving = null,Object? error = freezed,}) {
  return _then(_StationEditState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selectedPodcastIds: null == selectedPodcastIds ? _self._selectedPodcastIds : selectedPodcastIds // ignore: cast_nullable_to_non_nullable
as Set<int>,playbackState: null == playbackState ? _self.playbackState : playbackState // ignore: cast_nullable_to_non_nullable
as StationPlaybackState,filterDownloaded: null == filterDownloaded ? _self.filterDownloaded : filterDownloaded // ignore: cast_nullable_to_non_nullable
as bool,filterFavorited: null == filterFavorited ? _self.filterFavorited : filterFavorited // ignore: cast_nullable_to_non_nullable
as bool,durationFilter: freezed == durationFilter ? _self.durationFilter : durationFilter // ignore: cast_nullable_to_non_nullable
as StationDurationFilter?,publishedWithinDays: freezed == publishedWithinDays ? _self.publishedWithinDays : publishedWithinDays // ignore: cast_nullable_to_non_nullable
as int?,episodeSort: null == episodeSort ? _self.episodeSort : episodeSort // ignore: cast_nullable_to_non_nullable
as StationEpisodeSort,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
