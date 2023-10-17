import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide FormData;
import 'package:pro_z/src/store/store_index.dart';
import 'package:pro_z/src/utils/proz_dio_logger.dart';

import 'loading.dart';

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();

  factory HttpUtil() => _instance;

  late Dio dio;
  CancelToken cancelToken = CancelToken();

  HttpUtil._internal() {
    /// BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions(
      /// 请求基地址,可以包含子路径
      baseUrl: HttpSetting.to.baseUrl,

      // baseUrl: storage.read(key: STORAGE_KEY_APIURL) ?? SERVICE_API_BASEURL,
      ///连接服务器超时时间，单位是毫秒.
      connectTimeout: const Duration(milliseconds: 100000),

      /// 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(milliseconds: 100000),

      /// Http请求头.
      headers: {},

      /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
      /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
      /// 可以设置此选项为 `Headers.formUrlEncodedContentType`,  这样[Dio]
      /// 就会自动编码请求体.
      contentType: 'application/json; charset=utf-8',

      /// [responseType] 表示期望以那种格式(方式)接受响应数据。
      /// 目前 [ResponseType] 接受三种类型 `JSON`, `STREAM`, `PLAIN`.
      ///
      /// 默认值是 `JSON`, 当响应头中content-type为"application/json"时，dio 会自动将响应内容转化为json对象。
      /// 如果想以二进制方式接受响应数据，如下载一个二进制文件，那么可以使用 `STREAM`.
      ///
      /// 如果想以文本(字符串)格式接收响应数据，请使用 `PLAIN`.
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Cookie管理
    CookieJar cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Do something before request is sent
        return handler.next(options); //continue
        // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      },
      onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
        // 如果你想终止请求并触发一个错误,你可以 reject 一个`DioError`对象,如`handler.reject(error)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      },
      onError: (DioError e, handler) {
        // Do something with response error
        Loading.dismiss();
        ErrorEntity eInfo = createErrorEntity(e);
        onError(eInfo);
        return handler.next(e); //continue
        // 如果你想完成请求并返回一些自定义数据，可以resolve 一个`Response`,如`handler.resolve(response)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
      },
    ));
    dio.interceptors.add(ProZDioLogger(responseBody: false, maxWidth: 100));
  }

  /*
   * error统一处理
   */

  // 错误处理
  void onError(ErrorEntity eInfo) {
    debugPrint("error.code -> ${eInfo.code}, error.message -> ${eInfo.message}");
    switch (eInfo.code) {
      case 401:
        // UserStore.to.onLogout();
        EasyLoading.showError(eInfo.message);
        break;
      default:
        EasyLoading.showError('Unknown Error');
        break;
    }
  }

  // 错误信息
  ErrorEntity createErrorEntity(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        return ErrorEntity(code: -1, message: "Request to cancel");
      case DioErrorType.connectionTimeout:
        return ErrorEntity(code: -1, message: "Connection timed out");
      case DioErrorType.sendTimeout:
        return ErrorEntity(code: -1, message: "Request timed out");
      case DioErrorType.receiveTimeout:
        return ErrorEntity(code: -1, message: "Response timeout");
      case DioErrorType.badResponse:
        {
          try {
            int errCode = error.response != null ? error.response!.statusCode! : -1;
            // String errMsg = error.response.statusMessage;
            // return ErrorEntity(code: errCode, message: errMsg);
            switch (errCode) {
              case 400:
                return ErrorEntity(code: errCode, message: "Request syntax error");
              case 401:
                return ErrorEntity(code: errCode, message: "Permission denied");
              case 403:
                return ErrorEntity(code: errCode, message: "The server refuses to execute");
              case 404:
                return ErrorEntity(code: errCode, message: "Can not reach server");
              case 405:
                return ErrorEntity(code: errCode, message: "Request method is forbidden");
              case 500:
                return ErrorEntity(code: errCode, message: "Internal server error");
              case 502:
                return ErrorEntity(code: errCode, message: "Invalid request");
              case 503:
                return ErrorEntity(code: errCode, message: "Server down");
              case 505:
                return ErrorEntity(code: errCode, message: "Does not support HTTP protocol requests");
              default:
                {
                  // return ErrorEntity(code: errCode, message: "未知错误");
                  return ErrorEntity(
                    code: errCode,
                    message: error.response != null ? error.response!.statusMessage! : "",
                  );
                }
            }
          } on Exception catch (_) {
            return ErrorEntity(code: -1, message: "Unknown mistake");
          }
        }
      default:
        {
          return ErrorEntity(code: -1, message: error.message ?? '');
        }
    }
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }

  /// 读取本地配置
  Map<String, dynamic>? getAuthorizationHeader() {
    var headers = <String, dynamic>{};
    if (Get.isRegistered<HttpSetting>() && HttpSetting.to.token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${HttpSetting.to.token}';
    }
    return headers;
  }

  /// restful get 操作
  /// refresh 是否下拉刷新 默认 false
  /// noCache 是否不缓存 默认 true
  /// list 是否列表 默认 false
  /// cacheKey 缓存key
  /// cacheDisk 是否磁盘缓存
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool refresh = false,
    bool noCache = true,
    bool list = false,
    String cacheKey = '',
    bool cacheDisk = false,
    bool isRaw = false,
    bool isShowLoading = false,
    bool isShowResultDialog = false,
    String? message,
  }) async {
    dio.options.baseUrl = isRaw ? path : HttpSetting.to.baseUrl;
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra!.addAll({
      "refresh": refresh,
      "noCache": noCache,
      "list": list,
      "cacheKey": cacheKey,
      "cacheDisk": cacheDisk,
    });
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    if (isShowLoading) Loading.show('Loading...');
    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    if (isShowLoading) Loading.dismiss();
    if (isShowResultDialog) {
      Loading.success(message ?? response.data['message']);
    }
    dio.options.baseUrl = HttpSetting.to.baseUrl;
    return response.data;
  }

  /// restful post 操作
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRaw = false,
    bool isShowLoading = false,
    bool isShowResultDialog = false,
    String? message,
  }) async {
    dio.options.baseUrl = isRaw ? path : HttpSetting.to.baseUrl;
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    if (isShowLoading) Loading.show('Loading...');
    var response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (isShowLoading) Loading.dismiss();
    if (isShowResultDialog) {
      Loading.success(message ?? response.data['message']);
    }
    dio.options.baseUrl = HttpSetting.to.baseUrl;
    return response.data;
  }

  /// restful put 操作
  Future put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRaw = false,
    bool isShowLoading = false,
    bool isShowResultDialog = false,
    String? message,
  }) async {
    dio.options.baseUrl = isRaw ? path : HttpSetting.to.baseUrl;
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    if (isShowLoading) Loading.show('Loading...');
    var response = await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (isShowLoading) Loading.dismiss();
    if (isShowResultDialog) {
      Loading.success(message ?? response.data['message']);
    }
    dio.options.baseUrl = HttpSetting.to.baseUrl;
    return response.data;
  }

  /// restful patch 操作
  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRaw = false,
    bool isShowLoading = false,
    bool isShowResultDialog = false,
    String? message,
  }) async {
    dio.options.baseUrl = isRaw ? path : HttpSetting.to.baseUrl;
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    if (isShowLoading) Loading.show('Loading...');
    var response = await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (isShowLoading) Loading.dismiss();
    if (isShowResultDialog) {
      Loading.success(message ?? response.data['message']);
    }
    dio.options.baseUrl = HttpSetting.to.baseUrl;
    return response.data;
  }

  /// restful delete 操作
  Future delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRaw = false,
    bool isShowLoading = false,
    bool isShowResultDialog = false,
    String? message,
  }) async {
    dio.options.baseUrl = isRaw ? path : HttpSetting.to.baseUrl;
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    if (isShowLoading) Loading.show('Loading...');
    var response = await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (isShowLoading) Loading.dismiss();
    if (isShowResultDialog) {
      Loading.success(message ?? response.data['message']);
    }
    dio.options.baseUrl = HttpSetting.to.baseUrl;
    return response.data;
  }

  /// restful post form 表单提交操作
  Future postForm(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRaw = false,
    bool isShowLoading = false,
    bool isShowResultDialog = false,
    String? message,
  }) async {
    dio.options.baseUrl = isRaw ? path : HttpSetting.to.baseUrl;
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    if (isShowLoading) Loading.show('Loading...');
    var response = await dio.post(
      path,
      data: FormData.fromMap(data),
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (isShowLoading) Loading.dismiss();
    if (isShowResultDialog) {
      Loading.success(message ?? response.data['message']);
    }
    dio.options.baseUrl = HttpSetting.to.baseUrl;
    return response.data;
  }

  /// restful post Stream 流数据
  Future postStream(
    String path, {
    dynamic data,
    int dataLength = 0,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRaw = false,
    bool isShowLoading = false,
    bool isShowResultDialog = false,
    String? message,
  }) async {
    dio.options.baseUrl = isRaw ? path : HttpSetting.to.baseUrl;
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    requestOptions.headers!.addAll({
      Headers.contentLengthHeader: dataLength.toString(),
    });
    if (isShowLoading) Loading.show('Loading...');
    var response = await dio.post(
      path,
      data: Stream.fromIterable(data.map((e) => [e])),
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (isShowLoading) Loading.dismiss();
    if (isShowResultDialog) {
      Loading.success(message ?? response.data['message']);
    }
    dio.options.baseUrl = HttpSetting.to.baseUrl;
    return response.data;
  }
}

// 异常处理
class ErrorEntity implements Exception {
  int code = -1;
  String message = "";

  ErrorEntity({required this.code, required this.message});

  @override
  String toString() {
    if (message == "") return "Exception";
    return "Exception: code $code, $message";
  }
}
