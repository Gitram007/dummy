class AddMaterialParams {
  final String name;
  final double quantity;
  final String unit;

  const AddMaterialParams({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
