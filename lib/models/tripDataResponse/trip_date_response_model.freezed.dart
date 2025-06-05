// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_date_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripDateResponse _$TripDateResponseFromJson(Map<String, dynamic> json) {
  return _TripDateResponse.fromJson(json);
}


/// @nodoc
mixin _$TripDateResponse {
  List<Promotion> get promotions => throw _privateConstructorUsedError;
  @JsonKey(name: 'trips')
  List<Trip> get trips => throw _privateConstructorUsedError;
  List<TicketType> get tickettypes => throw _privateConstructorUsedError;

  /// Serializes this TripDateResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripDateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripDateResponseCopyWith<TripDateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripDateResponseCopyWith<$Res> {
  factory $TripDateResponseCopyWith(
          TripDateResponse value, $Res Function(TripDateResponse) then) =
      _$TripDateResponseCopyWithImpl<$Res, TripDateResponse>;
  @useResult
  $Res call(
      {List<Promotion> promotions,
      @JsonKey(name: 'trips') List<Trip> trips,
      List<TicketType> tickettypes});
}

/// @nodoc
class _$TripDateResponseCopyWithImpl<$Res, $Val extends TripDateResponse>
    implements $TripDateResponseCopyWith<$Res> {
  _$TripDateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripDateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promotions = null,
    Object? trips = null,
    Object? tickettypes = null,
  }) {
    return _then(_value.copyWith(
      promotions: null == promotions
          ? _value.promotions
          : promotions // ignore: cast_nullable_to_non_nullable
              as List<Promotion>,
      trips: null == trips
          ? _value.trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<Trip>,
      tickettypes: null == tickettypes
          ? _value.tickettypes
          : tickettypes // ignore: cast_nullable_to_non_nullable
              as List<TicketType>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripDateResponseImplCopyWith<$Res>
    implements $TripDateResponseCopyWith<$Res> {
  factory _$$TripDateResponseImplCopyWith(_$TripDateResponseImpl value,
          $Res Function(_$TripDateResponseImpl) then) =
      __$$TripDateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Promotion> promotions,
      @JsonKey(name: 'trips') List<Trip> trips,
      List<TicketType> tickettypes});
}

/// @nodoc
class __$$TripDateResponseImplCopyWithImpl<$Res>
    extends _$TripDateResponseCopyWithImpl<$Res, _$TripDateResponseImpl>
    implements _$$TripDateResponseImplCopyWith<$Res> {
  __$$TripDateResponseImplCopyWithImpl(_$TripDateResponseImpl _value,
      $Res Function(_$TripDateResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripDateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promotions = null,
    Object? trips = null,
    Object? tickettypes = null,
  }) {
    return _then(_$TripDateResponseImpl(
      promotions: null == promotions
          ? _value._promotions
          : promotions // ignore: cast_nullable_to_non_nullable
              as List<Promotion>,
      trips: null == trips
          ? _value._trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<Trip>,
      tickettypes: null == tickettypes
          ? _value._tickettypes
          : tickettypes // ignore: cast_nullable_to_non_nullable
              as List<TicketType>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$TripDateResponseImpl implements _TripDateResponse {
  const _$TripDateResponseImpl(
      {final List<Promotion> promotions = const [],
      @JsonKey(name: 'trips') final List<Trip> trips = const [],
      final List<TicketType> tickettypes = const []})
      : _promotions = promotions,
        _trips = trips,
        _tickettypes = tickettypes;

  factory _$TripDateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripDateResponseImplFromJson(json);

  final List<Promotion> _promotions;
  @override
  @JsonKey()
  List<Promotion> get promotions {
    if (_promotions is EqualUnmodifiableListView) return _promotions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promotions);
  }

  final List<Trip> _trips;
  @override
  @JsonKey(name: 'trips')
  List<Trip> get trips {
    if (_trips is EqualUnmodifiableListView) return _trips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trips);
  }

  final List<TicketType> _tickettypes;
  @override
  @JsonKey()
  List<TicketType> get tickettypes {
    if (_tickettypes is EqualUnmodifiableListView) return _tickettypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tickettypes);
  }

  @override
  String toString() {
    return 'TripDateResponse(promotions: $promotions, trips: $trips, tickettypes: $tickettypes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripDateResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._promotions, _promotions) &&
            const DeepCollectionEquality().equals(other._trips, _trips) &&
            const DeepCollectionEquality()
                .equals(other._tickettypes, _tickettypes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_promotions),
      const DeepCollectionEquality().hash(_trips),
      const DeepCollectionEquality().hash(_tickettypes));

  /// Create a copy of TripDateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripDateResponseImplCopyWith<_$TripDateResponseImpl> get copyWith =>
      __$$TripDateResponseImplCopyWithImpl<_$TripDateResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripDateResponseImplToJson(
      this,
    );
  }
}

abstract class _TripDateResponse implements TripDateResponse {
  const factory _TripDateResponse(
      {final List<Promotion> promotions,
      @JsonKey(name: 'trips') final List<Trip> trips,
      final List<TicketType> tickettypes}) = _$TripDateResponseImpl;

  factory _TripDateResponse.fromJson(Map<String, dynamic> json) =
      _$TripDateResponseImpl.fromJson;

  @override
  List<Promotion> get promotions;
  @override
  @JsonKey(name: 'trips')
  List<Trip> get trips;
  @override
  List<TicketType> get tickettypes;

  /// Create a copy of TripDateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripDateResponseImplCopyWith<_$TripDateResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
