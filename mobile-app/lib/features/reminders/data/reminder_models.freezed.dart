// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reminder {

 int get id; int get cropId; String get title;@JsonKey(unknownEnumValue: ReminderType.other) ReminderType get type;@LocalDateTimeConverter() DateTime get reminderAt; bool get enabled; bool get aiRecommended; bool get completed; String? get note;
/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderCopyWith<Reminder> get copyWith => _$ReminderCopyWithImpl<Reminder>(this as Reminder, _$identity);

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.reminderAt, reminderAt) || other.reminderAt == reminderAt)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.aiRecommended, aiRecommended) || other.aiRecommended == aiRecommended)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cropId,title,type,reminderAt,enabled,aiRecommended,completed,note);

@override
String toString() {
  return 'Reminder(id: $id, cropId: $cropId, title: $title, type: $type, reminderAt: $reminderAt, enabled: $enabled, aiRecommended: $aiRecommended, completed: $completed, note: $note)';
}


}

/// @nodoc
abstract mixin class $ReminderCopyWith<$Res>  {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) _then) = _$ReminderCopyWithImpl;
@useResult
$Res call({
 int id, int cropId, String title,@JsonKey(unknownEnumValue: ReminderType.other) ReminderType type,@LocalDateTimeConverter() DateTime reminderAt, bool enabled, bool aiRecommended, bool completed, String? note
});




}
/// @nodoc
class _$ReminderCopyWithImpl<$Res>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._self, this._then);

  final Reminder _self;
  final $Res Function(Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cropId = null,Object? title = null,Object? type = null,Object? reminderAt = null,Object? enabled = null,Object? aiRecommended = null,Object? completed = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReminderType,reminderAt: null == reminderAt ? _self.reminderAt : reminderAt // ignore: cast_nullable_to_non_nullable
as DateTime,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,aiRecommended: null == aiRecommended ? _self.aiRecommended : aiRecommended // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Reminder].
extension ReminderPatterns on Reminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reminder value)  $default,){
final _that = this;
switch (_that) {
case _Reminder():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reminder value)?  $default,){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int cropId,  String title, @JsonKey(unknownEnumValue: ReminderType.other)  ReminderType type, @LocalDateTimeConverter()  DateTime reminderAt,  bool enabled,  bool aiRecommended,  bool completed,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.cropId,_that.title,_that.type,_that.reminderAt,_that.enabled,_that.aiRecommended,_that.completed,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int cropId,  String title, @JsonKey(unknownEnumValue: ReminderType.other)  ReminderType type, @LocalDateTimeConverter()  DateTime reminderAt,  bool enabled,  bool aiRecommended,  bool completed,  String? note)  $default,) {final _that = this;
switch (_that) {
case _Reminder():
return $default(_that.id,_that.cropId,_that.title,_that.type,_that.reminderAt,_that.enabled,_that.aiRecommended,_that.completed,_that.note);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int cropId,  String title, @JsonKey(unknownEnumValue: ReminderType.other)  ReminderType type, @LocalDateTimeConverter()  DateTime reminderAt,  bool enabled,  bool aiRecommended,  bool completed,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.cropId,_that.title,_that.type,_that.reminderAt,_that.enabled,_that.aiRecommended,_that.completed,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reminder implements Reminder {
  const _Reminder({required this.id, required this.cropId, required this.title, @JsonKey(unknownEnumValue: ReminderType.other) this.type = ReminderType.other, @LocalDateTimeConverter() required this.reminderAt, this.enabled = true, this.aiRecommended = false, this.completed = false, this.note});
  factory _Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);

@override final  int id;
@override final  int cropId;
@override final  String title;
@override@JsonKey(unknownEnumValue: ReminderType.other) final  ReminderType type;
@override@LocalDateTimeConverter() final  DateTime reminderAt;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool aiRecommended;
@override@JsonKey() final  bool completed;
@override final  String? note;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderCopyWith<_Reminder> get copyWith => __$ReminderCopyWithImpl<_Reminder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReminderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.reminderAt, reminderAt) || other.reminderAt == reminderAt)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.aiRecommended, aiRecommended) || other.aiRecommended == aiRecommended)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cropId,title,type,reminderAt,enabled,aiRecommended,completed,note);

@override
String toString() {
  return 'Reminder(id: $id, cropId: $cropId, title: $title, type: $type, reminderAt: $reminderAt, enabled: $enabled, aiRecommended: $aiRecommended, completed: $completed, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ReminderCopyWith<$Res> implements $ReminderCopyWith<$Res> {
  factory _$ReminderCopyWith(_Reminder value, $Res Function(_Reminder) _then) = __$ReminderCopyWithImpl;
@override @useResult
$Res call({
 int id, int cropId, String title,@JsonKey(unknownEnumValue: ReminderType.other) ReminderType type,@LocalDateTimeConverter() DateTime reminderAt, bool enabled, bool aiRecommended, bool completed, String? note
});




}
/// @nodoc
class __$ReminderCopyWithImpl<$Res>
    implements _$ReminderCopyWith<$Res> {
  __$ReminderCopyWithImpl(this._self, this._then);

  final _Reminder _self;
  final $Res Function(_Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cropId = null,Object? title = null,Object? type = null,Object? reminderAt = null,Object? enabled = null,Object? aiRecommended = null,Object? completed = null,Object? note = freezed,}) {
  return _then(_Reminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReminderType,reminderAt: null == reminderAt ? _self.reminderAt : reminderAt // ignore: cast_nullable_to_non_nullable
as DateTime,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,aiRecommended: null == aiRecommended ? _self.aiRecommended : aiRecommended // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
