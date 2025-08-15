import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/add_material_params.dart';
import '../../../domain/entities/material.dart' as domain;
import '../../providers/application_providers.dart';

class AddEditMaterialScreen extends ConsumerWidget {
  final int? materialId;

  const AddEditMaterialScreen({super.key, this.materialId});

  bool get isEditMode => materialId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isEditMode) {
      final materialAsync = ref.watch(materialByIdProvider(materialId!));
      return materialAsync.when(
        data: (material) => _AddEditMaterialForm(material: material),
        loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Error: $e')),
        ),
      );
    } else {
      return const _AddEditMaterialForm();
    }
  }
}

class _AddEditMaterialForm extends ConsumerStatefulWidget {
  final domain.Material? material;

  const _AddEditMaterialForm({this.material});

  @override
  ConsumerState<_AddEditMaterialForm> createState() =>
      _AddEditMaterialFormState();
}

class _AddEditMaterialFormState extends ConsumerState<_AddEditMaterialForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;

  bool get _isEditMode => widget.material != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _quantityController = TextEditingController(
        text: widget.material?.quantity.toString() ?? '0.0');
    _unitController = TextEditingController(text: widget.material?.unit ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveMaterial() async {
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(materialRepositoryProvider);
      try {
        if (_isEditMode) {
          final updatedMaterial = widget.material!.copyWith(
            name: _nameController.text,
            quantity: double.tryParse(_quantityController.text) ?? 0.0,
            unit: _unitController.text,
          );
          await repository.updateMaterial(updatedMaterial);
        } else {
          final newMaterialParams = AddMaterialParams(
            name: _nameController.text,
            quantity: double.tryParse(_quantityController.text) ?? 0.0,
            unit: _unitController.text,
          );
          await repository.addMaterial(newMaterialParams);
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save material: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Material' : 'Add Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Material Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a material name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMaterial,
                child: const Text('Save Material'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
