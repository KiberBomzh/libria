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



		return Text('Всё хуйня');
	}

	Widget _buildFAB() {
		double screenHeight = MediaQuery.of(context).size.height;

		return FloatingActionButton(
			child: const Icon(Icons.play_arrow),
			onPressed: () {
				showModalBottomSheet<void>(
					context: context,
					builder: (BuildContext context) {
						return Container(
							height: screenHeight * 0.5,
							margin: EdgeInsets.all(20),
							child: Center(
								child: EpisodesList(episodes: _titleResponse['episodes']),
							),
						);
					},
				);
			},
		);
	}
}
