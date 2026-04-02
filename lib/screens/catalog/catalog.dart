import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:libria/main.dart';
import 'package:libria/screens/title/title.dart';
import 'package:libria/services/preferences.dart';
import 'package:libria/services/cache_manager.dart';
import 'package:libria/functions/play.dart';
import 'package:libria/screens/settings/settings.dart';

part 'catalog_state.dart';
part 'grid_item.dart';


class Catalog extends StatefulWidget {
	String? searchQuery;

	Catalog({
		super.key,
		this.searchQuery,
	});

	@override
	State<Catalog> createState() => _CatalogState();
}
