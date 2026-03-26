import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:libria/main.dart';
import 'package:libria/screens/title/title.dart';
import 'package:libria/services/preferences.dart';
import 'package:libria/services/cache_manager.dart';
import 'package:libria/functions/play.dart';

part 'catalog_state.dart';
part 'grid_item.dart';
part 'search_dialog.dart';


class Catalog extends StatefulWidget {
	String? searchQuery;

	Catalog({
		super.key,
		this.searchQuery,
	});

	@override
	State<Catalog> createState() => _CatalogState();
}
