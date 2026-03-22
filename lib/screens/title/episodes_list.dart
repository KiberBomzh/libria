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
			padding: const EdgeInsets.all(8),
			itemCount: episodes.length,
			itemBuilder: (context, index) {
				return EpisodeListItem(
					ordinal: episodes[index]['ordinal'],
					name: episodes[index]['name'],
					onTap: () {
						if (Platform.isAndroid) {
							final intent = AndroidIntent(
								action: 'android.intent.action.VIEW',
								data: episodes[index]['hls_720'],
								type: 'video/mp4',
							);
							intent.launch();
						} else {
							Process.run('mpv', [
								'--save-position-on-quit',
								episodes[index]['hls_720'],
							]);
						}
					},
				);
			}
		);
	}
}
