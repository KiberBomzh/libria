import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:libria/services/anilibria_api.dart';
import 'package:libria/services/preferences.dart';
import 'package:libria/services/settings_provider.dart';
import 'package:libria/screens/catalog/catalog.dart';
import 'package:libria/screens/title/title.dart';


void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Preferences.init();
	runApp(
		ChangeNotifierProvider(
			create: (_) => SettingsProvider(),
			child: const MyApp()
		),
	);
}

var base_url = 'https://anilibria.top';
var libria = Anilibria(base_url + '/api/v1');




class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		final settings = context.watch<SettingsProvider>();
		final ThemeMode? themeMode = settings.isDarkTheme!
			? ThemeMode.dark
			: ThemeMode.light;

		return MaterialApp(
			title: 'Libria',
			theme: ThemeData(
				useMaterial3: true,
				appBarTheme: const AppBarTheme(
					scrolledUnderElevation: 0.0,
					color: Colors.transparent,
				),
				colorScheme: ColorScheme.fromSeed(
					brightness: Brightness.light,
					seedColor: Colors.blue,
				),
			),
			darkTheme: ThemeData(
				useMaterial3: true,
				appBarTheme: const AppBarTheme(
					scrolledUnderElevation: 0.0,
					color: Colors.transparent,
				),
				colorScheme: ColorScheme.fromSeed(
					brightness: Brightness.dark,
					seedColor: Colors.blue,
				),
			),
			themeMode: themeMode ?? ThemeMode.system,
			home: _buildHome(),
		);
	}

	Widget _buildHome() {
		LastTitleInfo? title = Preferences.getLastTitle();
		if (title == null) {
			return Catalog();
		} else {
			return TitleScreen(currentTitle: title);
		}
	}
}
