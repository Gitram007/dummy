class AddProductionLogParams {
  final int productId;
  final double quantityProduced;
  final DateTime productionDate;

  const AddProductionLogParams({
    required this.productId,
    required this.quantityProduced,
    required this.productionDate,
  });
}
