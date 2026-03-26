part of 'title.dart';


class _TitleState extends State<TitleScreen> {
	Map<String, dynamic> _titleResponse = {};
	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';


	@override
	void initState() {
		super.initState();
		_loadTitle();
	}

	Future<void> _loadTitle() async {
		setState(() {
			_isLoading = true;
			_isError = false;
		});

		try {
			final resp = await libria.fetchTitle(widget.currentTitle.titleId!);
			setState(() {
				_titleResponse = resp;
				_isLoading = false;
			});
		} catch (e) {
			setState(() {
				_isError = true;
				_errorMessage = e.toString();

				_isLoading = false;
			});
		}
	}

	void _openSearchDialog() async {
		final q = await SearchDialog.show(context);
		if (q != null && q.isNotEmpty) {
			Navigator.push(context,
				MaterialPageRoute(
					builder: (context) => Catalog(searchQuery: q),
				),
			);
		}
	}


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Тайтл'),
				actions: [
					IconButton(
						icon: const Icon(Icons.launch),
						onPressed: () =>
							launchUrl(Uri.parse(base_url + '/anime/releases/release/' + widget.currentTitle.titleId.toString())),
						tooltip: "Открыть в браузере",
					),
					IconButton(
						icon: const Icon(Icons.search),
						onPressed: _openSearchDialog,
						tooltip: 'Поиск',
					),
				],
			),
			body: _buildBody(),
			floatingActionButton: (_isWideScreen(context))
				? Container()
				: Container(
					margin: EdgeInsets.only(
						bottom: 20,
						right: 20,
					),
					child: _buildFAB(),
				),
		);
	}


	Widget _buildBody() {
		if (_isLoading && _titleResponse.isEmpty) {
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
						Text('Не удалось загрузить тайтл: $_errorMessage'),
						const SizedBox(height: 16),
						ElevatedButton(
							onPressed: _loadTitle,
							child: const Text('Попробовать снова'),
						),
					],
				),
			);
		}


		if (_isWideScreen(context)) {
			return Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Expanded(
						flex: 5,
						child: _buildTitleDetails(),
					),

					Expanded(
						flex: 5,
						child: Container(
							margin: const EdgeInsets.only(bottom: 5, right: 5),
							decoration: BoxDecoration(
								border: Border.all(
									width: 2,
									color: Theme.of(context).colorScheme.secondary,
								),
								borderRadius: BorderRadius.circular(12),
								color: Theme.of(context).colorScheme.surfaceContainer,
							),
							child: TitleLists(
								episodes: _titleResponse['episodes'],
								torrents: _titleResponse['torrents'],
								currentTitle: widget.currentTitle,
							),
						),
					),
				],
			);
		}

		return _buildTitleDetails();
	}

	Widget _buildTitleDetails() {
		ScrollController scrollController = ScrollController();

		return Scrollbar(
			interactive: true,
			thickness: 4.0,
			radius: const Radius.circular(12),
			controller: scrollController,
			child: SingleChildScrollView(
				controller: scrollController,
				child: TitleDetails(
					nameRu: _titleResponse['name']['main'],
					nameEn: _titleResponse['name']['english'],
					coverImageUrl: base_url + _titleResponse['poster']['optimized']['src'],
					description: _titleResponse['description'],
					type: _titleResponse['type']['description'],
					episodesTotal: (_titleResponse['episodes_total'] != null) ?
						_titleResponse['episodes_total'].toString() : null
				),
			),
		);
	}

	Widget _buildFAB() {
		return FloatingActionButton(
			child: const Icon(Icons.play_arrow),
			onPressed: () => _buildBottomSheet(),
		);
	}

	void _buildBottomSheet() {
		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (context) => DraggableScrollableSheet(
				initialChildSize: 0.5,
				minChildSize: 0.0,
				maxChildSize: 0.9,
				snap: true,
				snapSizes: const [0.5, 0.9],
				expand: false,
				builder: (context, scrollController) {
					WidgetsBinding.instance.addPostFrameCallback((_) {
						if (_isWideScreen(context)) {
							Navigator.of(context).pop();
						}
					});

					return Container(
						decoration: BoxDecoration(
							color: Theme.of(context).colorScheme.surface,
							borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
							boxShadow: [
								BoxShadow(
									color: Colors.black26,
									blurRadius: 16,
									offset: Offset(0, -4),
								),
							],
						),
						child: Column(
							children: [
								Container(
									width: 40,
									height: 5,
									margin: const EdgeInsets.symmetric(vertical: 12),
									decoration: BoxDecoration(
										color: Colors.grey[400],
										borderRadius: BorderRadius.circular(10),
									),
								),

								Expanded(
									child: TitleLists(
										episodes: _titleResponse['episodes'],
										torrents: _titleResponse['torrents'],
										currentTitle: widget.currentTitle,
										controller: scrollController,
									),
								),
							],
						),
					);
				}
			),
		);
	}



	bool _isWideScreen(BuildContext context) {
		return MediaQuery.of(context).size.width > 800;
	}
}
