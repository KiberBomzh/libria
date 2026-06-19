part of 'title.dart';


class EpisodeListItem extends StatelessWidget {
	final VoidCallback onTap;
	final VoidCallback onTapDownload;

	final String ordinal;
	final String? name;
	final int currentIndex;
	final int? lastIndex;
	
	const EpisodeListItem({
		super.key,
		required this.onTap,
		required this.onTapDownload,
		required this.ordinal,
		required this.currentIndex,
		this.lastIndex,
		this.name,
	});


	@override
	Widget build(BuildContext context) {
		TextStyle textStyle;
		if (lastIndex == null) {
			textStyle = _buildDefaultTextStyle(context);
		} else {
			if (currentIndex > lastIndex!) { // Все эпизоды ПОСЛЕ последнего просмотренного
				textStyle = _buildDefaultTextStyle(context);
			} else if (currentIndex < lastIndex!) { // Все эпизоды ДО последнего просмотренного
				textStyle = _buildInactiveTextStyle(context);
			} else { // Последний просмотренный
				textStyle = _buildActiveTextStyle(context);
			}
		}

		return Container(
			decoration: BoxDecoration(
				color: Theme.of(context).colorScheme.surfaceContainerHighest,
				borderRadius: .circular(8),
			),
			margin: const EdgeInsets.symmetric(vertical: 5),
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: onTap,
					child: Padding(
						padding: EdgeInsets.symmetric(
							horizontal: 20,
							vertical: 10,
						),
						child: Row(
							children: [
								Container(
									width: 36,
									height: 36,
									decoration: BoxDecoration(
										color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
										border: Border.all(
											color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
											width: 2,
										),
										borderRadius: BorderRadius.circular(12),
									),
									child: Center(
										child: (lastIndex != null)
											? (currentIndex == lastIndex!)
												? Icon(Icons.play_arrow)
												: Text(ordinal, style: textStyle.copyWith(
													fontWeight: FontWeight.bold,
												)) 
											: Text(ordinal, style: textStyle.copyWith(
												fontWeight: FontWeight.bold,
											)),
									),
								),

								const SizedBox(width: 16),

								Expanded(
									child: Text(
										(name == null) ? '' : name.toString(),
										style: textStyle,
									),
								),

								SizedBox(width: 16),

								IconButton(
									icon: Icon(Icons.download),
									tooltip: 'Скачать',
									onPressed: onTapDownload,
								),
							],
						),
					),
				),
			),
		);
	}

	TextStyle _buildActiveTextStyle(BuildContext context) {
		return TextStyle(
			fontWeight: FontWeight.bold,
		);
	}
	TextStyle _buildInactiveTextStyle(BuildContext context) {
		return TextStyle(
			color: Colors.grey,
		);
	}
	TextStyle _buildDefaultTextStyle(BuildContext context) {
		return TextStyle();
	}
}



class TorrentListItem extends StatelessWidget {
	final VoidCallback onTap;
	final VoidCallback onLongTap;
	final String label;
	final int size;
	
	const TorrentListItem({
		super.key,
		required this.onTap,
		required this.onLongTap,
		required this.label,
		required this.size, // в байтах
	});


	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				border: Border.all(
					width: 2,
					color: Theme.of(context).colorScheme.outline,
				),
				borderRadius: BorderRadius.circular(12),
			),
			margin: const EdgeInsets.symmetric(vertical: 5),
			height: 80,
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: onTap,
					onLongPressUp: onLongTap,
					child: Container(
						padding: const EdgeInsets.all(10),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(label,
									overflow: TextOverflow.ellipsis,
									maxLines: 2,
									style: Theme.of(context).textTheme.bodyMedium,
								),
								Expanded(child: Container()),
								Row(
									children: [
										Expanded(child: Container()),
										Text('Размер: ' + (((size / (1024 * 1024 * 1024)) * 10).round() / 10).toString() + ' GiB',
											textAlign: TextAlign.right,
											style: Theme.of(context).textTheme.bodySmall,
										),
									],
								)
							],
						),
					),
				),
			),
		);
	}
}
