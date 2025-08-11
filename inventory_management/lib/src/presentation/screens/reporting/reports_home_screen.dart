import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Material Usage by Product'),
            subtitle: const Text('See total material usage for a specific product.'),
            onTap: () => context.go('/reports/material-usage-by-product'),
          ),
          ListTile(
            title: const Text('Overall Material Usage'),
            subtitle: const Text('See total usage for each material across all products.'),
            onTap: () => context.go('/reports/overall-material-usage'),
          ),
        ],
      ),
    );
  }
}
