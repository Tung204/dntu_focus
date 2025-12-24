import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FigmaService {
  late final Dio _dio;
  late final String _accessToken;
  late final String _fileId;
  late final String _baseUrl;

  FigmaService() {
    _accessToken = dotenv.env['FIGMA_ACCESS_TOKEN'] ?? '';
    _fileId = dotenv.env['FIGMA_FILE_ID'] ?? '';
    _baseUrl = dotenv.env['FIGMA_BASE_URL'] ?? 'https://api.figma.com/v1';

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'X-Figma-Token': _accessToken,
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// Lấy toàn bộ file data từ Figma
  Future<Map<String, dynamic>> getFile() async {
    try {
      final response = await _dio.get('/files/$_fileId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy specific nodes từ Figma file
  Future<Map<String, dynamic>> getNodes(List<String> nodeIds) async {
    try {
      final ids = nodeIds.join(',');
      final response = await _dio.get(
        '/files/$_fileId/nodes',
        queryParameters: {'ids': ids},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy file styles (colors, text, effects, grids)
  Future<Map<String, dynamic>> getStyles() async {
    try {
      final response = await _dio.get('/files/$_fileId/styles');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy components từ file
  Future<Map<String, dynamic>> getComponents() async {
    try {
      final response = await _dio.get('/files/$_fileId/components');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Export images từ Figma
  /// [nodeIds] - danh sách node IDs cần export
  /// [format] - định dạng: png, jpg, svg, pdf
  /// [scale] - scale factor: 1, 2, 3, 4
  Future<Map<String, String>> exportImages({
    required List<String> nodeIds,
    String format = 'png',
    int scale = 2,
  }) async {
    try {
      final ids = nodeIds.join(',');
      final response = await _dio.get(
        '/images/$_fileId',
        queryParameters: {
          'ids': ids,
          'format': format,
          'scale': scale,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      return Map<String, String>.from(data['images'] ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy file versions (history)
  Future<List<dynamic>> getVersions() async {
    try {
      final response = await _dio.get('/files/$_fileId/versions');
      final data = response.data as Map<String, dynamic>;
      return data['versions'] as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy comments từ file
  Future<List<dynamic>> getComments() async {
    try {
      final response = await _dio.get('/files/$_fileId/comments');
      final data = response.data as Map<String, dynamic>;
      return data['comments'] as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download image từ URL
  Future<List<int>> downloadImage(String imageUrl) async {
    try {
      final response = await Dio().get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Connection timeout. Vui lòng kiểm tra kết nối mạng.';
        break;
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 403:
            message = 'Access denied. Kiểm tra Figma access token hoặc file permissions.';
            break;
          case 404:
            message = 'File not found. Kiểm tra lại File ID.';
            break;
          case 429:
            message = 'Rate limit exceeded. Vui lòng thử lại sau.';
            break;
          default:
            message = 'Server error: ${error.response?.data}';
        }
        break;
      
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      
      default:
        message = 'Network error: ${error.message}';
    }
    return Exception(message);
  }

  /// Test connection với Figma API
  Future<bool> testConnection() async {
    try {
      await getFile();
      return true;
    } catch (e) {
      print('Figma connection test failed: $e');
      return false;
    }
  }

  /// Lấy file metadata (name, lastModified, thumbnailUrl, etc.)
  Future<Map<String, dynamic>> getFileMetadata() async {
    try {
      final data = await getFile();
      return {
        'name': data['name'],
        'lastModified': data['lastModified'],
        'thumbnailUrl': data['thumbnailUrl'],
        'version': data['version'],
        'role': data['role'],
        'editorType': data['editorType'],
      };
    } catch (e) {
      rethrow;
    }
  }
}