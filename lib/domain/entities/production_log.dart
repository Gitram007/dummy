class ProductionLog {
  final int id;
  final int productId;
  final double quantityProduced;
  final DateTime productionDate;

  const ProductionLog({
    required this.id,
    required this.productId,
    required this.quantityProduced,
    required this.productionDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          quantityProduced == other.quantityProduced &&
          productionDate == other.productionDate;

  @override
  int get hashCode =>
      id.hashCode ^
      productId.hashCode ^
      quantityProduced.hashCode ^
      productionDate.hashCode;

  factory ProductionLog.fromJson(Map<String, dynamic> json) {
    return ProductionLog(
      id: json['id'],
      productId: json['product'],
      quantityProduced: (json['quantity_produced'] as num).toDouble(),
      productionDate: DateTime.parse(json['production_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity_produced': quantityProduced,
      'production_date': productionDate.toIso8601String(),
    };
  }
}
