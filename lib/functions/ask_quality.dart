import 'dart:io';
import 'package:flutter/material.dart';

import 'package:libria/main.dart';
import 'package:libria/services/preferences.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';


Future<String?> askQuality(BuildContext context,
	{
		required String? hls_480,
		required String? hls_720,
		required String? hls_1080,
	}
) async {
	int? def_q = Preferences.getInt('default_video_quality');
	if (def_q != null) {
		if (def_q == 480) {
			if (hls_480 == null) def_q = null;
		} else if (def_q == 720) {
			if (hls_720 == null) def_q = null;
		} else if (def_q == 1080) {
			if (hls_1080 == null) def_q = null;
		}
	}

	int? q = def_q ?? await showQualityDialog(context,
		isAvailable480: hls_480 != null,
		isAvailable720: hls_720 != null,
		isAvailable1080: hls_1080 != null,
	);

	String? link = switch (q) {
		480 => hls_480,
		720 => hls_720,
		1080 => hls_1080,
		_ => null,
	};
	return link;
}


Future<int?> showQualityDialog(BuildContext context,
	{
		required bool isAvailable480,
		required bool isAvailable720,
		required bool isAvailable1080,
}) async {
	return showDialog<int?>(
		context: context,
		barrierDismissible: true,
		builder: (context) {
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
