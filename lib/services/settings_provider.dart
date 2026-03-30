import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:libria/services/preferences.dart';


class SettingsProvider extends ChangeNotifier {
	bool? _isDarkTheme;
	bool _reverseEpisodesSorting = false;

	bool? get isDarkTheme => _isDarkTheme;
	bool get reverseEpisodesSorting => _reverseEpisodesSorting;

	SettingsProvider() {
		_loadAllSettings();
	}


	void _loadAllSettings() {
		_isDarkTheme = Preferences.getBool('is_dark_theme');
		_reverseEpisodesSorting = Preferences.getBool('reverse_episodes_sorting') ?? false;

		notifyListeners();
	}

	Future<void> setDarkTheme(bool value) async {
		_isDarkTheme = value;
		await Preferences.setBool('is_dark_theme', value);

		notifyListeners();
	}

	Future<void> setReverseEpisodesSorting(bool value) async {
		_reverseEpisodesSorting = value;
		await Preferences.setBool('reverse_episodes_sorting', value);

		notifyListeners();
	}
}
