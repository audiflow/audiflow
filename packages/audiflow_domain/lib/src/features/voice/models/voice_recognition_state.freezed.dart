// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_recognition_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoiceRecognitionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRecognitionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoiceRecognitionState()';
}


}

/// @nodoc
class $VoiceRecognitionStateCopyWith<$Res>  {
$VoiceRecognitionStateCopyWith(VoiceRecognitionState _, $Res Function(VoiceRecognitionState) __);
}


/// Adds pattern-matching-related methods to [VoiceRecognitionState].
extension VoiceRecognitionStatePatterns on VoiceRecognitionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VoiceIdle value)?  idle,TResult Function( VoiceListening value)?  listening,TResult Function( VoiceProcessing value)?  processing,TResult Function( VoiceExecuting value)?  executing,TResult Function( VoiceSuccess value)?  success,TResult Function( VoiceError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VoiceIdle() when idle != null:
return idle(_that);case VoiceListening() when listening != null:
return listening(_that);case VoiceProcessing() when processing != null:
return processing(_that);case VoiceExecuting() when executing != null:
return executing(_that);case VoiceSuccess() when success != null:
return success(_that);case VoiceError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VoiceIdle value)  idle,required TResult Function( VoiceListening value)  listening,required TResult Function( VoiceProcessing value)  processing,required TResult Function( VoiceExecuting value)  executing,required TResult Function( VoiceSuccess value)  success,required TResult Function( VoiceError value)  error,}){
final _that = this;
switch (_that) {
case VoiceIdle():
return idle(_that);case VoiceListening():
return listening(_that);case VoiceProcessing():
return processing(_that);case VoiceExecuting():
return executing(_that);case VoiceSuccess():
return success(_that);case VoiceError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VoiceIdle value)?  idle,TResult? Function( VoiceListening value)?  listening,TResult? Function( VoiceProcessing value)?  processing,TResult? Function( VoiceExecuting value)?  executing,TResult? Function( VoiceSuccess value)?  success,TResult? Function( VoiceError value)?  error,}){
final _that = this;
switch (_that) {
case VoiceIdle() when idle != null:
return idle(_that);case VoiceListening() when listening != null:
return listening(_that);case VoiceProcessing() when processing != null:
return processing(_that);case VoiceExecuting() when executing != null:
return executing(_that);case VoiceSuccess() when success != null:
return success(_that);case VoiceError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String? partialTranscript)?  listening,TResult Function( String transcription)?  processing,TResult Function( VoiceCommand command)?  executing,TResult Function( String message)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VoiceIdle() when idle != null:
return idle();case VoiceListening() when listening != null:
return listening(_that.partialTranscript);case VoiceProcessing() when processing != null:
return processing(_that.transcription);case VoiceExecuting() when executing != null:
return executing(_that.command);case VoiceSuccess() when success != null:
return success(_that.message);case VoiceError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String? partialTranscript)  listening,required TResult Function( String transcription)  processing,required TResult Function( VoiceCommand command)  executing,required TResult Function( String message)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case VoiceIdle():
return idle();case VoiceListening():
return listening(_that.partialTranscript);case VoiceProcessing():
return processing(_that.transcription);case VoiceExecuting():
return executing(_that.command);case VoiceSuccess():
return success(_that.message);case VoiceError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String? partialTranscript)?  listening,TResult? Function( String transcription)?  processing,TResult? Function( VoiceCommand command)?  executing,TResult? Function( String message)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case VoiceIdle() when idle != null:
return idle();case VoiceListening() when listening != null:
return listening(_that.partialTranscript);case VoiceProcessing() when processing != null:
return processing(_that.transcription);case VoiceExecuting() when executing != null:
return executing(_that.command);case VoiceSuccess() when success != null:
return success(_that.message);case VoiceError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class VoiceIdle implements VoiceRecognitionState {
  const VoiceIdle();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoiceRecognitionState.idle()';
}


}




/// @nodoc


class VoiceListening implements VoiceRecognitionState {
  const VoiceListening({this.partialTranscript});


/// Partial transcription as user speaks.
 final  String? partialTranscript;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceListeningCopyWith<VoiceListening> get copyWith => _$VoiceListeningCopyWithImpl<VoiceListening>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceListening&&(identical(other.partialTranscript, partialTranscript) || other.partialTranscript == partialTranscript));
}


@override
int get hashCode => Object.hash(runtimeType,partialTranscript);

@override
String toString() {
  return 'VoiceRecognitionState.listening(partialTranscript: $partialTranscript)';
}


}

