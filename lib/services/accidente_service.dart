import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccidenteService {
  final Dio _dio = Dio();
  final String _baseUrl = dotenv.env['ACCIDENTES_URL']!;

  Future<List<Map<String, dynamic>>> obtenerJsonCrudo() async {
    try {
      final response = await _dio.get('$_baseUrl?\$limit=100000');
      final List data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      throw Exception('Error al cargar accidentes: ${e.message}');
    }
  }

  Future<int> obtenerTotal() async {
    final lista = await obtenerJsonCrudo();
    return lista.length;
  }
}
