// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_date_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripDateResponseImpl _$$TripDateResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TripDateResponseImpl(
      promotions: (json['promotions'] as List<dynamic>?)
              ?.map((e) => Promotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trips: (json['trips'] as List<dynamic>?)
              ?.map((e) => Trip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tickettypes: (json['tickettypes'] as List<dynamic>?)
              ?.map((e) => TicketType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TripDateResponseImplToJson(
        _$TripDateResponseImpl instance) =>
    <String, dynamic>{
      'promotions': instance.promotions.map((e) => e.toJson()).toList(),
      'trips': instance.trips.map((e) => e.toJson()).toList(),
      'tickettypes': instance.tickettypes.map((e) => e.toJson()).toList(),
    };
