import 'package:recipto/models/discount_model.dart';

class VoucherModel {
  final String id;
  final String title;
  final double minAmount;
  final double maxAmount;
  final bool disablePurchase;
  final List<DiscountModel> discounts;
  final List<String> redeemSteps;

  VoucherModel({
    required this.id,
    required this.title,
    required this.minAmount,
    required this.maxAmount,
    required this.disablePurchase,
    required this.discounts,
    required this.redeemSteps,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as String,
      title: json['title'] as String,
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      disablePurchase: json['disablePurchase'] as bool? ?? false,
      discounts:
          (json['discounts'] as List<dynamic>?)
              ?.map((e) => DiscountModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      redeemSteps:
          (json['redeemSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'disablePurchase': disablePurchase,
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'redeemSteps': redeemSteps,
    };
  }
}
