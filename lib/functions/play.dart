import 'dart:io';
import 'package:flutter/material.dart';
import 'package:libria/main.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';


Future<void> play(BuildContext context, {
	required String? hls_480,
	required String? hls_720,
	required String? hls_1080
}) async {
	int? q = await _showQualityDialog(context,
		isAvailable480: hls_480 != null,
		isAvailable720: hls_720 != null,
		isAvailable1080: hls_1080 != null,
	);

	switch (q) {
		case (480): _playLink(hls_480!);
		case (720): _playLink(hls_720!);
		case (1080): _playLink(hls_1080!);
	}
}

void _playLink(String link) {
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


Future<int?> _showQualityDialog(BuildContext context,
	{
		required bool isAvailable480,
		required bool isAvailable720,
		required bool isAvailable1080,
}) async {
	return showDialog<int?>(
		context: context,
		barrierDismissible: true,
		builder: (context) {
			WidgetsBinding.instance.addPostFrameCallback((_) {
				if (MediaQuery.of(context).size.width > 800) {
					Navigator.of(context).pop();
				}
			});

			return SimpleDialog(
				title: const Text('Выберите качество'),
				children: [
					_qualityOption(context,
						value: 480,
						available: isAvailable480,
					),
					_qualityOption(context,
						value: 720,
						available: isAvailable720,
					),
					_qualityOption(context,
						value: 1080,
						available: isAvailable1080,
					),
				],
			);
		}
	);
}

Widget _qualityOption(BuildContext context,
	{
		required int value,
		required bool available
}) {
	return SimpleDialogOption(
		onPressed: available
			? () => Navigator.pop(context, value)
			: null,
		child: Row(
			children: [
				Expanded(
					child: Center( child: Text( value.toString() + 'p',
						style: Theme.of(context).textTheme.bodyLarge!.copyWith(
							color: available ? null : Colors.grey,
						),
					),
				)),
			],
		),
	);
}