/// @nodoc
abstract mixin class $VoiceListeningCopyWith<$Res> implements $VoiceRecognitionStateCopyWith<$Res> {
  factory $VoiceListeningCopyWith(VoiceListening value, $Res Function(VoiceListening) _then) = _$VoiceListeningCopyWithImpl;
@useResult
$Res call({
 String? partialTranscript
});




}
/// @nodoc
class _$VoiceListeningCopyWithImpl<$Res>
    implements $VoiceListeningCopyWith<$Res> {
  _$VoiceListeningCopyWithImpl(this._self, this._then);

  final VoiceListening _self;
  final $Res Function(VoiceListening) _then;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? partialTranscript = freezed,}) {
  return _then(VoiceListening(
partialTranscript: freezed == partialTranscript ? _self.partialTranscript : partialTranscript // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class VoiceProcessing implements VoiceRecognitionState {
  const VoiceProcessing({required this.transcription});


/// The finalized transcription text.
 final  String transcription;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceProcessingCopyWith<VoiceProcessing> get copyWith => _$VoiceProcessingCopyWithImpl<VoiceProcessing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceProcessing&&(identical(other.transcription, transcription) || other.transcription == transcription));
}


@override
int get hashCode => Object.hash(runtimeType,transcription);

@override
String toString() {
  return 'VoiceRecognitionState.processing(transcription: $transcription)';
}


}

/// @nodoc
abstract mixin class $VoiceProcessingCopyWith<$Res> implements $VoiceRecognitionStateCopyWith<$Res> {
  factory $VoiceProcessingCopyWith(VoiceProcessing value, $Res Function(VoiceProcessing) _then) = _$VoiceProcessingCopyWithImpl;
@useResult
$Res call({
 String transcription
});




}
/// @nodoc
class _$VoiceProcessingCopyWithImpl<$Res>
    implements $VoiceProcessingCopyWith<$Res> {
  _$VoiceProcessingCopyWithImpl(this._self, this._then);

  final VoiceProcessing _self;
  final $Res Function(VoiceProcessing) _then;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transcription = null,}) {
  return _then(VoiceProcessing(
transcription: null == transcription ? _self.transcription : transcription // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VoiceExecuting implements VoiceRecognitionState {
  const VoiceExecuting({required this.command});


/// The parsed command being executed.
 final  VoiceCommand command;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceExecutingCopyWith<VoiceExecuting> get copyWith => _$VoiceExecutingCopyWithImpl<VoiceExecuting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceExecuting&&(identical(other.command, command) || other.command == command));
}


@override
int get hashCode => Object.hash(runtimeType,command);

@override
String toString() {
  return 'VoiceRecognitionState.executing(command: $command)';
}


}

/// @nodoc
abstract mixin class $VoiceExecutingCopyWith<$Res> implements $VoiceRecognitionStateCopyWith<$Res> {
  factory $VoiceExecutingCopyWith(VoiceExecuting value, $Res Function(VoiceExecuting) _then) = _$VoiceExecutingCopyWithImpl;
@useResult
$Res call({
 VoiceCommand command
});




}
/// @nodoc
class _$VoiceExecutingCopyWithImpl<$Res>
    implements $VoiceExecutingCopyWith<$Res> {
  _$VoiceExecutingCopyWithImpl(this._self, this._then);

  final VoiceExecuting _self;
  final $Res Function(VoiceExecuting) _then;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? command = null,}) {
  return _then(VoiceExecuting(
command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as VoiceCommand,
  ));
}


}

/// @nodoc


class VoiceSuccess implements VoiceRecognitionState {
  const VoiceSuccess({required this.message});


/// Human-readable success message.
 final  String message;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceSuccessCopyWith<VoiceSuccess> get copyWith => _$VoiceSuccessCopyWithImpl<VoiceSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceSuccess&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VoiceRecognitionState.success(message: $message)';
}


}

/// @nodoc
abstract mixin class $VoiceSuccessCopyWith<$Res> implements $VoiceRecognitionStateCopyWith<$Res> {
  factory $VoiceSuccessCopyWith(VoiceSuccess value, $Res Function(VoiceSuccess) _then) = _$VoiceSuccessCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$VoiceSuccessCopyWithImpl<$Res>
    implements $VoiceSuccessCopyWith<$Res> {
  _$VoiceSuccessCopyWithImpl(this._self, this._then);

  final VoiceSuccess _self;
  final $Res Function(VoiceSuccess) _then;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(VoiceSuccess(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VoiceError implements VoiceRecognitionState {
  const VoiceError({required this.message});


/// Human-readable error message.
 final  String message;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceErrorCopyWith<VoiceError> get copyWith => _$VoiceErrorCopyWithImpl<VoiceError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VoiceRecognitionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $VoiceErrorCopyWith<$Res> implements $VoiceRecognitionStateCopyWith<$Res> {
  factory $VoiceErrorCopyWith(VoiceError value, $Res Function(VoiceError) _then) = _$VoiceErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$VoiceErrorCopyWithImpl<$Res>
    implements $VoiceErrorCopyWith<$Res> {
  _$VoiceErrorCopyWithImpl(this._self, this._then);

  final VoiceError _self;
  final $Res Function(VoiceError) _then;

/// Create a copy of VoiceRecognitionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(VoiceError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
