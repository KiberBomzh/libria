import 'package:flutter/material.dart';
import 'package:libria/main.dart';


class Catalog extends StatefulWidget {
	@override
	State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.primary,
				title: Text('Каталог'),
				centerTitle: true,
			),
			body: Center(child:Text("Какой-то текст"))
		);
	}
}

