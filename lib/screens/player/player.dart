import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:provider/provider.dart';

import 'package:libria/services/preferences.dart';
import 'package:libria/services/settings_provider.dart';


part 'player_state.dart';


class PlayerScreen extends StatefulWidget {
	LastTitleInfo title;
	final List<dynamic> episodes;
	final int index;
	final int? quality;

	PlayerScreen({
		super.key,
		required this.title,
		required this.episodes,
		required this.index,
		this.quality,
	});


	@override
	State<PlayerScreen> createState() => _PlayerState();
}
