import 'package:flutter/material.dart';
import 'package:libria/services/anilibria_api.dart';
import 'package:libria/screens/catalog/catalog.dart';


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
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed(
					seedColor: Colors.blue,
					brightness: Brightness.dark,
				),
			),
			home: Catalog(),
		);
	}
}
