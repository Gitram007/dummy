class AddProductionLogParams {
  final int productId;
  final double quantityProduced;
  final DateTime productionDate;

  const AddProductionLogParams({
    required this.productId,
    required this.quantityProduced,
    required this.productionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity_produced': quantityProduced,
      'production_date': productionDate.toIso8601String(),
    };
  }
}
