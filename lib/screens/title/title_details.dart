part of 'title.dart';


class TitleDetails extends StatelessWidget {
	final String nameRu;
	final String nameEn;
	final String coverImageUrl;
	final String description;
	final String type;
	final String episodesTotal;

	TitleDetails({
		Key? key,
		required this.nameRu,
		required this.nameEn,
		required this.coverImageUrl,
		required this.description,
		required this.type,
		required this.episodesTotal,
	}) : super(key: key);


	@override
	Widget build(BuildContext context) {
		return Container(
			margin: EdgeInsets.symmetric(horizontal: 10),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Обложка тайтла и название
					_buildHead(context),

					// Описание
					Container(
						margin: const EdgeInsets.only(top: 20),
						padding: const EdgeInsets.all(8),
						decoration: BoxDecoration(
							color: Colors.grey[900],
							borderRadius: BorderRadius.circular(12),
						),
						child: Text(description,
							style: Theme.of(context).textTheme.bodyLarge,
						),
					),
				],
			),
		);
	}


	Widget _buildHead(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Expanded(
					flex: 4,
					child: Card(
						clipBehavior: Clip.antiAlias,
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(12),
						),

						child: Image.network( coverImageUrl,
							fit: BoxFit.cover,

							loadingBuilder: (context, child, loadingProgress) {
								if (loadingProgress == null) return child;

								return Center(
									child: CircularProgressIndicator(
										value: loadingProgress.expectedTotalBytes != null
											? loadingProgress.cumulativeBytesLoaded /
											  loadingProgress.expectedTotalBytes!

											: null
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
							},
						),
					),
				),
				SizedBox(width: 5),

				// Доп инфа
				Expanded(
					flex: 3,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Container(
								margin: const EdgeInsets.only(top: 5, bottom: 1),
								child: Text('Название на русском',
									overflow: TextOverflow.ellipsis,
									maxLines: 2,
									style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
								),
							),

							Container(
								margin: const EdgeInsets.only(bottom: 5),
								child: Text(nameRu,
									overflow: TextOverflow.ellipsis,
									maxLines: 2,
									style: TextStyle(
										fontWeight: FontWeight.bold,
									),
								),
							),


							Container(
								margin: const EdgeInsets.only(top: 5, bottom: 1),
								child: Text('Название на английском',
									overflow: TextOverflow.ellipsis,
									maxLines: 2,
									style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
								),
							),

							Container(
								margin: const EdgeInsets.only(bottom: 5),
								child: Text(nameEn,
									overflow: TextOverflow.ellipsis,
									maxLines: 2,
									style: TextStyle(
										color: Colors.grey[300],
									),
								),
							),


							Container(
								margin: const EdgeInsets.only(top: 5, bottom: 1),
								child: Text('Тип',
									overflow: TextOverflow.ellipsis,
									maxLines: 2,
									style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
								),
							),

							Container(
								margin: const EdgeInsets.only(bottom: 5),
								child: Text(type),
							),


							Container(
								margin: const EdgeInsets.only(top: 5, bottom: 1),
								child: Text('Эпизодов всего',
									overflow: TextOverflow.ellipsis,
									maxLines: 2,
									style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
								),
							),

							Container(
								margin: const EdgeInsets.only(bottom: 5),
								child: Text(episodesTotal),
							),
						],
					),
				),
			],
		);
	}
}
