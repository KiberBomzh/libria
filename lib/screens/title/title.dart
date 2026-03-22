import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import 'package:libria/main.dart';

part 'title_state.dart';
part 'title_details.dart';
part 'list_item.dart';
part 'episodes_list.dart';


class TitleEpisodes extends StatefulWidget {
	int titleId;

	TitleEpisodes({
		Key? key,
		required this.titleId,
	}) : super(key: key);


	@override
	State<TitleEpisodes> createState() => _TitleState();
}
