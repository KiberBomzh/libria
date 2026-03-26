part of 'title.dart';


class EpisodesList extends StatelessWidget {
	final List<dynamic> episodes;
	final List<dynamic> torrents;
	final ScrollController? controller;

	const EpisodesList({
		Key? key,
		required this.episodes,
		required this.torrents,
		this.controller,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		ScrollController scrollController = (controller == null) ? ScrollController() : controller!;

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
				itemCount: episodes.length,
				itemBuilder: (context, index) {
					return EpisodeListItem(
						ordinal: episodes[index]['ordinal'].toString(),
						name: episodes[index]['name'],
						onTap: () => play(context,
							hls_480: episodes[index]['hls_480'],
							hls_720: episodes[index]['hls_720'],
							hls_1080: episodes[index]['hls_1080']
						),
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
				itemCount: torrents.length,
				itemBuilder: (context, index) {
					return TorrentListItem(
						label: torrents[index]['label'],
						onPressedCopyToClipboard: () => Clipboard.setData(ClipboardData(text: torrents[index]['magnet'])),
						onTap: () => launchUrl(Uri.parse(torrents[index]['magnet'])),
					);
				}
			),
		);
	}
}
