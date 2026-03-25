import 'package:shared_preferences/shared_preferences.dart';


class Preferences {
	static SharedPreferences? _prefs;

	static Future<void> init() async {
		_prefs = await SharedPreferences.getInstance();
	}


	static Future<void> setString(String key, String value) async {
		await _prefs?.setString(key, value);
	}
	static String getString(String key, {String defaultValue = ''}) {
		return _prefs?.getString(key) ?? defaultValue;
	}

	static Future<void> setInt(String key, int value) async {
		await _prefs?.setInt(key, value);
	}
	static int getInt(String key, {int defaultValue = 0}) {
		return _prefs?.getInt(key) ?? defaultValue;
	}
}
