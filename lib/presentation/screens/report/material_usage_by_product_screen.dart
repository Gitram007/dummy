import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management/domain/entities/product.dart';
import 'package:inventory_management/presentation/providers/application_providers.dart';
import 'package:inventory_management/domain/entities/material.dart' as domain;
import 'package:printing/printing.dart';

enum TimeFrame { today, thisWeek, thisMonth, custom }

class MaterialUsageByProductScreen extends ConsumerStatefulWidget {
  const MaterialUsageByProductScreen({super.key});

  @override
  ConsumerState<MaterialUsageByProductScreen> createState() =>
      _MaterialUsageByProductScreenState();
}

class _MaterialUsageByProductScreenState
    extends ConsumerState<MaterialUsageByProductScreen> {
  Product? _selectedProduct;
  DateTimeRange? _selectedDateRange;
  TimeFrame _selectedTimeFrame = TimeFrame.custom;
  Map<domain.Material, double>? _reportData;
  bool _isLoading = false;

  void _setDateRange(TimeFrame timeFrame) {
    final now = DateTime.now();
    DateTime start;
    // Set end of day to include all of today's logs
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (timeFrame) {
      case TimeFrame.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case TimeFrame.thisWeek:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case TimeFrame.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case TimeFrame.custom:
        return;
    }
    setState(() {
      _selectedDateRange = DateTimeRange(start: start, end: end);
      _selectedTimeFrame = timeFrame;
    });
    _generateReport();
  }

  Future<void> _generateReport() async {
    if (_selectedProduct == null || _selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a product and a date range')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reportService = ref.read(reportServiceProvider);
      final data = await reportService.getMaterialUsageForProduct(
        productId: _selectedProduct!.id,
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
      );
      setState(() {
        _reportData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _exportReport(String format) async {
    if (_reportData == null || _reportData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No report data to export')),
      );
      return;
    }

    final exportService = ref.read(exportServiceProvider);
    final title = 'Material Usage for ${_selectedProduct!.name}';
    final headers = ['Material Name', 'Total Quantity Used', 'Unit'];
    final data = _reportData!.entries.map((entry) {
      return [
        entry.key.name,
        entry.value.toStringAsFixed(2),
        entry.key.unit,
      ];
    }).toList();

    final fullData = [headers, ...data];

    if (format == 'pdf') {
      final pdfData = await exportService.createPdf(fullData, title);
      await Printing.sharePdf(bytes: pdfData, filename: 'material_usage_report.pdf');
    } else if (format == 'csv') {
      final csvData = exportService.createCsv(fullData);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CSV Data'),
          content: SingleChildScrollView(child: Text(csvData)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Usage by Product'),
        actions: [
          if (_reportData != null && _reportData!.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: _exportReport,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'pdf',
                  child: Text('Export as PDF'),
                ),
                const PopupMenuItem<String>(
                  value: 'csv',
                  child: Text('Export as CSV'),
                ),
              ],
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters
            productsAsync.when(
              data: (products) => DropdownButtonFormField<Product>(
                value: _selectedProduct,
                hint: const Text('Select Product'),
                items: products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (p) => setState(() => _selectedProduct = p),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const Text('Could not load products'),
            ),
            const SizedBox(height: 16),

            // Quick Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final timeFrame in TimeFrame.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _selectedTimeFrame == timeFrame ? theme.primaryColor.withOpacity(0.1) : null,
                        ),
                        onPressed: () async {
                          if (timeFrame == TimeFrame.custom) {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: _selectedDateRange,
                            );
                            if (range != null) {
                              setState(() {
                                _selectedDateRange = range;
                                _selectedTimeFrame = TimeFrame.custom;
                              });
                            }
                          } else {
                            _setDateRange(timeFrame);
                          }
                        },
                        child: Text(timeFrame.name[0].toUpperCase() + timeFrame.name.substring(1)),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            if (_selectedDateRange != null)
              Text(
                'Range: ${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
                style: theme.textTheme.bodySmall,
              ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateReport,
              child: const Text('Generate Report'),
            ),
            const Divider(height: 32),

            // Report Display
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reportData == null
                  ? const Center(
                  child: Text('Generate a report to see data.'))
                  : _reportData!.isEmpty
                  ? const Center(
                  child: Text('No data for the selected criteria.'))
                  : ListView(
                children: _reportData!.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key.name),
                    trailing: Text(
                        'Used: ${entry.value.toStringAsFixed(2)}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
