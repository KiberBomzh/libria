part of 'catalog.dart';


class Filters extends StatefulWidget {
	final VoidCallback onCancel;
	final Function(Map<String, dynamic>) onDone;
	final Map<String, dynamic> parameters;

	Filters({
		super.key,
		required this.onCancel,
		required this.onDone,
		required this.parameters,
	});

	@override
	State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
	List<dynamic> _allGenres = [];
	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';

	Sorting _currentSorting = Sorting.FreshDesc;
	List<int> _genres = [];
	List<String> _types = [];
	List<String> _seasons = [];
	List<String> _ageRatings = [];
	List<String> _publishStatuses = [];

	@override
	void initState() {
		super.initState();
		_getLists();
		_loadAllGenres();
	}

	void _getLists() {
		setState(() {
			_currentSorting = widget.parameters['sorting'] ?? Sorting.FreshDesc;
			_genres = widget.parameters['genres'] ?? [];
			_types = widget.parameters['types'] ?? [];
			_seasons = widget.parameters['seasons'] ?? [];
			_ageRatings = widget.parameters['age_ratings'] ?? [];
			_publishStatuses = widget.parameters['publish_statuses'] ?? [];
		});
	}

	Future<void> _loadAllGenres() async {
		setState(() {
			_isLoading = true;
			_isError = false;
		});

		try {
			final resp = await libria.fetchAllGenres();
			setState(() {
				_allGenres = resp;
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
		return Column(
			children: [
				Expanded(
					child: ListView(
						children: [
							_buildSortTile(),

							
							_buildGenresTile(),

							_buildTileWithChips(
								title: 'Типы',
								options: ['ТВ', 'ONA', 'WEB', 'OVA', 'OAD', 'Фильм', 'Дорама', 'Спешл'],
								values: {
									'ТВ': 'TV', 
									'ONA': 'ONA',
									'WEB': 'WEB',
									'OVA': 'OVA',
									'OAD': 'OAD',
									'Фильм': 'MOVIE',
									'Дорама': 'DORAMA',
									'Спешл': 'SPECIAL'
								},
								selected: _types,
							),

							_buildTileWithChips(
								title: 'Сезоны',
								options: ['Зима', 'Весна', 'Лето', 'Осень'],
								values: {
									'Зима': 'winter',
									'Весна': 'spring',
									'Лето': 'summer',
									'Осень': 'autumn'
								},
								selected: _seasons,
							),

							_buildTileWithChips(
								title: 'Возрастные рейтинги',
								options: ['R0+', 'R6+', 'R12+', 'R16+', 'R18+'],
								values: {
									'R0+': 'R0_PLUS',
									'R6+': 'R6_PLUS',
									'R12+': 'R12_PLUS',
									'R16+': 'R16_PLUS',
									'R18+': 'R18_PLUS'
								},
								selected: _ageRatings,
							),

							_buildTileWithChips(
								title: 'Статусы',
								options: ['Онгоинг', 'Завершено'],
								values: {
									'Онгоинг': 'IS_ONGOING',
									'Завершено': 'IS_NOT_ONGOING'
								},
								selected: _publishStatuses,
							),
						]
					),
				),
				Divider(
					color: Theme.of(context).colorScheme.outline,
				),
				_buildBottomButtons(),
			],
		);
	}

	Widget _buildWithLoadingCheck({required Widget child}) {
		if (_isLoading && _allGenres.isEmpty)
			return const Center(
				child: CircularProgressIndicator()
			);

		if (_isError)
			return Center(
				child: Container(
					margin: const EdgeInsets.all(20),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							const Icon( Icons.error_outline,
								size: 60,
								color: Colors.red,
							),
							const SizedBox(height: 16),
							Text( 'Ошибка загрузки: $_errorMessage', 
								textAlign: TextAlign.center,
							),
							const SizedBox(height: 16),
							ElevatedButton(
								onPressed: _loadAllGenres,
								child: const Text('Попробовать снова'),	
							),
						],
					),
				),
			);


		return child;
	}

	Widget _buildTileWithChips({
		required String title,
		required List<String> options,
		required Map<String, String> values,
		required List<String> selected
	}) {
		return ExpansionTile(
			title: Text(title),
			children: [
				_buildFilterChips(
					options: options,
					values: values,
					selected: selected
				),
				SizedBox(height: 10),
			],
		);
	}

	Widget _buildBottomButtons() {
		return Row(
			children: [
				TextButton(
					child: Padding(
						padding: const EdgeInsets.all(15),
						child: Text('Отмена'),
					),
					onPressed: widget.onCancel,
				),

				Spacer(),

				TextButton(
					child: Padding(
						padding: const EdgeInsets.all(15),
						child: Text('Применить',
							style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
						),
					),
					style: TextButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
					onPressed: () => widget.onDone({
						'sorting': _currentSorting,
						'genres': _genres,
						'types': _types,
						'seasons': _seasons,
						'age_ratings': _ageRatings,
						'publish_statuses': _publishStatuses,
					}),
				),
			]
		);
	}

	Widget _buildItem({
		required Widget child,
		required VoidCallback onTap,
	}) {
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
				highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
				child: Padding(
					padding: const EdgeInsets.symmetric(
						horizontal: 10,
						vertical: 15,
					),
					child: child
				),
			),
		);
	}

	Widget _buildFilterChips({
		required List<String> options,
		required Map<String, String> values,
		required List<String> selected
	}) {
		return Wrap(
			spacing: 8,
			runSpacing: 10,
			children: options.map((option) {
				final bool isSelected = selected.contains(values[option]);

				return FilterChip(
					label: Text(option),
					backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
					selected: isSelected,
					onSelected: (bool value) {
						setState(() {
							if (value) {
								selected.add(values[option]!);
							} else {
								selected.remove(values[option]);
							}
						});
					},
				);
			}).toList(),
		);
	}


	Widget _buildSortTile() {
		return ExpansionTile(
			title: Text('Сортировка'),
			children: [
				_buildItem(
					child: _buildSortingItem(
						text: 'По дате обновления',
						isDownward: switch (_currentSorting) {
							Sorting.FreshDesc => true,
							Sorting.FreshAsc => false,
							_ => null
						},
					),
					onTap: () => setState(() {
						switch (_currentSorting) {
							case Sorting.FreshDesc:
								_currentSorting = Sorting.FreshAsc;
							case Sorting.FreshAsc:
								_currentSorting = Sorting.FreshDesc;
							default:
								_currentSorting = Sorting.FreshDesc;
						}
					}),
				),
				_buildItem(
					child: _buildSortingItem(
						text: 'По рейтингу',
						isDownward: switch (_currentSorting) {
							Sorting.RatingDesc => true,
							Sorting.RatingAsc => false,
							_ => null
						},
					),
					onTap: () => setState(() {
						switch (_currentSorting) {
							case Sorting.RatingDesc:
								_currentSorting = Sorting.RatingAsc;
							case Sorting.RatingAsc:
								_currentSorting = Sorting.RatingDesc;
							default:
								_currentSorting = Sorting.RatingDesc;
						}
					}),
				),
				_buildItem(
					child: _buildSortingItem(
						text: 'По годy',
						isDownward: switch (_currentSorting) {
							Sorting.YearDesc => true,
							Sorting.YearAsc => false,
							_ => null
						},
					),
					onTap: () => setState(() {
						switch (_currentSorting) {
							case Sorting.YearDesc:
								_currentSorting = Sorting.YearAsc;
							case Sorting.YearAsc:
								_currentSorting = Sorting.YearDesc;
							default:
								_currentSorting = Sorting.YearDesc;
						}
					}),
				),
			]
		);
	}

	Widget _buildSortingItem({
		required String text,
		bool? isDownward,
	}) {
		return Row(
			children: [
				Text(text),
				Spacer(),

				if (isDownward != null)
					Icon((isDownward!) ? Icons.arrow_downward : Icons.arrow_upward,
						color: Theme.of(context).colorScheme.primary,
						size: 20,
					),
			],
		);
	}


	Widget _buildGenresTile() {
		return ExpansionTile(
			title: Text('Жанры'),
			children: [
				_buildWithLoadingCheck(
					child: _buildGenres()
				),

				SizedBox(height: 10),
			],
		);
	}

	Widget _buildGenres() {
		return Wrap(
			spacing: 8,
			runSpacing: 10,
			children: _allGenres.map((genre) {
				final bool isSelected = _genres.contains(genre['id']);

				return FilterChip(
					label: Text(genre['name']),
					backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
					selected: isSelected,
					onSelected: (bool value) {
						setState(() {
							if (value) {
								_genres.add(genre['id']);
							} else {
								_genres.remove(genre['id']);
							}
						});
					},
				);
			}).toList(),
		);
	}
}
