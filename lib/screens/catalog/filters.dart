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
	final Map<String, dynamic> _allGenres;
	Sorting _currentSorting = Sorting.FreshDesc;
	List<String> _genres = [];
	List<String> _types = [];
	List<String> _seasons = [];
	List<String> _ageRatings = [];
	List<String> _publishStatuses = [];

	@override
	void initState() {
		super.initState();
		_getLists();
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

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Expanded(
					child: ListView(
						children: [
							_buildSortTile(),


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
			runSpacing: 12,
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
}
