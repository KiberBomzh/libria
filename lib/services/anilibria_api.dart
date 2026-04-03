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
	

	Future<Map<String, dynamic>> fetchCatalog(Map<String, dynamic> params) async {
		String? query = params['query'];
		String? sorting = switch (params['sorting']) {
			(Sorting.FreshDesc) => 'FRESH_AT_DESC',
			(Sorting.FreshAsc) => 'FRESH_AT_ASC',
			(Sorting.RatingDesc) => 'RATING_DESC',
			(Sorting.RatingAsc) => 'RATING_ASC',
			(Sorting.YearDesc) => 'YEAR_DESC',
			(Sorting.YearAsc) => 'YEAR_ASC',
			_ => null,
		};
		List<int>? genres = params['genres'];
		List<String>? types = params['types'];
		List<String>? seasons = params['seasons'];
		List<String>? age_ratings = params['age_ratings'];
		List<String>? publish_statuses = params['publish_statuses'];
		final response = await this._dio.get('/anime/catalog/releases',
			queryParameters: {
				'limit': 25,
				'f[search]': query,
				'f[sorting]': sorting,
				'f[genres]': genres,
				'f[types]': types,
				'f[seasons]': seasons,
				'f[age_ratings]': age_ratings,
				'f[publish_statuses]': publish_statuses,
			},
		);

		return response.data;
	}

	Future<Map<String, dynamic>> fetchTitle(int id) async {
		final response = await this._dio.get(
			'/anime/releases/$id'
		);

		return response.data;
	}

	Future<List<dynamic>> fetchAllGenres() async {
		final response = await this._dio.get('/anime/genres');
		return response.data;
	}
}


enum Sorting {
	FreshDesc,
	FreshAsc,
	RatingDesc,
	RatingAsc,
	YearDesc,
	YearAsc
}
