import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:libria/services/preferences.dart';


class SettingsProvider extends ChangeNotifier {
	bool? _isDarkTheme;
	bool _reverseEpisodesSorting = false;
	int? _defaultVideoQuality;

	bool? get isDarkTheme => _isDarkTheme;
	bool get reverseEpisodesSorting => _reverseEpisodesSorting;
	int? get defaultVideoQuality => _defaultVideoQuality;

	SettingsProvider() {
		_loadAllSettings();
	}


	void _loadAllSettings() {
		_isDarkTheme = Preferences.getBool('is_dark_theme');
		_reverseEpisodesSorting = Preferences.getBool('reverse_episodes_sorting') ?? false;
		_defaultVideoQuality = Preferences.getInt('default_video_quality');

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

	Future<void> setDefaultVideoQuality(int value) async {
		_defaultVideoQuality = value;
		await Preferences.setInt('default_video_quality', value);

		notifyListeners();
	}


	Future<void> resetToDefault() async {
		_isDarkTheme = null;
		await Preferences.remove('is_dark_theme');

		_reverseEpisodesSorting = false;
		await Preferences.remove('reverse_episodes_sorting');

		_defaultVideoQuality = null;
		await Preferences.remove('default_video_quality');


		notifyListeners();
	}
}
