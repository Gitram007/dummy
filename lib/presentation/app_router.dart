import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './screens/mapping/product_material_mapping_screen.dart';
import './screens/mapping/product_selection_screen.dart';
import './screens/materials/add_edit_material_screen.dart';
import './screens/materials/material_list_screen.dart';
import './screens/products/add_edit_product_screen.dart';
import './screens/products/product_list_screen.dart';
import './screens/reporting/log_production_screen.dart';
import './screens/reporting/material_usage_by_product_screen.dart';
import './screens/reporting/overall_material_usage_screen.dart';
import './screens/reporting/reports_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/products'),
                  child: const Text('Manage Products'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/materials'),
                  child: const Text('Manage Materials'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/mappings'),
                  child: const Text('Map Materials to Products'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/log-production'),
                  child: const Text('Log Production'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/reports'),
                  child: const Text('View Reports'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
          path: '/products',
          builder: (context, state) => const ProductListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddEditProductScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return AddEditProductScreen(productId: id);
              },
            ),
          ]),
      GoRoute(
          path: '/materials',
          builder: (context, state) => const MaterialListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddEditMaterialScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return AddEditMaterialScreen(materialId: id);
              },
            ),
          ]),
      GoRoute(
          path: '/mappings',
          builder: (context, state) => const ProductSelectionScreen(),
          routes: [
            GoRoute(
              path: ':productId',
              builder: (context, state) {
                final productId = int.parse(state.pathParameters['productId']!);
                return ProductMaterialMappingScreen(productId: productId);
              },
            ),
          ]),
      GoRoute(
        path: '/log-production',
        builder: (context, state) => const LogProductionScreen(),
      ),
      GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsHomeScreen(),
          routes: [
            GoRoute(
              path: 'material-usage-by-product',
              builder: (context, state) => const MaterialUsageByProductScreen(),
            ),
            GoRoute(
              path: 'overall-material-usage',
              builder: (context, state) => const OverallMaterialUsageScreen(),
            ),
          ]
      ),
    ],
  );
});
