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
double safe_area_padding = 0;




class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		safe_area_padding = MediaQuery.of(context).padding.bottom;

		final settings = context.watch<SettingsProvider>();
		final themeMode = (settings.isDarkTheme != null)
			? settings.isDarkTheme!
				? ThemeMode.dark
				: ThemeMode.light
			: ThemeMode.system;


		final lightTheme = ColorScheme.fromSeed(
			brightness: Brightness.light,
			seedColor: settings.colorAccent,
		);

		final darkTheme = ColorScheme.fromSeed(
			brightness: Brightness.dark,
			seedColor: settings.colorAccent,
		);

		final amoledTheme = darkTheme.copyWith(
			surface: Color(0xFF000000),
			surfaceContainer: Color(0xFF151515),
			surfaceContainerHighest: Color(0xFF333333),
		);


		return SafeArea(
			top: true,
			bottom: true,
			child: MaterialApp(
				title: 'Libria',
				theme: ThemeData(
					useMaterial3: true,
					appBarTheme: const AppBarTheme(
						scrolledUnderElevation: 0.0,
						backgroundColor: Colors.transparent,
					),
					colorScheme: lightTheme,
				),
				darkTheme: ThemeData(
					useMaterial3: true,
					appBarTheme: const AppBarTheme(
						scrolledUnderElevation: 0.0,
						backgroundColor: Colors.transparent,
					),
					colorScheme: settings.isAmoled
						? amoledTheme
						: darkTheme,
				),
				themeMode: themeMode,
				home: _buildHome(),
			),
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
