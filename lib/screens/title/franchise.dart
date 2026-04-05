part of 'title.dart';


class Franchise extends StatefulWidget {
	final int titleId;
	final bool isPreview;

	Franchise({
		super.key,
		required this.titleId,
		required this.isPreview,
	});


	@override
	State<Franchise> createState() => _FranchiseState();
}

class _FranchiseState extends State<Franchise> {
	List<dynamic> _franchiseResponse = [];

	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';

	
	@override
	void initState() {
		super.initState();
		_loadFranchise();
	}

	Future<void> _loadFranchise() async {
		setState(() {
			_isLoading = true;
			_isError = false;
		});

		try {
			final resp = await libria.fetchFranchise(widget.titleId);

			setState(() {
				_franchiseResponse = resp;
				_isLoading = false;
			});
		} catch(e) {
			setState(() {
				_isError = true;
				_errorMessage = e.toString();

				_isLoading = false;
			});
		}
	}


	@override
	Widget build(BuildContext context) {
		return _buildWithLoadingCheck(
			(widget.isPreview) ? _buildPreview() : _buildMainScreen()
		);
	}

	Widget _buildWithLoadingCheck(Widget w) {
		if (_isLoading)
			return Padding(
				padding: EdgeInsets.only(top: (widget.isPreview) ? 20 : 0),
				child: const Center(
					child: CircularProgressIndicator(),
				),
			);

		if (_isError)
			return Center(
				child: Padding(
					padding: const EdgeInsets.all(20),
					child: Column(
						mainAxisAlignment: .center,
						children: [
							const Icon(Icons.error_outline,
								size: 60,
								color: Colors.red,
							),
							const SizedBox(height: 16),

							Text('Ошибка загрузки: $_errorMessage',
								textAlign: .center,
							),
							const SizedBox(height: 16),

							ElevatedButton(
								onPressed: _loadFranchise,
								child: const Text('Повторить'),
							),
						],
					),
				),
			);


		return w;
	}


	Widget _buildMainScreen() {
		return Scaffold(
			appBar: AppBar(
				title: Text('Связанное'),
			),
			body: Container(
				child: ListView.builder(
					itemCount: _franchiseResponse.length,
					itemBuilder: (context, index) {
						final releases =
							[..._franchiseResponse[index]['franchise_releases']]
								..sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

						return ExpansionTile(
							title: Container(
								child: Column(
									crossAxisAlignment: .start,
									children: [
										Text(_franchiseResponse[index]['name'],
											style: Theme.of(context).textTheme.titleMedium,
										),
										Text(_franchiseResponse[index]['name_english'],
											style: Theme.of(context).textTheme.bodyMedium?.copyWith( color: Colors.grey ),
										),
									]
								),
							),
							initiallyExpanded: (index == 0) ? true : false,
							children: releases.map<Widget>((v) {
								final release = v['release'];

								return _buildTitleItem(
									onTap: () {
										int currentTitleId = release['id'];
										LastTitleInfo? lastTitle = Preferences.getLastTitle();
										LastTitleInfo title;
										if (lastTitle == null) {
											title = LastTitleInfo(titleId: currentTitleId);
										} else {
											if (lastTitle!.titleId != currentTitleId) {
												title = LastTitleInfo(titleId: currentTitleId);
											} else {
												title = lastTitle!;
											}
										}

										Navigator.push(context,
											MaterialPageRoute(
												builder: (context) => TitleScreen(currentTitle: title),
											),
										);
									},
									imageUrl: base_url + release['poster']['optimized']['src'],
									titleName: release['name']['main'],
									titleNameEn: release['name']['english'],
									titleType: release['type']['description'],
									titleId: release['id'],
									isOngoing: release['is_ongoing'],
								);
							}).toList(),
						);
					}
				),
			),
		);
	}

