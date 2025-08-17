class AddProductParams {
  final String name;

  const AddProductParams({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
