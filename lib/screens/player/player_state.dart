part of 'player.dart';


enum VideoQuality {
	hls_480,
	hls_720,
	hls_1080,
}

const VideoQuality DEFAULT_QUALITY = VideoQuality.hls_1080;


class _PlayerState extends State<PlayerScreen> {
	late final _player = Player();
	late final _controller = VideoController(_player);
	late Playlist _playlist;

	bool _showControls = false;
	Timer? _showControlsTimer;

	bool _isLoading = true;

	VideoQuality _quality = DEFAULT_QUALITY;

	late String _currentEpisodeName;
	late int _currentIndex;
	int _lastSecond = 0;
	Duration _duration = Duration(seconds: 0);
	int _position = 0;

	bool _inOpening = false;
	bool _inEnding = false;


	@override
	void initState() {
		super.initState();
		defaultEnterNativeFullscreen();

		_loadPlaylist();
		_openPlayer();

		_player.stream.buffering.listen((buffering) {
			setState(() => _isLoading = true);
		});
		_player.stream.duration.listen((duration) => _duration = duration);
		_player.stream.position.listen((Duration position) {
			if (_isLoading && _position != 0)
				setState(() => _isLoading = false);


			final inSeconds = position.inSeconds;
			_position = inSeconds;
			_checkPosition();

			if (inSeconds < 5)
				return;

			if (inSeconds != widget.title.episodePosition) {
				widget.title.episodePosition = inSeconds;
				Preferences.setLastTitle(widget.title);
			}
		});


		_currentIndex = widget.index;
		widget.title.episodeIndex = widget.index;
		Preferences.setLastTitle(widget.title);
		_loadEpisodeName();
		_setLastLink();
	}

	@override
	void dispose() {
		_player.dispose();

		_showControlsTimer?.cancel();
		defaultExitNativeFullscreen();
		super.dispose();
	}

	void _loadPlaylist() {
		final List<Media> links = [];
		for (int i = 0; i < widget.episodes.length; i++) {
			final link = _getLink(i);
			links.add(Media(link));
		}
		_playlist = Playlist(links, index: widget.index);
	}

	void _openPlayer() async {
		if (widget.title.episodeIndex == widget.index && 
			widget.title.episodePosition != null) {
			await _player.open(_playlist, play: false);
			setState(() => _isLoading = true);
			while (_duration.inSeconds < 5) {
				print('opening');
				await Future.delayed(Duration(seconds: 1));
			}

			_player.seek(Duration(seconds: widget.title.episodePosition!));
			setState(() => _isLoading = true);
			while (_position != widget.title.episodePosition) {
				print('seeking');
				await Future.delayed(Duration(seconds: 1));
			}

			setState(() => _isLoading = true);
			_player.play();
		} else {
			await _player.open(_playlist);
		}
	}

	void _loadEpisodeName() => setState(() {
		final episode = widget.episodes[_currentIndex];
		final ordinal = episode['ordinal'];
		final name = episode['name'];

		if (name != null)
			_currentEpisodeName = "Эпизод $ordinal. $name";
		else
			_currentEpisodeName = "Эпизод $ordinal";
	});

	void _setLastLink() {
		final link = _playlist.medias[_currentIndex].uri;
		widget.title.episodeLink = link;
		Preferences.setLastTitle(widget.title);
	}


	String _getLink(int index) {
		String? link;
		VideoQuality q = _quality;
		int counter = 0;
		while (link == null) {
			counter++;
			if (counter > 10) {
				break;
			}
			switch (q) {
				case (VideoQuality.hls_480):
					link = widget.episodes[index]['hls_480'];
					if (link == null) {
						q = VideoQuality.hls_1080;
					} else {
						return link!;
					}
					break;

				case (VideoQuality.hls_720):
					final link = widget.episodes[index]['hls_720'];
					if (link == null) {
						q = VideoQuality.hls_480;
					} else {
						return link!;
					}
					break;

				case (VideoQuality.hls_1080):
					final link = widget.episodes[index]['hls_1080'];
					if (link == null) {
						q = VideoQuality.hls_720;
					} else {
						return link!;
					}
					break;
			}
		}

		return '';
	}

	void _skip() {
		final episode = widget.episodes[_currentIndex];
		if (_inOpening) {
			final end = episode['opening']['stop'];
			if (end != null) {
				_player.seek(Duration(seconds: end! + 1));
			}
		} else if (_inEnding) {
			final end = episode['ending']['stop'];
			if (end != null) {
				_player.seek(Duration(seconds: end!));
			}
		}
	}

