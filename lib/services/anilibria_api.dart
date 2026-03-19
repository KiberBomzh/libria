import 'package:dio/dio.dart';


class Anilibria {
	final Dio _dio;

	Anilibria(String url)
		: _dio = Dio(BaseOptions(
			baseUrl: url,
			connectTimeout: const Duration(seconds: 10),
			receiveTimeout: const Duration(seconds: 5),
			headers: {
				'Content-Type': 'application/json',
				'Accept': 'application/json',
			},
		));
	

	Future<Map<String, dynamic>> fetchCatalog() async {
		final response = await this._dio.get(
			'/anime/catalog/releases',
			queryParameters: { 'limit': 25 },
		);

		return response.data;
	}

	Future<Map<String, dynamic>> fetchTitle(int id) async {
		final response = await this._dio.get(
			'/anime/releases/$id'
		);

		return response.data;
	}
}
