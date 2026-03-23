import 'package:flutter/material.dart';

import 'package:libria/main.dart';
import 'package:libria/screens/title/title.dart';

part 'catalog_state.dart';
part 'grid_item.dart';
part 'search_dialog.dart';


class Catalog extends StatefulWidget {
	String? searchQuery;

	Catalog({super.key, this.searchQuery});

	@override
	State<Catalog> createState() => _CatalogState();
}
