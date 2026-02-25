class DiscountModel {
  final String method;
  final double percent;

  DiscountModel({required this.method, required this.percent});

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      method: json['method'] as String,
      percent: (json['percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'method': method, 'percent': percent};
  }
}
