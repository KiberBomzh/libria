part of 'title.dart';


class EpisodesList extends StatefulWidget {
	final VoidCallback onTapDownload;

	final List<dynamic> episodes;
	final ScrollController? controller;
	LastTitleInfo currentTitle;
	final bool isWideScreen;

	EpisodesList({
		Key? key,
		required this.onTapDownload,
		required this.episodes,
		required this.currentTitle,
		required this.isWideScreen,
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
		const double barHeight = 80.0;

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
					padding: const EdgeInsets.symmetric(horizontal: 15),
					child: _buildEpisodesList(),
				),
			),
		);
	}

	Widget _buildEpisodesList() {
		return ListView.builder(
			reverse: Preferences.getBool('reverse_episodes_sorting') ?? false,
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

	Widget _buildBar(double height) {
		return Container(
			height: height,
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
								playLink(widget.currentTitle.episodeLink!);
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
		bool isSucces = await play(context,
			hls_480: widget.episodes[index]['hls_480'],
			hls_720: widget.episodes[index]['hls_720'],
			hls_1080: widget.episodes[index]['hls_1080'],
			currentTitle: widget.currentTitle,
			episodeIndex: index,
		);
		print(isSucces);
		if (isSucces)
			setState(() { lastIndex = index; });
	}
}
