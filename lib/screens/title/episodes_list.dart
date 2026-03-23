part of 'title.dart';


class EpisodesList extends StatelessWidget {
	final List<dynamic> episodes;

	const EpisodesList({
		Key? key,
		required this.episodes,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return ListView.builder(
			padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
			itemCount: episodes.length,
			itemBuilder: (context, index) {
				return EpisodeListItem(
					ordinal: episodes[index]['ordinal'].toString(),
					name: episodes[index]['name'],
					onTap: () => play(episodes[index][DEFAULT_VIDEO_QUALITY]),
				);
			}
		);
	}
}
