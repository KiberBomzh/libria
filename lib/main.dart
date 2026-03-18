import 'package:flutter/material.dart';
import 'package:libria/services/anilibria_api.dart';
import 'package:libria/screens/catalog.dart';


void main() {
	runApp(const MyApp());
}

var base_url = 'https://anilibria.top';
var libria = Anilibria(base_url + '/api/v1');




class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Libria',
			theme: ThemeData(
				colorScheme: ColorScheme.dark(
					primary: Colors.blue,
					secondary: Colors.yellow,
				),
			),
			home: Catalog(),
		);
	}
}
