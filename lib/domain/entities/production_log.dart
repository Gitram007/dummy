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
}
