import 'package:ailand_pos/core/network/interceptors/logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
// import 'interceptors/logging_interceptor.dart';

/// API 客户端单例
class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;

  // 私有构造函数
  ApiClient._internal() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  // 获取单例实例
  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  // 获取 Dio 实例
  Dio get dio => _dio;

  // 基础配置
  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: 'https://dev-alland.zzss.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'AL-APP-ID': 'amCMI4Dgjc',
      'AL-CLIENT-TYPE': 'GMS',
    },
    validateStatus: (status) {
      // 接受所有状态码，在拦截器中统一处理
      return status != null && status < 500;
    },
  );

  // 设置拦截器
  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
  }

  // GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // PATCH 请求
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 下载文件
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// 统一的 API 响应模型
class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;
  final int? page;
  final int? pages;
  final int? pageSize;
  final int? total;
  final List<dynamic>? result;

  ApiResponse({
    required this.code,
    required this.msg,
    this.data,
    this.page,
    this.pages,
    this.pageSize,
    this.total,
    this.result,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? 0,
      msg: json['msg'] as String? ?? '',
      data: json['data'] as T?,
      page: json['page'] as int?,
      pages: json['pages'] as int?,
      pageSize: json['pageSize'] as int?,
      total: json['total'] as int?,
      result: json['result'] as List<dynamic>?,
    );
  }

  bool get isSuccess => code == 0;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data,
      'page': page,
      'pages': pages,
      'pageSize': pageSize,
      'total': total,
      'result': result,
    };
  }
}
