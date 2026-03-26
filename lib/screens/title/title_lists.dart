part of 'title.dart';


class TitleLists extends StatefulWidget {
	final List<dynamic> episodes;
	final List<dynamic> torrents;
	final ScrollController? controller;
	LastTitleInfo currentTitle;

	TitleLists({
		Key? key,
		required this.episodes,
		required this.torrents,
		required this.currentTitle,
		this.controller,
	}) : super(key: key);

	@override
	State<TitleLists> createState() => _TitleListsState();
}

class _TitleListsState extends State<TitleLists> {
	int? lastIndex;

	@override
	void initState() {
		super.initState();
		lastIndex = widget.currentTitle.episodeIndex;
	}

	@override
	Widget build(BuildContext context) {
		ScrollController scrollController = widget.controller ?? ScrollController();

		// TODO
		// При прокрутке со списка торрентов не работает управлениe bottom sheet
		return DefaultTabController(
			length: 2,
			child: Column(
				children: [
					Material(
						clipBehavior: Clip.antiAlias,
						borderRadius: BorderRadius.circular(12),
						child: TabBar(
							tabs: [
								Tab(text: 'Эпизоды'),
								Tab(text: 'Торренты'),
							],
						),
					),
					Expanded(
						child: TabBarView(
							children: [
								_buildEpisodesList(scrollController),
								_buildTorrentsList(),
							],
						),
					),
				],
			),
		);
	}

	Widget _buildEpisodesList(ScrollController scrollController) {
		return Scrollbar(
			interactive: true,
			thickness: 10.0,
			radius: const Radius.circular(12),
			controller: scrollController,
			child: ListView.builder(
				controller: scrollController,
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
			),
		);
	}

	Widget _buildTorrentsList() {
		return Scrollbar(
			interactive: true,
			thickness: 10.0,
			radius: const Radius.circular(12),
			child: ListView.builder(
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
				itemCount: widget.torrents.length,
				itemBuilder: (context, index) {
					return TorrentListItem(
						label: widget.torrents[index]['label'],
						onPressedCopyToClipboard: () => Clipboard.setData(ClipboardData(text: widget.torrents[index]['magnet'])),
						onTap: () => launchUrl(Uri.parse(widget.torrents[index]['magnet'])),
					);
				}
			),
		);
	}
}
