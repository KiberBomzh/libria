part of 'title.dart';


class TitleDetails extends StatelessWidget {
	final String? nameRu;
	final String? nameEn;
	final String coverImageUrl;
	final String? description;
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
					if (description != null)
						Container(
							margin: const EdgeInsets.only(top: 20),
							padding: const EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: Theme.of(context).colorScheme.surfaceContainer,
								border: Border.all(
									width: 1,
									color: Theme.of(context).colorScheme.secondary,
								),
								borderRadius: BorderRadius.circular(12),
							),
							child: ReadMoreText(description!,
								trimLines: 10,
								style: Theme.of(context).textTheme.bodyLarge,
								colorClickableText: Theme.of(context).colorScheme.primary,
								trimMode: TrimMode.Line,
								trimCollapsedText: 'Развернуть',
								trimExpandedText: ' Свернуть',
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

						child: AspectRatio(
							aspectRatio: 7 / 10,
							child: CachedNetworkImage(
								imageUrl: coverImageUrl,
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
						maxLines: 1,
						style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
					),
					const SizedBox(height: 1),
					Text(value,
						overflow: TextOverflow.ellipsis,
						maxLines: 2,
					),
				],
			),
		);
	}
}
