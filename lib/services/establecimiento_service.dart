import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/establecimiento.dart';

class EstablecimientoService {
  final Dio _dio = Dio();
  final String _base = dotenv.env['PARKING_URL']!;

  Future<List<Establecimiento>> obtenerTodos() async {
    try {
      final res = await _dio.get('$_base/establecimientos');
      final List data = res.data['data'] ?? res.data;
      return data.map((e) => Establecimiento.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception('Error al listar: ${e.message}');
    }
  }

  Future<Establecimiento> obtenerPorId(int id) async {
    try {
      final res = await _dio.get('$_base/establecimientos/$id');
      return Establecimiento.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener: ${e.message}');
    }
  }

  Future<void> crear(FormData formData) async {
    try {
      await _dio.post('$_base/establecimientos', data: formData);
    } on DioException catch (e) {
      throw Exception('Error al crear: ${e.message}');
    }
  }

  Future<void> editar(int id, FormData formData) async {
    try {
      formData.fields.add(const MapEntry('_method', 'PUT'));
      await _dio.post('$_base/establecimiento-update/$id', data: formData);
    } on DioException catch (e) {
      throw Exception('Error al editar: ${e.message}');
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('$_base/establecimientos/$id');
    } on DioException catch (e) {
      throw Exception('Error al eliminar: ${e.message}');
    }
  }
}
