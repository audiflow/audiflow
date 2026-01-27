// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatus()';
}


}

/// @nodoc
class $DownloadStatusCopyWith<$Res>  {
$DownloadStatusCopyWith(DownloadStatus _, $Res Function(DownloadStatus) __);
}


/// Adds pattern-matching-related methods to [DownloadStatus].
extension DownloadStatusPatterns on DownloadStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DownloadStatusPending value)?  pending,TResult Function( DownloadStatusDownloading value)?  downloading,TResult Function( DownloadStatusPaused value)?  paused,TResult Function( DownloadStatusCompleted value)?  completed,TResult Function( DownloadStatusFailed value)?  failed,TResult Function( DownloadStatusCancelled value)?  cancelled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DownloadStatusPending() when pending != null:
return pending(_that);case DownloadStatusDownloading() when downloading != null:
return downloading(_that);case DownloadStatusPaused() when paused != null:
return paused(_that);case DownloadStatusCompleted() when completed != null:
return completed(_that);case DownloadStatusFailed() when failed != null:
return failed(_that);case DownloadStatusCancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DownloadStatusPending value)  pending,required TResult Function( DownloadStatusDownloading value)  downloading,required TResult Function( DownloadStatusPaused value)  paused,required TResult Function( DownloadStatusCompleted value)  completed,required TResult Function( DownloadStatusFailed value)  failed,required TResult Function( DownloadStatusCancelled value)  cancelled,}){
final _that = this;
switch (_that) {
case DownloadStatusPending():
return pending(_that);case DownloadStatusDownloading():
return downloading(_that);case DownloadStatusPaused():
return paused(_that);case DownloadStatusCompleted():
return completed(_that);case DownloadStatusFailed():
return failed(_that);case DownloadStatusCancelled():
return cancelled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DownloadStatusPending value)?  pending,TResult? Function( DownloadStatusDownloading value)?  downloading,TResult? Function( DownloadStatusPaused value)?  paused,TResult? Function( DownloadStatusCompleted value)?  completed,TResult? Function( DownloadStatusFailed value)?  failed,TResult? Function( DownloadStatusCancelled value)?  cancelled,}){
final _that = this;
switch (_that) {
case DownloadStatusPending() when pending != null:
return pending(_that);case DownloadStatusDownloading() when downloading != null:
return downloading(_that);case DownloadStatusPaused() when paused != null:
return paused(_that);case DownloadStatusCompleted() when completed != null:
return completed(_that);case DownloadStatusFailed() when failed != null:
return failed(_that);case DownloadStatusCancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  pending,TResult Function()?  downloading,TResult Function()?  paused,TResult Function()?  completed,TResult Function()?  failed,TResult Function()?  cancelled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DownloadStatusPending() when pending != null:
return pending();case DownloadStatusDownloading() when downloading != null:
return downloading();case DownloadStatusPaused() when paused != null:
return paused();case DownloadStatusCompleted() when completed != null:
return completed();case DownloadStatusFailed() when failed != null:
return failed();case DownloadStatusCancelled() when cancelled != null:
return cancelled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  pending,required TResult Function()  downloading,required TResult Function()  paused,required TResult Function()  completed,required TResult Function()  failed,required TResult Function()  cancelled,}) {final _that = this;
switch (_that) {
case DownloadStatusPending():
return pending();case DownloadStatusDownloading():
return downloading();case DownloadStatusPaused():
return paused();case DownloadStatusCompleted():
return completed();case DownloadStatusFailed():
return failed();case DownloadStatusCancelled():
return cancelled();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  pending,TResult? Function()?  downloading,TResult? Function()?  paused,TResult? Function()?  completed,TResult? Function()?  failed,TResult? Function()?  cancelled,}) {final _that = this;
switch (_that) {
case DownloadStatusPending() when pending != null:
return pending();case DownloadStatusDownloading() when downloading != null:
return downloading();case DownloadStatusPaused() when paused != null:
return paused();case DownloadStatusCompleted() when completed != null:
return completed();case DownloadStatusFailed() when failed != null:
return failed();case DownloadStatusCancelled() when cancelled != null:
return cancelled();case _:
  return null;

}
}

}

/// @nodoc


class DownloadStatusPending extends DownloadStatus {
  const DownloadStatusPending(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusPending);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatus.pending()';
}


}




/// @nodoc


class DownloadStatusDownloading extends DownloadStatus {
  const DownloadStatusDownloading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusDownloading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatus.downloading()';
}


}




/// @nodoc


class DownloadStatusPaused extends DownloadStatus {
  const DownloadStatusPaused(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusPaused);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatus.paused()';
}


}




/// @nodoc


class DownloadStatusCompleted extends DownloadStatus {
  const DownloadStatusCompleted(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatus.completed()';
}


}




/// @nodoc


class DownloadStatusFailed extends DownloadStatus {
  const DownloadStatusFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatus.failed()';
}


}




/// @nodoc


class DownloadStatusCancelled extends DownloadStatus {
  const DownloadStatusCancelled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatus.cancelled()';
}


}




// dart format on
