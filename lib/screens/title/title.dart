import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:share_plus/share_plus.dart';

import 'package:libria/main.dart';
import 'package:libria/functions/play.dart';
import 'package:libria/functions/ask_quality.dart';
import 'package:libria/services/preferences.dart';
import 'package:libria/services/settings_provider.dart';
import 'package:libria/services/cache_manager.dart';
import 'package:libria/screens/catalog/catalog.dart';
import 'package:libria/screens/settings/settings.dart';

part 'title_state.dart';
part 'title_details.dart';
part 'title_lists.dart';
part 'list_item.dart';


class TitleScreen extends StatefulWidget {
	LastTitleInfo currentTitle;

	TitleScreen({
		Key? key,
		required this.currentTitle,
	}) : super(key: key);


	@override
	State<TitleScreen> createState() => _TitleState();
}
