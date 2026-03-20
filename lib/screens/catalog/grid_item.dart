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
				color: Colors.grey[900],
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
								child: Image.network( titleCoverUrl,
									fit: BoxFit.cover,
									loadingBuilder: (context, child, loadingProgress) {
										if (loadingProgress == null) return child;

										return Center(
											child: CircularProgressIndicator(
												value: loadingProgress.expectedTotalBytes != null
													? loadingProgress.cumulativeBytesLoaded /
													  loadingProgress.expectedTotalBytes!
													: null,
											),
										);
									},
									errorBuilder: (context, error, stackTrace) {
										return Container(
											color: Colors.grey[300],
											child: Center(
												child: Icon( Icons.broken_image,
													size: 50,
													color: Colors.grey[600],
												),
											),
										);
									}
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
