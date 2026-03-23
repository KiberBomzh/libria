part of 'title.dart';


class _TitleState extends State<TitleEpisodes> {
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
			final resp = await libria.fetchTitle(widget.titleId);
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


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Тайтл'),
				centerTitle: true,
			),
			body: _buildBody(),
			floatingActionButton: Container(
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



		// TODO сделать нормальную поддержку широких экранов
		return SingleChildScrollView(
			child: TitleDetails(
				nameRu: _titleResponse['name']['main'],
				nameEn: _titleResponse['name']['english'],
				coverImageUrl: base_url + _titleResponse['poster']['optimized']['src'],
				description: _titleResponse['description'],
				type: _titleResponse['type']['value'],
				episodesTotal: (_titleResponse['episodes_total'] != null) ?
					_titleResponse['episodes_total'].toString() : null
			),
		);
	}

	Widget _buildFAB() {
		return FloatingActionButton(
			child: const Icon(Icons.play_arrow),
			onPressed: () {
				showModalBottomSheet(
					context: context,
					isScrollControlled: true,
					builder: (context) => DraggableScrollableSheet(
						initialChildSize: 0.8,
						expand: false,
						builder: (context, scrollController) => Container(
							child: Center(
								child: EpisodesList(episodes: _titleResponse['episodes']),
							),
						),
					),
				);
			},
		);
	}
}
