import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:libria/services/preferences.dart';
import 'package:libria/screens/settings/color_picker_dialog.dart';


class SettingsProvider extends ChangeNotifier {
	bool? _isDarkTheme;
	ColorItem _colorAccent = ColorItem('blue', Colors.blue);
	bool _reverseEpisodesSorting = false;
	int? _defaultVideoQuality;

	bool? get isDarkTheme => _isDarkTheme;
	Color get colorAccent => _colorAccent.color;
	bool get reverseEpisodesSorting => _reverseEpisodesSorting;
	int? get defaultVideoQuality => _defaultVideoQuality;

	SettingsProvider() {
		_loadAllSettings();
	}


	void _loadAllSettings() {
		_isDarkTheme = Preferences.getBool('is_dark_theme');
		_colorAccent = ColorItem.fromString(Preferences.getString('color_accent') ?? 'blue');
		_reverseEpisodesSorting = Preferences.getBool('reverse_episodes_sorting') ?? false;
		_defaultVideoQuality = Preferences.getInt('default_video_quality');

		notifyListeners();
	}

	Future<void> setDarkTheme(bool value) async {
		_isDarkTheme = value;
		await Preferences.setBool('is_dark_theme', value);

		notifyListeners();
	}

	Future<void> setColorAccent(ColorItem value) async {
		_colorAccent = value;
		await Preferences.setString('color_accent', value.name);

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

		_colorAccent = ColorItem('blue', Colors.blue);
		await Preferences.remove('color_accent');

		_reverseEpisodesSorting = false;
		await Preferences.remove('reverse_episodes_sorting');

		_defaultVideoQuality = null;
		await Preferences.remove('default_video_quality');


		notifyListeners();
	}
}
