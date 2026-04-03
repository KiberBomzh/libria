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
	Sorting _currentSorting = Sorting.FreshDesc;

	@override
	void initState() {
		super.initState();
		_currentSorting = widget.parameters['sorting'] ?? Sorting.FreshDesc;
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Expanded(
					child: ListView(
						children: [
							_buildSortTile(),
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
}
