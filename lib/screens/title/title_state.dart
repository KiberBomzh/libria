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

	Future<void> _openDownloadDialog(BuildContext context, {required List<dynamic> torrents}) async {
		return showDialog<void>(
			context: context,
			barrierDismissible: true,
			builder: (context) {
				return SimpleDialog(
					// title: const Text('Выберите качество'),
					children: [
						SizedBox(
							height: MediaQuery.of(context).size.height * 0.5,
							width: MediaQuery.of(context).size.width * 0.8,
							child: ListView.builder(
								itemCount: torrents.length,
								itemBuilder: (context, index) {
									return SimpleDialogOption(
										child: TorrentListItem(
											label: torrents[index]['label'],
											onLongTap: () => Clipboard.setData(ClipboardData(text: torrents[index]['magnet'])),
											onTap: () {
												launchUrl(Uri.parse(torrents[index]['magnet']));
												Navigator.pop(context);
											},
										),
									);
								}
							),
						),
					],
				);
			}
		);
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
			body: (!_isWideScreen(context) && _titleResponse.isNotEmpty)
				? SlidingUpPanel(
					minHeight: 120,
					maxHeight: MediaQuery.of(context).size.height * 0.9,
					snapPoint: 0.5,

					borderRadius: BorderRadius.circular(12),
					color: Theme.of(context).colorScheme.surfaceVariant,
					backdropEnabled: true,

					panelBuilder: (scrollController) {
						return Container(
							margin: const EdgeInsets.only(top: 10),
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
										child: EpisodesList(
											episodes: _titleResponse['episodes'],
											currentTitle: widget.currentTitle,
											controller: scrollController,
											onTapDownload: () =>
												_openDownloadDialog(context, torrents: _titleResponse['torrents']),
											isWideScreen: false,
										),
									),
								],
							),
						);
					},
					body: _buildBody(),
				)
				: _buildBody(),
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
								borderRadius: BorderRadius.circular(12),
								color: Theme.of(context).colorScheme.surfaceVariant,
							),
							child: EpisodesList(
								episodes: _titleResponse['episodes'],
								currentTitle: widget.currentTitle,
								onTapDownload: () =>
									_openDownloadDialog(context, torrents: _titleResponse['torrents']),
								isWideScreen: true,
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



	bool _isWideScreen(BuildContext context) {
		return MediaQuery.of(context).size.width > 800;
	}
}
