part of 'catalog.dart';


class _CatalogState extends State<Catalog> {
	Map<String, dynamic> _catalogResponse = {};

	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';
	String? _currentSearchQuery;


	@override
	void initState() {
		super.initState();
		_currentSearchQuery = widget.searchQuery;
		_loadTitles();
	}


	Future<void> _loadTitles() async {
		setState(() {
			_isLoading = true;
			_isError = false;
		});

		try {
			final resp = await libria.fetchCatalog(_currentSearchQuery);
			setState(() {
				_catalogResponse = resp;
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

	void _openSearchDialog() async {
		final q = await SearchDialog.show(context, query: _currentSearchQuery ?? '');
		if (q != null && q.isNotEmpty) {
			if (_currentSearchQuery == null) {
				Navigator.push(context,
					MaterialPageRoute(
						builder: (context) => Catalog(searchQuery: q),
					),
				);
			} else {
				setState(() {
					_currentSearchQuery = q;
					_catalogResponse = {};
				});
				_loadTitles();
			}
		}
	}



	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(
					(_currentSearchQuery == null) ? 'Каталог' : _currentSearchQuery!
				),
				actions: [
					IconButton(
						icon: const Icon(Icons.search),
						onPressed: _openSearchDialog,
						tooltip: 'Поиск',
					),
				],
			),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		if (_isLoading && _catalogResponse.isEmpty) {
			return const Center(
				child: CircularProgressIndicator(),
			);
		}

		if (_isError) {
			return Center(
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
							onPressed: _loadTitles,
							child: const Text('Попробовать снова'),	
						),
					],
				),
			);
		}

		if (_catalogResponse['data'].isEmpty) {
			return Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon( Icons.info,
							size: 60,
						),
						const SizedBox(height: 16),

						Text('Ничего не найдено',
							style: Theme.of(context).textTheme.titleLarge,
						),
						const SizedBox(height: 60),
					],
				),
			);
		}


		// Main
		ScrollController scrollController = ScrollController();
		return RefreshIndicator(
			onRefresh: _loadTitles,
			color: Theme.of(context).colorScheme.primary,
			child: Scrollbar(
				interactive: true,
				thickness: 6.0,
				radius: const Radius.circular(12),
				controller: scrollController,
				child: _buildGridView(scrollController),
			),
		);
	}

	Widget _buildGridView(ScrollController scrollController) {
		return GridView.builder(
			padding: const EdgeInsets.all(12),
			controller: scrollController,
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: _calculateCrossAxisCount(MediaQuery.of(context).size.width),
				crossAxisSpacing: 12,
				mainAxisSpacing: 12,
				childAspectRatio: 0.6,
			),
			itemCount: _catalogResponse['data'].length,
			itemBuilder: (context, index) {
				final name = _catalogResponse['data'][index]['name']['main'];
				final img_url = base_url + _catalogResponse['data'][index]['poster']['optimized']['preview'];

				return CatalogGridItem(
					titleCoverUrl: img_url,
					titleName: name,
					onTap: () {
						int currentTitleId = _catalogResponse['data'][index]['id'];
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
					}
				);
			}
		);
	}


	// Адаптивное количество колонок в зависимости от ширины экрана
	int _calculateCrossAxisCount(double screenWidth) {
		if (screenWidth > 1200) {
			return 6;  // Очень широкий экран
		} else if (screenWidth > 800) {
			return 4;  // Планшет
		} else if (screenWidth > 600) {
			return 3;  // Маленький планшет / большой телефон
		} else {
			return 2;  // Обычный телефон
		}
	}
}
