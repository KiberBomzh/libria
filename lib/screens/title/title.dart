import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import 'package:libria/main.dart';
import 'package:libria/functions/play.dart';

part 'title_state.dart';
part 'title_details.dart';
part 'list_item.dart';
part 'episodes_list.dart';


class TitleScreen extends StatefulWidget {
	int titleId;

	TitleScreen({
		Key? key,
		required this.titleId,
	}) : super(key: key);


	@override
	State<TitleScreen> createState() => _TitleState();
}
