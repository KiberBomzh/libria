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
			child: Card(
				color: Theme.of(context).colorScheme.surfaceContainer,
				elevation: 4,
				clipBehavior: Clip.antiAlias,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(12),
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Cover
						Expanded(
							flex: 16,
							child: Container(
								width: double.infinity,
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
							flex: 4,
							child: Container(
								padding: const EdgeInsets.all(8),
								child: Text( titleName,
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
								),
							),
						),
					],
				),
			),
		);
	}
}
