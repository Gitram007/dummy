import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management/domain/entities/add_production_log_params.dart';
import 'package:inventory_management/domain/entities/product.dart';
import 'package:inventory_management/presentation/providers/application_providers.dart';

class LogProductionScreen extends ConsumerStatefulWidget {
  const LogProductionScreen({super.key});

  @override
  ConsumerState<LogProductionScreen> createState() => _LogProductionScreenState();
}

class _LogProductionScreenState extends ConsumerState<LogProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveLog() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product')),
        );
        return;
      }

      final params = AddProductionLogParams(
        productId: _selectedProduct!.id,
        quantityProduced: double.parse(_quantityController.text),
        productionDate: DateTime.now(),
      );

      try {
        await ref.read(productionLogRepositoryProvider).addProductionLog(params);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Production logged successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log production: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Production'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              productsAsync.when(
                data: (products) => DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  hint: const Text('Select Product'),
                  items: products.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (product) {
                    setState(() {
                      _selectedProduct = product;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a product' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Could not load products'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity Produced'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLog,
                child: const Text('Log Production'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
