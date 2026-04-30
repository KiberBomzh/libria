import 'package:shared_preferences/shared_preferences.dart';


class Preferences {
	static SharedPreferences? _prefs;

	static Future<void> init() async {
		_prefs = await SharedPreferences.getInstance();
	}


	static Future<void> setLastTitle(LastTitleInfo title) async {
		if (
			title.titleId == null ||
			title.episodeIndex == null ||
			title.episodeLink == null
		   ) { return; }

		await _prefs?.setInt('last_title_id', title.titleId!);
		await _prefs?.setInt('last_episode_index', title.episodeIndex!);
		await _prefs?.setString('last_video_link', title.episodeLink!);

		if (title.episodePosition != null)
			await _prefs?.setInt('last_episode_position', title.episodePosition!);
		else
			await _prefs?.remove('last_episode_position');
	}

	static LastTitleInfo? getLastTitle() {
		LastTitleInfo title = LastTitleInfo();
		title.titleId = _prefs?.getInt('last_title_id');
		title.episodeIndex = _prefs?.getInt('last_episode_index');
		title.episodeLink = _prefs?.getString('last_video_link');
		title.episodePosition = _prefs?.getInt('last_episode_position');
		if (
			title.titleId == null ||
			title.episodeLink == null ||
			title.episodeIndex == null
		   ) {
			return null;
		} else {
			return title;
		}
	}


	static Future<void> setString(String key, String value) async {
		await _prefs?.setString(key, value);
	}
	static String? getString(String key) {
		return _prefs?.getString(key);
	}

	static Future<void> setInt(String key, int value) async {
		await _prefs?.setInt(key, value);
	}
	static int? getInt(String key) {
		return _prefs?.getInt(key);
	}

	static Future<void> setBool(String key, bool value) async {
		await _prefs?.setBool(key, value);
	}
	static bool? getBool(String key) {
		return _prefs?.getBool(key);
	}

	static Future<void> remove(String key) async {
		await _prefs?.remove(key);
	}
}


class LastTitleInfo {
	int? titleId;
	String? episodeLink;
	int? episodeIndex;
	int? episodePosition; // in seconds

	LastTitleInfo({
		this.titleId,
		this.episodeIndex,
		this.episodeLink,
		this.episodePosition,
	});
}
