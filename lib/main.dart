import 'dart:io';
import 'package:flutter/material.dart';
import 'package:libria/services/anilibria_api.dart';
import 'package:libria/screens/catalog/catalog.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';


void main() {
	runApp(const MyApp());
}

var base_url = 'https://anilibria.top';
var libria = Anilibria(base_url + '/api/v1');

const String DEFAULT_VIDEO_QUALITY = 'hls_720';




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


void play(String link) {
	if (Platform.isAndroid) {
		final intent = AndroidIntent(
			action: 'android.intent.action.VIEW',
			data: link,
			type: 'video/mp4',
		);
		intent.launch();
	} else {
		Process.run('mpv', [
			'--save-position-on-quit',
			link,
		]);
	}
}
