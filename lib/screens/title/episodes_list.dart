part of 'title.dart';


class EpisodesList extends StatelessWidget {
	final List<dynamic> episodes;
	final ScrollController? controller;

	const EpisodesList({
		Key? key,
		required this.episodes,
		this.controller,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		ScrollController scrollController = (controller == null) ? ScrollController() : controller!;

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
}
