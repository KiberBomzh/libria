part of 'title.dart';


class TitleDetails extends StatelessWidget {
	final int titleId;
	final String? nameRu;
	final String? nameEn;
	final String coverImageUrl;
	final String? description;
	final String? type;
	final bool? isOngoing;
	final String? episodesTotal;
	final List<dynamic>? genres;

	TitleDetails({
		Key? key,
		required this.titleId,
		required this.nameRu,
		required this.nameEn,
		required this.coverImageUrl,
		required this.description,
		required this.type,
		required this.isOngoing,
		required this.episodesTotal,
		required this.genres,
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

					// Жанры
					_buildGenres(context),

					// Описание
					if (description != null)
						_buildDescription(context),

					// Связанное
					Franchise(
						titleId: titleId,
						isPreview: true,
					),
				],
			),
		);
	}

	Widget _buildGenres(BuildContext context) {
		if (genres == null)
			return Container();

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 15),
			child: Column(
				crossAxisAlignment: .start,
				children: [
					const SizedBox(height: 10),
					Text('Жанры',
						style: Theme.of(context).textTheme.titleLarge,
					),
					Divider(),
					Container(
						decoration: BoxDecoration(
							color: Theme.of(context).colorScheme.surfaceContainer,
							borderRadius: .circular(8),
						),
						width: double.infinity,
						padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
						child: Center(
							child: Wrap(
								spacing: 8,
								runSpacing: 10,
								children: genres!.map((v) {
									return FilterChip(
										label: Text(v['name']),
										onSelected: (_) => Navigator.push(context,
											MaterialPageRoute(
												builder: (context) => Catalog(searchParameters: { 'genres': <int>[ v['id'].toInt() ] })
											),
										),
									);
								}).toList(),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildDescription(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 15),
			child: Column(
				crossAxisAlignment: .start,
				children: [
					const SizedBox(height: 20),
					Text('Описание',
						style: Theme.of(context).textTheme.titleLarge,
					),
					Divider(),
					Container(
						padding: const EdgeInsets.all(12),
						decoration: BoxDecoration(
							color: Theme.of(context).colorScheme.surfaceContainer,
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
		String? ongoing;
		if (isOngoing != null)
			ongoing = (isOngoing!) ? 'Онгоинг' : 'Завершено';

		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Expanded(
					child: AspectRatio(
						aspectRatio: 7 / 10,
						child: Card(
							clipBehavior: Clip.antiAlias,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
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
								description: 'Статус',
								value: ongoing
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
