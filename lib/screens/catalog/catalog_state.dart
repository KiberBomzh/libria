part of 'catalog.dart';


class _CatalogState extends State<Catalog> {
	Map<String, dynamic> _catalogResponse = {};

	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';
	Map<String, dynamic> _currentSearchParameters = {};

	final TextEditingController _textController = TextEditingController();
	final ScrollController _scrollController = ScrollController();


	bool _isLoadingNextPage = false;
	bool _isErrorLoadingNextPage = false;
	int _currentPage = 0;
	int _totalPages = 0;


	@override
	void initState() {
		super.initState();
		_currentSearchParameters = widget.searchParameters ?? {};

		_textController.text = _currentSearchParameters['query'] ?? '';
		_scrollController.addListener(_onScroll);
		_loadTitles();
	}

	@override
	void dispose() {
		_scrollController.removeListener(_onScroll);
		_scrollController.dispose();
		_textController.dispose();
		super.dispose();
	}

	void _onScroll() {
		if (_isLoading || _isLoadingNextPage || _currentPage >= _totalPages)
			return;

		if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200)
			_loadNextPage();
	}


	Future<void> _loadTitles() async {
		setState(() {
			_isLoading = true;
			_isError = false;
		});

		try {
			final resp = await libria.fetchCatalog(_currentSearchParameters);
			setState(() {
				_catalogResponse = resp;
				_isLoading = false;

				_currentPage = resp['meta']['pagination']['current_page'];
				_totalPages = resp['meta']['pagination']['total_pages'];
			});
		} catch(e) {
			setState(() {
				_isError = true;
				_errorMessage = e.toString();
				
				_isLoading = false;
			});
		}
	}

	Future<void> _loadNextPage() async {
		if (_currentPage >= _totalPages)
			return;

		setState(() {
			_isLoadingNextPage = true;
			_isErrorLoadingNextPage = false;
			_currentPage += 1;
		});

		try {
			_currentSearchParameters['page'] = _currentPage;
			final resp = await libria.fetchCatalog(_currentSearchParameters);
			setState(() {
				_catalogResponse['data'].addAll(resp['data']);
				_isLoadingNextPage = false;

				_currentPage = resp['meta']['pagination']['current_page'];
				_totalPages = resp['meta']['pagination']['total_pages'];
			});
		} catch(e) {
			setState(() {
				_isErrorLoadingNextPage = true;
				_errorMessage = e.toString();

				_isLoadingNextPage = false;
			});
		}
	}



	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				centerTitle: true,
				title: _buildSearchTextField(),
				actions: [
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
			floatingActionButton: _buildFAB(),
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
		return RefreshIndicator(
			onRefresh: _loadTitles,
			color: Theme.of(context).colorScheme.primary,
			child: Scrollbar(
				interactive: true,
				thickness: 6.0,
				radius: const Radius.circular(12),
				controller: _scrollController,
				child: _buildGridView()
			),
		);
	}

	Widget _buildGridView() {
		return GridView.builder(
			padding: const EdgeInsets.all(12),
			controller: _scrollController,
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: _calculateCrossAxisCount(MediaQuery.of(context).size.width),
				crossAxisSpacing: 12,
				mainAxisSpacing: 12,
				childAspectRatio: 0.6,
			),
			itemCount: _catalogResponse['data'].length + ((_currentPage < _totalPages) ? 1 : 0),
			itemBuilder: (context, index) {
				if (index == _catalogResponse['data'].length)
					return _buildNextPageLoader();

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

	Widget _buildNextPageLoader() {
		if (_isLoadingNextPage) {
			return const Center(
				child: CircularProgressIndicator(),
			);
		}

		if (_isErrorLoadingNextPage) {
			return Center(
				child: Container(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							const Icon( Icons.error_outline,
								size: 40,
								color: Colors.red,
							),
							const SizedBox(height: 16),
							Text( 'Ошибка загрузки: $_errorMessage', 
								textAlign: TextAlign.center,
							),
							const SizedBox(height: 16),
							ElevatedButton(
								onPressed: _loadNextPage,
								child: const Text('Попробовать снова'),	
							),
						],
					),
				),
			);
		}

		return SizedBox();
	}

	Widget _buildSearchTextField() {
		return TextField(
			controller: _textController,
			autofocus: false,
			decoration: InputDecoration(
				constraints: BoxConstraints(maxHeight: 40),
				contentPadding: const EdgeInsets.all(5),
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
									_currentSearchParameters['query'] = '';
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
					_currentSearchParameters['query'] = value;
				});
			},
			onSubmitted: (value) {
				setState(() {
					_currentSearchParameters = {};
				});

				if (widget.searchParameters != null) {
					setState(() {
						_currentSearchParameters['query'] = value;
						_catalogResponse = {};
					});
					_loadTitles();
				} else {
					_textController.clear();
					_currentSearchParameters['query'] = null;
					Navigator.push(context,
						MaterialPageRoute(
							builder: (context) => Catalog(searchParameters: {'query': value}),
						),
					);
				}
			},
		);
	}

	void _buildFilterBottomSheet() {
		showModalBottomSheet<void> (
			context: context,
			builder: (context) {
				final screenHeight = MediaQuery.of(context).size.height;

				return Container(
					height: double.infinity,
					width: double.infinity,
					padding: const EdgeInsets.all(10),
					decoration: BoxDecoration(
						color: Theme.of(context).colorScheme.surface,
						borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
					),
					child: Filters(
						parameters: _currentSearchParameters,
						onCancel: () => Navigator.pop(context),
						onDone: (params) {
							_textController.clear();
							Navigator.pop(context);

							if (widget.searchParameters != null) {
								setState(() {
									_currentSearchParameters = params;
									_catalogResponse = {};
								});
								_loadTitles();
							} else {
								Navigator.push(context,
									MaterialPageRoute(
										builder: (context) => Catalog(searchParameters: params),
									),
								);
							}
						},
					),
				);
			}
		);
	}

	Widget _buildFAB() {
		return Padding(
			padding: const EdgeInsets.only(right: 20, bottom: 20),
			child: FloatingActionButton(
				child: const Icon(Icons.filter_alt),
				onPressed: () => _buildFilterBottomSheet(),
				tooltip: 'Фильтры',
			),
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
