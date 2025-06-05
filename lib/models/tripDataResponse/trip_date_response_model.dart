import '../promotions/promotions_model.dart';

import '../tictet_type/tycket_type_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../trips/trips_model.dart';

part 'trip_date_response_model.freezed.dart';

part 'trip_date_response_model.g.dart';

@freezed
class TripDateResponse with _$TripDateResponse {
  @JsonSerializable(explicitToJson: true)
  const factory TripDateResponse({
    @Default([]) List<Promotion> promotions,
    @JsonKey(name: 'trips') @Default([]) List<Trip> trips,
    @Default([]) List<TicketType> tickettypes,
  }) = _TripDateResponse;


  factory TripDateResponse.fromJson(Map<String, dynamic> json) =>
      _$TripDateResponseFromJson(json);
}
