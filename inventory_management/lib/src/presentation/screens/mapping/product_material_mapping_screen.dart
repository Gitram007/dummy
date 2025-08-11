import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management/src/domain/entities/product_material_mapping.dart';
import 'package:inventory_management/src/presentation/providers/application_providers.dart';
import 'package:inventory_management/src/domain/entities/material.dart' as domain;

class ProductMaterialMappingScreen extends ConsumerWidget {
  final int productId;
  const ProductMaterialMappingScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final mappingsAsync = ref.watch(productMaterialsStreamProvider(productId));
    final allMaterialsAsync = ref.watch(allMaterialsProvider);

    return Scaffold(
      appBar: AppBar(
        title: productAsync.when(
          data: (product) => Text("Mapping for ${product.name}"),
          loading: () => const Text('Loading...'),
          error: (e, s) => const Text('Error'),
        ),
      ),
      body: allMaterialsAsync.when(
        data: (allMaterials) {
          final materialMap = {for (var m in allMaterials) m.id: m};
          return mappingsAsync.when(
            data: (mappings) {
              if (mappings.isEmpty) {
                return const Center(
                    child: Text('No materials mapped yet.'));
              }
              return ListView.builder(
                itemCount: mappings.length,
                itemBuilder: (context, index) {
                  final mapping = mappings[index];
                  final material = materialMap[mapping.materialId];
                  return ListTile(
                    title: Text(material?.name ?? 'Unknown Material'),
                    subtitle: Text('Quantity: ${mapping.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditMappingDialog(context, ref,
                              productId: productId,
                              allMaterials: allMaterials,
                              existingMapping: mapping),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Mapping?'),
                                content: const Text(
                                    'Are you sure you want to delete this material mapping?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              ref
                                  .read(productMaterialRepositoryProvider)
                                  .removeMapping(
                                      productId, mapping.materialId);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Could not load materials: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final allMaterials = allMaterialsAsync.valueOrNull;
          if (allMaterials != null) {
            _showAddEditMappingDialog(context, ref,
                productId: productId, allMaterials: allMaterials);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditMappingDialog(
    BuildContext context,
    WidgetRef ref, {
    required int productId,
    required List<domain.Material> allMaterials,
    ProductMaterialMapping? existingMapping,
  }) {
    final formKey = GlobalKey<FormState>();
    domain.Material? selectedMaterial = existingMapping != null
        ? allMaterials.firstWhere((m) => m.id == existingMapping.materialId)
        : null;
    final quantityController =
        TextEditingController(text: existingMapping?.quantity.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingMapping != null ? 'Edit Mapping' : 'Add Material'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<domain.Material>(
                  value: selectedMaterial,
                  hint: const Text('Select Material'),
                  // If editing, disable the dropdown
                  onChanged: existingMapping != null
                      ? null
                      : (material) {
                          selectedMaterial = material;
                        },
                  items: allMaterials
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.name),
                          ))
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Please select a material' : null,
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final mapping = ProductMaterialMapping(
                    productId: productId,
                    materialId: selectedMaterial!.id,
                    quantity: double.parse(quantityController.text),
                    assignedAt: DateTime.now(), // This will be updated by the db anyway
                  );
                  ref
                      .read(productMaterialRepositoryProvider)
                      .addMapping(mapping);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
