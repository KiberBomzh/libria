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
		const oneElementHeight = 90;
		final elementsHeight = oneElementHeight * torrents.length + 50;

		final screenHeight = MediaQuery.of(context).size.height;
		final maxDialogHeight = screenHeight * 0.7;

		final dialogHeight = (elementsHeight > maxDialogHeight)
			? maxDialogHeight
			: elementsHeight;
		final dialogWidth = dialogHeight * ( 2 / 3 );

		return showDialog<void>(
			context: context,
			barrierDismissible: true,
			builder: (context) {
				return SimpleDialog(
					title: Container(
						child: Column(
							children: [
								Text('Выберите торрент',
									style: Theme.of(context).textTheme.titleLarge,
								),
								Text('Долгое нажатие чтоб скопировать magnet-ссылку',
									style: Theme.of(context).textTheme.titleSmall?.copyWith(
										color: Colors.grey,
									),
								),
							],
						),
					),
					children: [
						SizedBox(
							height: dialogHeight.toDouble(),
							width: dialogWidth,
							child: ListView.builder(
								itemCount: torrents.length,
								itemBuilder: (context, index) {
									return SimpleDialogOption(
										child: TorrentListItem(
											label: torrents[index]['label'],
											size: torrents[index]['size'],
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
		if (_isLoading && _titleResponse.isEmpty) {
			return _buildWithAppBar(
				child: const Center(
					child: CircularProgressIndicator(),
				),
			);
		}

		if (_isError) {
			return _buildWithAppBar(
				child: Center(
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
								Text('Не удалось загрузить тайтл: $_errorMessage'),
								const SizedBox(height: 16),
								ElevatedButton(
									onPressed: _loadTitle,
									child: const Text('Попробовать снова'),
								),
							],
						),
					),
				),
			);
		}

		if (_isWideScreen(context))
			return SafeArea(
				bottom: true,
				child: _buildWideScreenBody(),
			);


		return SafeArea(
			bottom: true,
			child: _buildWithAppBar(
				child: _buildBodyWithSlidingUpPanel(),
			),
		);
	}

	
	PreferredSizeWidget _buildAppBar() {
		return AppBar(
			title: const Text('Тайтл'),
			actions: [
				IconButton(
					icon: const Icon(Icons.launch),
					tooltip: "Открыть в браузере",
					onPressed: () =>
						launchUrl(Uri.parse(base_url + '/anime/releases/release/' + widget.currentTitle.titleId.toString())),
				),
				IconButton(
					icon: const Icon(Icons.search),
					tooltip: 'Поиск',
					onPressed: _openSearchDialog,
				),
				IconButton(
					icon: const Icon(Icons.settings),
					tooltip: 'Настройки',
					onPressed: () => Navigator.push(context,
						MaterialPageRoute(
							builder: (context) => SettingsScreen(),
						),
					),
				),
			],
		);
	}
	
	Widget _buildWithAppBar({ required Widget child }) {
		return Scaffold(
			appBar: _buildAppBar(),
			body: child,
		);
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

	Widget _buildWideScreenBody() {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Expanded(
					flex: 1,
					child: _buildWithAppBar(
						child: _buildTitleDetails(),
					),
				),

				Expanded(
					flex: 1,
					child: Container(
						color: Theme.of(context).colorScheme.surface,
						child: Container(
							margin: const EdgeInsets.only(
								top: 5,
								bottom: 20,
								right: 5,
								left: 5,
							),
							decoration: BoxDecoration(
								color: Theme.of(context).colorScheme.surfaceVariant,
								border: Border.all(
									width: 2,
									color: Theme.of(context).colorScheme.outline,
								),
								borderRadius: BorderRadius.circular(12),
							),
							child: EpisodesList(
								titleName: _titleResponse['name']['main'],
								episodes: _titleResponse['episodes'],
								currentTitle: widget.currentTitle,
								onTapDownload: () =>
									_openDownloadDialog(context, torrents: _titleResponse['torrents']),
								isWideScreen: true,
							),
						),
					),
				),
			],
		);
	}

	Widget _buildBodyWithSlidingUpPanel() {
		return SlidingUpPanel(
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
									titleName: _titleResponse['name']['main'],
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
			body: _buildTitleDetails(),
		);
	}



	bool _isWideScreen(BuildContext context) {
		return MediaQuery.of(context).size.width > 800;
	}
}
