import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management/domain/entities/add_product_params.dart';
import 'package:inventory_management/domain/entities/product.dart';
import 'package:inventory_management/presentation/providers/application_providers.dart';

class AddEditProductScreen extends ConsumerWidget {
  final int? productId;

  const AddEditProductScreen({super.key, this.productId});

  bool get isEditMode => productId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isEditMode) {
      final productAsync = ref.watch(productByIdProvider(productId!));
      return productAsync.when(
        data: (product) => _AddEditProductForm(product: product),
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
      return const _AddEditProductForm();
    }
  }
}

class _AddEditProductForm extends ConsumerStatefulWidget {
  final Product? product;

  const _AddEditProductForm({this.product});

  @override
  ConsumerState<_AddEditProductForm> createState() => _AddEditProductFormState();
}

class _AddEditProductFormState extends ConsumerState<_AddEditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(productRepositoryProvider);
      try {
        if (_isEditMode) {
          final updatedProduct = widget.product!.copyWith(
            name: _nameController.text,
          );
          await repository.updateProduct(updatedProduct);
        } else {
          final newProductParams = AddProductParams(
            name: _nameController.text,
          );
          await repository.addProduct(newProductParams);
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save product: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