	void _checkPosition() {
		final episode = widget.episodes[_currentIndex];
		if (_position == 0)
			return;

		// Opening
		final opening_start = episode['opening']['start'];
		final opening_end = episode['opening']['stop'];
		if (opening_start != null && opening_end != null) {
			setState(() {
				if (opening_start! <= _position && opening_end >= _position) {
					_inOpening = true;
				} else {
					_inOpening = false;
				}
			});
		}


		// Ending
		final ending_start = episode['ending']['start'];
		final ending_end = episode['ending']['stop'];
		if (ending_start != null && ending_end != null) {
			setState(() {
				if (ending_start! <= _position && ending_end >= _position) {
					_inEnding = true;
				} else {
					_inEnding = false;
				}
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		if (_controller == null)
			return const Center(child: CircularProgressIndicator());

		final videoTheme = MaterialVideoControlsThemeData(
			seekBarPositionColor: Theme.of(context).colorScheme.primary,
			seekBarThumbColor: Theme.of(context).colorScheme.primary,
			seekBarHeight: 4,
			seekBarContainerHeight: 20,
		);


		return Scaffold(
			backgroundColor: Colors.black,
			body: GestureDetector(
				onTap: () => setState(() {
					_showControls = !_showControls;
					_showControlsTimer?.cancel();
					if (_showControls) {
						_showControlsTimer = Timer(Duration(seconds: 5), (){
							setState(() => _showControls = false);
						});
					}
				}),
				child: Stack(
					children: [
						MaterialVideoControlsTheme(
							normal: videoTheme,
							fullscreen: MaterialVideoControlsThemeData(),
							child: Video(
								controller: _controller!,
								controls: _buildControls,
							),
						),
						if (_isLoading)
							Center(
								child: CircularProgressIndicator()
							),

						if (_inOpening || _inEnding)
							Align(
								alignment: .bottomRight,
								child: Container(
									margin: const EdgeInsets.only(bottom: 35, right: 20),
									decoration: BoxDecoration(
										color: Colors.black.withOpacity(0.5),
										borderRadius: .circular(5),
									),
									child: TextButton(
										child: Text('Пропустить'),
										onPressed: _skip,
									),
								),
							),
					],
				),
			),
		);
	}

	Widget _buildControls(VideoState state) {
		if (!_showControls)
			return SizedBox();

		return Stack(
			children: [
				Container(color: Colors.black.withOpacity(0.5)),
				Column(
					mainAxisAlignment: .center,
					children: [
						const SizedBox(height: 20),
						_buildTop(state),

						Spacer(),
						Expanded(
							child: _buildCenter(state),
						),
						Spacer(),

						_buildBottom(state),
						const SizedBox(height: 20),
					],
				),
			],
		);
	}

	Widget _buildTop(VideoState state) {
		return Row(
			children: [
				BackButton(),
				const SizedBox(width: 10),

				Text(_currentEpisodeName),
			],
		);
	}

	Widget _buildCenter(VideoState state) {
		return Row(
			mainAxisAlignment: .center,
			children: [
				Spacer(flex: 2),
				IconButton(
					icon: Icon(Icons.skip_previous,
						size: 40,
						color: (_currentIndex > 0)
							? Colors.white
							: Colors.grey,
					),
					onPressed: (_currentIndex > 0)
						? () async {
							await _player.previous();
							_currentIndex--;
							widget.title.episodeIndex = _currentIndex;
							await Preferences.setLastTitle(widget.title);
							_loadEpisodeName();
							_setLastLink();
						}
						: null,
				),

				Spacer(),
				if (!_isLoading)
					MaterialPlayOrPauseButton(iconSize: 50),
				Spacer(),

				IconButton(
					icon: Icon(Icons.skip_next,
					size: 40,
					color: (_currentIndex < widget.episodes.length - 1)
							? Colors.white
							: Colors.grey,
					),
					onPressed: (_currentIndex < widget.episodes.length - 1)
						? () async {
							await _player.next();
							_currentIndex++;
							widget.title.episodeIndex = _currentIndex;
							await Preferences.setLastTitle(widget.title);
							_loadEpisodeName();
							_setLastLink();
						}
						: null,
				),
				Spacer(flex: 2),
			],
		);
	}

	Widget _buildBottom(VideoState state) {
		return Column(
			crossAxisAlignment: .start,
			children: [
				Padding(
					padding: const EdgeInsets.only(left: 10),
					child: MaterialPositionIndicator(),
				),
				MaterialSeekBar(),
			],
		);
	}
}
