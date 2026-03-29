part of 'title.dart';


class EpisodesList extends StatefulWidget {
	final List<dynamic> episodes;
	final ScrollController? controller;
	LastTitleInfo currentTitle;

	EpisodesList({
		Key? key,
		required this.episodes,
		required this.currentTitle,
		this.controller,
	}) : super(key: key);

	@override
	State<EpisodesList> createState() => _EpisodesListState();
}

class _EpisodesListState extends State<EpisodesList> {
	int? lastIndex;
	ScrollController scrollController = ScrollController();

	@override
	void initState() {
		super.initState();
		lastIndex = widget.currentTitle.episodeIndex;
		if (widget.controller != null)
			scrollController = widget.controller!;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
				automaticallyImplyLeading: false,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.vertical(
						top: Radius.circular(12),
					),
				),
				title: Text('Эпизоды'),
				actions: [
					Container(
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(20),
							color: Theme.of(context).colorScheme.primary,
						),
						margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
						padding: const EdgeInsets.symmetric(horizontal: 20),
						child: IconButton(
							color: Theme.of(context).colorScheme.onPrimary,
							icon: Icon(Icons.play_arrow),
							tooltip: 'Играть',
							onPressed: () {
								if (lastIndex != null) {
									playLink(widget.currentTitle.episodeLink!);
								} else {
									_playFirst();
								}
							},
						),
					),
				],
			),

			body: Scrollbar(
				interactive: true,
				thickness: 8.0,
				radius: const Radius.circular(12),
				controller: scrollController,
				child: Container(
					padding: const EdgeInsets.symmetric(horizontal: 15),
					child: _buildEpisodesList(),
				),
			),
		);
	}

	Widget _buildEpisodesList() {
		return ListView.builder(
			controller: scrollController,
			itemCount: widget.episodes.length,
			itemBuilder: (context, index) {
				return EpisodeListItem(
					ordinal: widget.episodes[index]['ordinal'].toString(),
					name: widget.episodes[index]['name'],
					currentIndex: index,
					lastIndex: lastIndex,
					onTap: () async {
						bool isSucces = await play(context,
							hls_480: widget.episodes[index]['hls_480'],
							hls_720: widget.episodes[index]['hls_720'],
							hls_1080: widget.episodes[index]['hls_1080'],
							currentTitle: widget.currentTitle,
							episodeIndex: index,
						);
						if (isSucces)
							setState(() { lastIndex = index; });
					},
				);
			}
		);
	}

	void _playFirst() async {
		bool isSucces = await play(context,
			hls_480: widget.episodes[0]['hls_480'],
			hls_720: widget.episodes[0]['hls_720'],
			hls_1080: widget.episodes[0]['hls_1080'],
			currentTitle: widget.currentTitle,
			episodeIndex: 0,
		);
		if (isSucces)
			setState(() { lastIndex = 0; });
	}
}


// class TorrentsList extends StatelessWidget {
// 	Widget _buildTorrentsList() {
// 		return ListView.builder(
// 			itemCount: widget.torrents.length,
// 			itemBuilder: (context, index) {
// 				return TorrentListItem(
// 					label: widget.torrents[index]['label'],
// 					onPressedCopyToClipboard: () => Clipboard.setData(ClipboardData(text: widget.torrents[index]['magnet'])),
// 					onTap: () => launchUrl(Uri.parse(widget.torrents[index]['magnet'])),
// 				);
// 			}
// 		);
// 	}
// 
// }
