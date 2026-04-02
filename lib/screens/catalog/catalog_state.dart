part of 'catalog.dart';


class _CatalogState extends State<Catalog> {
	Map<String, dynamic> _catalogResponse = {};

	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';
	String _currentSearchQuery = '';

	final TextEditingController _textController = TextEditingController();


	@override
	void initState() {
		super.initState();
		_currentSearchQuery = widget.searchQuery ?? '';

		_textController.text = _currentSearchQuery;
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



	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				centerTitle: true,
				title: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
					child: _buildSearchTextField(),
				),
				actions: [ // Добавить кнопку вызова slidingUpPanel с фильтрами
					IconButton(
						icon: const Icon(Icons.filter_alt),
						onPressed: () {},
						tooltip: 'Фильтры',
					),
					IconButton(
						icon: const Icon(Icons.settings),
						onPressed: () => Navigator.push(context,
							MaterialPageRoute(
								builder: (context) => SettingsScreen(),
							),
						),
						tooltip: 'Настройки',
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
				child: Container(
					margin: const EdgeInsets.all(50),
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
				),
			);
		}

		if (_catalogResponse['data'].isEmpty) {
			return Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon( Icons.info,
							size: 50,
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

	Widget _buildSearchTextField() {
		return TextField(
			controller: _textController,
			autofocus: false,
			decoration: InputDecoration(
				hintText: 'Каталог',
				prefixIcon: const Icon(Icons.search, color: Colors.grey),
				suffixIcon: ValueListenableBuilder<TextEditingValue>(
					valueListenable: _textController,
					builder: (context, value, _) {
						return value.text.isNotEmpty
							? IconButton(
								icon: const Icon(Icons.clear, color: Colors.grey),
								onPressed: () {
									_textController.clear();
									_currentSearchQuery = '';
								},
							)
							: const SizedBox.shrink();
					},
				),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: BorderSide(color: Colors.grey.shade300),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: BorderSide(
						color: Theme.of(context).colorScheme.primary,
						width: 2,
					),
				),
			),
			onChanged: (value) {
				setState(() {
					_currentSearchQuery = value;
				});
			},
			onSubmitted: (value) {
				if (widget.searchQuery != null) {
					setState(() {
						_currentSearchQuery = value;
						_catalogResponse = {};
					});
					_loadTitles();
				} else {
					Navigator.push(context,
						MaterialPageRoute(
							builder: (context) => Catalog(searchQuery: value),
						),
					);
				}
			},
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
