import 'package:flutter_cache_manager/flutter_cache_manager.dart';


final customCacheManager = CacheManager(
	Config(
		'AnimeCoversCache',
		stalePeriod: const Duration(days: 30),
		maxNrOfCacheObjects: 500,
		repo: JsonCacheInfoRepository(databaseName: 'AnimeCoversCache'),
		fileService: HttpFileService(),
	),
);
