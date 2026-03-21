part of 'catalog.dart';


class _CatalogState extends State<Catalog> {
	Map<String, dynamic> _catalogResponse = {};

	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';


	@override
	void initState() {
		super.initState();
		_loadTitles();
	}


	Future<void> _loadTitles({String? query = null}) async {
		setState(() {
			_isLoading = true;
			_isError = false;
		});

		try {
			final resp = await libria.fetchCatalog(query);
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
		final q = await SearchDialog.show(context);
		if (q != null) {
			_loadTitles(query: q);
		}
	}



	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Каталог'),
				centerTitle: true,
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


		// Main
		return RefreshIndicator(
			onRefresh: _loadTitles,
			color: Theme.of(context).colorScheme.primary,
			child: _buildGridView(),
		);
	}

	Widget _buildGridView() {
		return GridView.builder(
			padding: const EdgeInsets.all(12),
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
						Navigator.push(context,
							MaterialPageRoute(
								builder: (context) => TitleEpisodes(titleId: _catalogResponse['data'][index]['id']),
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
