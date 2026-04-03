import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:libria/main.dart';
import 'package:libria/screens/title/title.dart';
import 'package:libria/services/preferences.dart';
import 'package:libria/services/cache_manager.dart';
import 'package:libria/services/anilibria_api.dart';
import 'package:libria/functions/play.dart';
import 'package:libria/screens/settings/settings.dart';

part 'catalog_state.dart';
part 'grid_item.dart';
part 'filters.dart';


class Catalog extends StatefulWidget {
	Map<String, dynamic>? searchParameters;

	Catalog({
		super.key,
		this.searchParameters,
	});

	@override
	State<Catalog> createState() => _CatalogState();
}
