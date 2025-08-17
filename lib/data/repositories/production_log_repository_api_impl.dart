import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../domain/entities/add_production_log_params.dart';
import '../../domain/entities/production_log.dart';
import '../../domain/repositories/production_log_repository.dart';

class ProductionLogRepositoryApiImpl implements IProductionLogRepository {
  final String _baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

  @override
  Future<void> addProductionLog(AddProductionLogParams params) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/productionlogs/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(params.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add production log');
    }
  }

  @override
  Future<List<ProductionLog>> getProductionLogs(DateTime start, DateTime end) async {
    final response = await http.get(Uri.parse('$_baseUrl/productionlogs/?start_date=${start.toIso8601String()}&end_date=${end.toIso8601String()}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ProductionLog.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load production logs');
    }
  }

  @override
  Future<List<ProductionLog>> getProductionLogsForProduct(int productId, DateTime start, DateTime end) async {
    final response = await http.get(Uri.parse('$_baseUrl/productionlogs/?product_id=$productId&start_date=${start.toIso8601String()}&end_date=${end.toIso8601String()}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ProductionLog.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load production logs');
    }
  }
}
