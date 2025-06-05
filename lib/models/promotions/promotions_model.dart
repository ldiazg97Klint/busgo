import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotions_model.freezed.dart';
part 'promotions_model.g.dart';

@freezed
class Promotion with _$Promotion {
  factory Promotion({
    required int id,
    required String name,
    String? description,
    required int percentage,
    @Default(true) bool active,
  }) = _Promotion;

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);
}

extension PromotionMethods on Promotion {
  double applyDiscount(double price) {
    return price * (1 - (percentage / 100));
  }
}