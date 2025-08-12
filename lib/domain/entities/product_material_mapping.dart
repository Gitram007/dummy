class ProductMaterialMapping {
  final int productId;
  final int materialId;
  final double quantity;
  final DateTime assignedAt;

  const ProductMaterialMapping({
    required this.productId,
    required this.materialId,
    required this.quantity,
    required this.assignedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductMaterialMapping &&
              runtimeType == other.runtimeType &&
              productId == other.productId &&
              materialId == other.materialId &&
              quantity == other.quantity &&
              assignedAt == other.assignedAt;

  @override
  int get hashCode =>
      productId.hashCode ^
      materialId.hashCode ^
      quantity.hashCode ^
      assignedAt.hashCode;
}
