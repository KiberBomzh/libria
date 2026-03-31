part of 'catalog.dart';


class CatalogGridItem extends StatelessWidget {
	final String titleCoverUrl;
	final String titleName;
	final VoidCallback onTap;

	const CatalogGridItem({
		Key? key,
		required this.titleCoverUrl,
		required this.titleName,
		required this.onTap
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: Container(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Cover
						AspectRatio(
							aspectRatio: 7 / 10,
							child: Card(
								clipBehavior: Clip.antiAlias,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
								child: CachedNetworkImage(
									imageUrl: titleCoverUrl,
									cacheManager: customCacheManager,
									fit: BoxFit.cover,
									placeholder: (context, url) => Container(
										color: Theme.of(context).colorScheme.surfaceVariant,
										child: const Center(child: CircularProgressIndicator()),
									),
									errorWidget: (context, url, error) => Container(
										color: Theme.of(context).colorScheme.surfaceVariant,
										child: const Icon(Icons.broken_image, size: 50),
									),
								),
							),
						),

						// Title
						Expanded(
							child: Container(
								padding: const EdgeInsets.symmetric(horizontal: 10),
								child: Text( titleName,
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
									style: TextStyle(
										color: Theme.of(context).colorScheme.onSurface,
									),
								),
							),
						),
					],
				),
			),
		);
	}
}
