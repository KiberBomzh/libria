part of 'title.dart';


class TitleDetails extends StatelessWidget {
	final String? nameRu;
	final String? nameEn;
	final String coverImageUrl;
	final String description;
	final String? type;
	final String? episodesTotal;

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
							_buildHeadInfoContainer(context,
								description: 'Название на русском',
								value: nameRu
							),

							_buildHeadInfoContainer(context,
								description: 'Название на английском',
								value: nameEn
							),

							_buildHeadInfoContainer(context,
								description: 'Тип',
								value: type
							),

							_buildHeadInfoContainer(context,
								description: 'Эпизодов всего',
								value: episodesTotal
							),
						],
					),
				),
			],
		);
	}


	Widget _buildHeadInfoContainer(BuildContext context, {required String description, required String? value}) {
		if (value == null) {
			return Container(margin: const EdgeInsets.symmetric(vertical: 5));
		}

		return Container(
			margin: const EdgeInsets.symmetric(vertical: 5),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(description,
						overflow: TextOverflow.ellipsis,
						maxLines: 2,
						style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
					),
					const SizedBox(height: 1),
					Text(value),
				],
			),
		);
	}
}
