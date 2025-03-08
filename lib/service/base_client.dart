import 'package:dio/dio.dart';

import '../utils/storage.dart';

class BaseClient {
  static Future<BaseOptions> getBasseOptions() async {
    BaseOptions options = BaseOptions(
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
      headers: {
        "Accept": "application/json",
        'Content-type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ${await storage.read('token')}',
      },
    );

    return options;
  }

  static Future<dynamic> get({required String url, var payload}) async {
    print(">>>>>>>.${storage.read('token')}");
    var dio = Dio(await getBasseOptions());

    var response = await dio.get(url, queryParameters: payload);
    print('\nURL: $url');
    print('Request Body: $response\n');
    return response;
  }

  static Future<dynamic> post({required String url, dynamic payload}) async {
    print(">>>>>>>.${storage.read('token')}");
    var dio = Dio(await getBasseOptions());
    var response = await dio.post(url, data: payload);
    print('\nURL: $url');
    print('Request Body: $response\n');
    return response;
  }

  static Future<dynamic> postWithQP({url, queryPayload}) async {
    var dio = Dio(await getBasseOptions());
    var response = await dio.post(url, queryParameters: queryPayload);
    return response;
  }

  static Future<dynamic> put({url, payload}) async {
    var dio = Dio(await getBasseOptions());
    var response = await dio.put(url, data: payload);
    return response;
  }

  static Future<dynamic> delete({url}) async {
    var dio = Dio(await getBasseOptions());
    var response = await dio.delete(url);
    return response;
  }
}
