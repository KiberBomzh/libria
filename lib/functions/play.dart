import 'dart:io';
import 'package:flutter/material.dart';

import 'package:libria/main.dart';
import 'package:libria/services/preferences.dart';
import 'package:libria/functions/ask_quality.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';


Future<bool> play(BuildContext context, {
	required String? hls_480,
	required String? hls_720,
	required String? hls_1080,
	required LastTitleInfo currentTitle,
	required int episodeIndex,
	required String titleName,
	required String? episodeName,
	required String episodeOrdinal,
}) async {
	final String? lastLink = currentTitle.episodeLink;
	currentTitle.episodeLink = await askQuality(context,
		hls_480: hls_480,
		hls_720: hls_720,
		hls_1080: hls_1080,
	);

	if (currentTitle.episodeLink == null) {
		currentTitle.episodeLink = lastLink;
		return false;
	}

	currentTitle.episodeIndex = episodeIndex;
	await Preferences.setLastTitle(currentTitle);
	playLink(currentTitle.episodeLink!,
		titleName: titleName,
		episodeName: episodeName,
		episodeOrdinal: episodeOrdinal,
	);
	return true;
}

void playLink(String link,
	{
		required String titleName,
		required String? episodeName,
		required String episodeOrdinal,
	}
) {
	final title = titleName + ' - ' + 'Эпизод ' + episodeOrdinal + '. ' + (episodeName ?? '');
	if (Platform.isAndroid) {
		final intent = AndroidIntent(
			action: 'android.intent.action.VIEW',
			data: link,
			type: 'video/mp4',
			arguments: {'title': title},
		);
		intent.launch();
	} else {
		Process.run('mpv', [
			'--title=$title',
			'--save-position-on-quit',
			link,
		]);
	}
}
