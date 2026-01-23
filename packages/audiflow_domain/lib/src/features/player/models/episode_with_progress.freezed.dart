// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_with_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EpisodeWithProgress {

 Episode get episode; PlaybackHistory? get history;
/// Create a copy of EpisodeWithProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeWithProgressCopyWith<EpisodeWithProgress> get copyWith => _$EpisodeWithProgressCopyWithImpl<EpisodeWithProgress>(this as EpisodeWithProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpisodeWithProgress&&const DeepCollectionEquality().equals(other.episode, episode)&&const DeepCollectionEquality().equals(other.history, history));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(episode),const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'EpisodeWithProgress(episode: $episode, history: $history)';
}


}

/// @nodoc
abstract mixin class $EpisodeWithProgressCopyWith<$Res>  {
  factory $EpisodeWithProgressCopyWith(EpisodeWithProgress value, $Res Function(EpisodeWithProgress) _then) = _$EpisodeWithProgressCopyWithImpl;
@useResult
$Res call({
 Episode episode, PlaybackHistory? history
});




}
/// @nodoc
class _$EpisodeWithProgressCopyWithImpl<$Res>
    implements $EpisodeWithProgressCopyWith<$Res> {
  _$EpisodeWithProgressCopyWithImpl(this._self, this._then);

  final EpisodeWithProgress _self;
  final $Res Function(EpisodeWithProgress) _then;

/// Create a copy of EpisodeWithProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? episode = freezed,Object? history = freezed,}) {
  return _then(_self.copyWith(
episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as Episode,history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as PlaybackHistory?,
  ));
}

}


/// Adds pattern-matching-related methods to [EpisodeWithProgress].
extension EpisodeWithProgressPatterns on EpisodeWithProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpisodeWithProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpisodeWithProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpisodeWithProgress value)  $default,){
final _that = this;
switch (_that) {
case _EpisodeWithProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpisodeWithProgress value)?  $default,){
final _that = this;
switch (_that) {
case _EpisodeWithProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Episode episode,  PlaybackHistory? history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpisodeWithProgress() when $default != null:
return $default(_that.episode,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Episode episode,  PlaybackHistory? history)  $default,) {final _that = this;
switch (_that) {
case _EpisodeWithProgress():
return $default(_that.episode,_that.history);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Episode episode,  PlaybackHistory? history)?  $default,) {final _that = this;
switch (_that) {
case _EpisodeWithProgress() when $default != null:
return $default(_that.episode,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _EpisodeWithProgress extends EpisodeWithProgress {
  const _EpisodeWithProgress({required this.episode, this.history}): super._();


@override final  Episode episode;
@override final  PlaybackHistory? history;

/// Create a copy of EpisodeWithProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpisodeWithProgressCopyWith<_EpisodeWithProgress> get copyWith => __$EpisodeWithProgressCopyWithImpl<_EpisodeWithProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpisodeWithProgress&&const DeepCollectionEquality().equals(other.episode, episode)&&const DeepCollectionEquality().equals(other.history, history));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(episode),const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'EpisodeWithProgress(episode: $episode, history: $history)';
}


}

/// @nodoc
abstract mixin class _$EpisodeWithProgressCopyWith<$Res> implements $EpisodeWithProgressCopyWith<$Res> {
  factory _$EpisodeWithProgressCopyWith(_EpisodeWithProgress value, $Res Function(_EpisodeWithProgress) _then) = __$EpisodeWithProgressCopyWithImpl;
@override @useResult
$Res call({
 Episode episode, PlaybackHistory? history
});




}
/// @nodoc
class __$EpisodeWithProgressCopyWithImpl<$Res>
    implements _$EpisodeWithProgressCopyWith<$Res> {
  __$EpisodeWithProgressCopyWithImpl(this._self, this._then);

  final _EpisodeWithProgress _self;
  final $Res Function(_EpisodeWithProgress) _then;

/// Create a copy of EpisodeWithProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? episode = freezed,Object? history = freezed,}) {
  return _then(_EpisodeWithProgress(
episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as Episode,history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as PlaybackHistory?,
  ));
}


}

// dart format on
