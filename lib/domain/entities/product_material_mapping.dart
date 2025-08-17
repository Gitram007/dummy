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

  ProductMaterialMapping copyWith({
    int? productId,
    int? materialId,
    double? quantity,
    DateTime? assignedAt,
  }) {
    return ProductMaterialMapping(
      productId: productId ?? this.productId,
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }

  factory ProductMaterialMapping.fromJson(Map<String, dynamic> json) {
    return ProductMaterialMapping(
      productId: json['product'],
      materialId: json['material'],
      quantity: (json['quantity'] as num).toDouble(),
      assignedAt: DateTime.parse(json['assigned_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'material': materialId,
      'quantity': quantity,
    };
  }
}
