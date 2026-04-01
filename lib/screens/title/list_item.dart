part of 'title.dart';


class EpisodeListItem extends StatelessWidget {
	final VoidCallback onTap;
	final VoidCallback onTapDownload;

	final String ordinal;
	final String? name;
	final int currentIndex;
	final int? lastIndex;
	
	const EpisodeListItem({
		Key? key,
		required this.onTap,
		required this.onTapDownload,
		required this.ordinal,
		required this.currentIndex,
		this.lastIndex,
		this.name,
	}) : super(key: key);


	@override
	Widget build(BuildContext context) {
		BoxDecoration boxDecoration;
		TextStyle textStyle;
		if (lastIndex == null) {
			boxDecoration = _buildDefaultBoxDecoration(context);
			textStyle = _buildDefaultTextStyle(context);
		} else {
			if (currentIndex > lastIndex!) { // Все эпизоды ПОСЛЕ последнего просмотренного
				boxDecoration = _buildDefaultBoxDecoration(context);
				textStyle = _buildDefaultTextStyle(context);
			} else if (currentIndex < lastIndex!) { // Все эпизоды ДО последнего просмотренного
				boxDecoration = _buildInactiveBoxDecoration(context);
				textStyle = _buildInactiveTextStyle(context);
			} else { // Последний просмотренный
				boxDecoration = _buildActiveBoxDecoration(context);
				textStyle = _buildActiveTextStyle(context);
			}
		}

		return Container(
			decoration: boxDecoration,
			margin: const EdgeInsets.symmetric(vertical: 5),
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: onTap,
					splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
					highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
										color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
										border: Border.all(
											color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
											width: 2,
										),
										borderRadius: BorderRadius.circular(12),
									),
									child: Center(
										child: (lastIndex != null)
											? (currentIndex == lastIndex!)
												? Icon(Icons.play_arrow)
												: Text(ordinal, style: textStyle) 
											: Text(ordinal, style: textStyle),
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

	BoxDecoration _buildActiveBoxDecoration(BuildContext context) {
		return BoxDecoration(
			border: Border.all(
				width: 2,
				color: Theme.of(context).colorScheme.primary,
			),
			borderRadius: BorderRadius.circular(12),
		);
	}
	BoxDecoration _buildInactiveBoxDecoration(BuildContext context) {
		return BoxDecoration(
			border: Border.all(
				width: 2,
				color: Theme.of(context).colorScheme.outline,
			),
			borderRadius: BorderRadius.circular(12),
		);
	}
	BoxDecoration _buildDefaultBoxDecoration(BuildContext context) {
		return BoxDecoration(
			border: Border.all(
				width: 2,
				color: Theme.of(context).colorScheme.secondary,
			),
			borderRadius: BorderRadius.circular(12),
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
		Key? key,
		required this.onTap,
		required this.onLongTap,
		required this.label,
		required this.size, // в байтах
	}) : super(key: key);


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
					splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
					highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
