part of 'title.dart';


class EpisodesList extends StatefulWidget {
	final VoidCallback onTapDownload;

	final String titleName;
	final List<dynamic> episodes;
	final ScrollController? controller;
	LastTitleInfo currentTitle;
	final bool isWideScreen;

	EpisodesList({
		Key? key,
		required this.titleName,
		required this.onTapDownload,
		required this.episodes,
		required this.currentTitle,
		required this.isWideScreen,
		this.controller,
	}) : super(key: key);

	void loadCurrentTitle() {
		final t = Preferences.getLastTitle();
		if (t != null)
			currentTitle = t;
	}

	@override
	State<EpisodesList> createState() => _EpisodesListState();
}

class _EpisodesListState extends State<EpisodesList> {
	int? lastIndex;
	ScrollController scrollController = ScrollController();
	late SettingsProvider settings;

	@override
	void initState() {
		super.initState();
		lastIndex = widget.currentTitle.episodeIndex;
		if (widget.controller != null)
			scrollController = widget.controller!;
	}

	@override
	Widget build(BuildContext context) {
		settings = context.watch<SettingsProvider>();
		const double barHeight = 85.0;

		return Scaffold(
			backgroundColor: Colors.transparent,
			appBar: PreferredSize(
				preferredSize: Size.fromHeight(barHeight),
				child: _buildBar(barHeight),
			),

			body: Scrollbar(
				interactive: true,
				thickness: 8.0,
				radius: const Radius.circular(12),
				controller: scrollController,
				child: Container(
					padding: EdgeInsets.only(
						bottom: (!widget.isWideScreen)
							? safe_area_padding
							: 0,
						left: 15,
						right: 15,
					),
					child: _buildEpisodesList(),
				),
			),
		);
	}

	Widget _buildEpisodesList() {
		final bool isReverse = settings.reverseEpisodesSorting;

		return ListView.builder(
			controller: scrollController,
			itemCount: widget.episodes.length,
			itemBuilder: (context, index) {
				index = (isReverse)
					? _getReversedIndex(widget.episodes.length, index)
					: index;

				return EpisodeListItem(
					ordinal: widget.episodes[index]['ordinal'].toString(),
					name: widget.episodes[index]['name'],
					currentIndex: index,
					lastIndex: lastIndex,
					onTap: () => _playEpisode(index),
					onTapDownload: () async {
						String? link = await askQuality(context,
							hls_480: widget.episodes[index]['hls_480'],
							hls_720: widget.episodes[index]['hls_720'],
							hls_1080: widget.episodes[index]['hls_1080'],
						);
						if (link == null)
							return;

						SharePlus.instance.share(
							ShareParams(
								text: link,
								title: widget.titleName + ' - ' + 'Эпизод ' + widget.episodes[index]['ordinal'].toString(),
							)
						);
					},
				);
			}
		);
	}

	Widget _buildBar(double height) {
		return Container(
			height: height,
			decoration: BoxDecoration(
				color: Theme.of(context).colorScheme.surfaceVariant,
				borderRadius: .vertical(top: .circular(10)),
			),
			child: Row(
				children: [
					Container(
						margin: const EdgeInsets.symmetric(horizontal: 10),
						child: Text('Эпизоды',
							style: Theme.of(context).textTheme.headlineSmall,
						),
					),
					Expanded(
						child: _buildActions(),
					),
				],
			),
		);
	}

	Widget _buildActions() {
		return Row(
			mainAxisAlignment: MainAxisAlignment.end,
			children: [
				Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(20),
						color: Theme.of(context).colorScheme.primary,
					),
					margin: const EdgeInsets.symmetric(horizontal: 5),
					width: 50,
					child: IconButton(
						color: Theme.of(context).colorScheme.onPrimary,
						icon: Icon(Icons.download),
						tooltip: 'Торренты',
						onPressed: widget.onTapDownload,
					),
				),

				if (lastIndex != null && widget.episodes.length - 1 != lastIndex!)
					Container(
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(20),
							color: Theme.of(context).colorScheme.primary,
						),
						margin: const EdgeInsets.symmetric(horizontal: 5),
						width: 50,
						child: IconButton(
							color: Theme.of(context).colorScheme.onPrimary,
							icon: Icon(Icons.skip_next),
							tooltip: 'Следующая серия',
							onPressed: () => _playEpisode(lastIndex! + 1),
						),
					),

				Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(20),
						color: Theme.of(context).colorScheme.primary,
					),
					margin: const EdgeInsets.only(left: 5, right: 10),
					width: 80,
					child: IconButton(
						color: Theme.of(context).colorScheme.onPrimary,
						icon: Icon(Icons.play_arrow),
						tooltip: 'Играть',
						onPressed: () {
							if (lastIndex != null) {
								if (settings.useExternalPlayer) {
									playLink(widget.currentTitle.episodeLink!,
										titleName: widget.titleName,
										episodeName: widget.episodes[lastIndex!]['name'],
										episodeOrdinal: widget.episodes[lastIndex!]['ordinal'].toString(),
									);
								} else {
									Navigator.push(context,
										MaterialPageRoute(
											builder: (context) => PlayerScreen(
												title: widget.currentTitle,
												episodes: widget.episodes,
												index: lastIndex!,
												quality: settings.defaultVideoQuality,
											)
										),
									);
								}
							} else {
								_playEpisode(0);
							}
						},
					),
				),
			],
		);
	}

	void _playEpisode(int index) async {
		if (settings.useExternalPlayer) {
			await _playInExternalPlayer(index);
		} else {
			await Navigator.push(context,
				MaterialPageRoute(
					builder: (context) => PlayerScreen(
						title: widget.currentTitle,
						episodes: widget.episodes,
						index: index,
						quality: settings.defaultVideoQuality,
					),
				),
			);
			widget.loadCurrentTitle();
			setState(() => lastIndex = widget.currentTitle.episodeIndex);
		}
	}

	Future<void> _playInExternalPlayer(int index) async {
		bool isSucces = await play(context,
			hls_480: widget.episodes[index]['hls_480'],
			hls_720: widget.episodes[index]['hls_720'],
			hls_1080: widget.episodes[index]['hls_1080'],
			currentTitle: widget.currentTitle,
			episodeIndex: index,
			titleName: widget.titleName,
			episodeName: widget.episodes[index]['name'],
			episodeOrdinal: widget.episodes[index]['ordinal'].toString(),
		);

		if (isSucces)
			setState(() { lastIndex = index; });
	}


	int _getReversedIndex(int length, int index ) { return length - 1 - index; }
}