	Widget _buildTitleItem({
		required VoidCallback onTap,
		required String imageUrl,
		required String titleName,
		required String? titleNameEn,
		required String? titleType,
		required int titleId,
		required bool? isOngoing,
	}) {
		return Container(
			height: 250,
			decoration: BoxDecoration(
				borderRadius: .circular(15),
				color: (titleId == widget.titleId)
					? Theme.of(context).colorScheme.surfaceVariant
					: Colors.transparent,
			),
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
							crossAxisAlignment: .start,
							children: [
								AspectRatio(
									aspectRatio: 7 / 10,
									child: Card(
										clipBehavior: .antiAlias,
										shape: RoundedRectangleBorder(
											borderRadius: .circular(12),
										),
										child: CachedNetworkImage(
											imageUrl: imageUrl,
											cacheManager: customCacheManager,
											fit: .cover,
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

								SizedBox(width: 10),

								Expanded(
									child: Column(
										crossAxisAlignment: .start,
										children: [
											const SizedBox(height: 10),
											Text(titleName,
												style: Theme.of(context).textTheme.titleMedium,
												overflow: TextOverflow.ellipsis,
												maxLines: 2,
											),


											if (titleNameEn != null) ...[
												const SizedBox(height: 20),
												Text('Название на английском',
													overflow: TextOverflow.ellipsis,
													maxLines: 1,
													style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
												),
												const SizedBox(height: 1),
												Text(titleNameEn,
													overflow: TextOverflow.ellipsis,
													maxLines: 2,
												),
											],


											if (titleType != null) ...[
												const SizedBox(height: 10),
												Text('Тип',
													overflow: TextOverflow.ellipsis,
													maxLines: 1,
													style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
												),
												const SizedBox(height: 1),
												Text(titleType,
													overflow: TextOverflow.ellipsis,
													maxLines: 2,
												),
											],


											if (isOngoing != null) ...[
												const SizedBox(height: 10),
												Text('Статус',
													overflow: TextOverflow.ellipsis,
													maxLines: 1,
													style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.grey ),
												),
												const SizedBox(height: 1),
												Text((isOngoing) ? 'Онгоинг' : 'Завершено',
													overflow: TextOverflow.ellipsis,
													maxLines: 2,
												),
											],
										],
									),
								),
							],
						),
					),
				),
			),
		);
	}


	
	Widget _buildPreview() {
		if (_franchiseResponse.isEmpty)
			return _buildWithPreviewHead(
				Container(
					decoration: BoxDecoration(
						color: Theme.of(context).colorScheme.surfaceContainer,
						borderRadius: .circular(12),
					),
					child: const Center(
						child: Text('Для этого тайтла ничего нет...'),
					),
				),
			);

		
		final firstFranchiseList =
			[..._franchiseResponse[0]['franchise_releases']]
				..sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

		return _buildWithPreviewHead(
			ListView.builder(
				scrollDirection: Axis.horizontal,
				itemCount: firstFranchiseList.length, // Только первая франшиза, остальные в полном просмотре
				itemBuilder: (context, index) {
					final release = firstFranchiseList[index]['release'];

					final double itemHeight = 250;
					return Container(
						height: itemHeight,
						width: itemHeight * 0.6,
						decoration: BoxDecoration(
							borderRadius: .circular(10),
							color: (release['id'] == widget.titleId)
								? Theme.of(context).colorScheme.surfaceVariant
								: Colors.transparent,
						),
						child: CatalogGridItem(
							titleCoverUrl: base_url + release['poster']['optimized']['src'],
							titleName: release['name']['main'],
							onTap: () {
								int currentTitleId = release['id'];
								LastTitleInfo? lastTitle = Preferences.getLastTitle();
								LastTitleInfo title;
								if (lastTitle == null) {
									title = LastTitleInfo(titleId: currentTitleId);
								} else {
									if (lastTitle!.titleId != currentTitleId) {
										title = LastTitleInfo(titleId: currentTitleId);
									} else {
										title = lastTitle!;
									}
								}

								Navigator.push(context,
									MaterialPageRoute(
										builder: (context) => TitleScreen(currentTitle: title),
									),
								);
							},
						),
					);
				},
			),
		);
	}

	Widget _buildWithPreviewHead(Widget w) {
		return Container(
			height: 320,
			margin: const EdgeInsets.only(top: 20),
			padding: const EdgeInsets.symmetric(horizontal: 15),
			child: Column(
				crossAxisAlignment: .start,
				children: [
					Row(
						children: [
							Text('Связанное',
								style: Theme.of(context).textTheme.titleLarge
							),
							Spacer(),
							if (_franchiseResponse.isNotEmpty)
								TextButton(
									child: Text('Показать все'),
									onPressed: () => Navigator.push(context,
										MaterialPageRoute(
											builder: (context) => Franchise(titleId: widget.titleId, isPreview: false),
										),
									),
								),
						],
					),
					Divider( color: Theme.of(context).colorScheme.outline ),
					Expanded( child: w ),
				],
			),
		);
	}
}
