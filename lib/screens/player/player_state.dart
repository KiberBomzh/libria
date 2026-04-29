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

	bool _isPlaying = false;
	bool _isBuffering = false;
	bool _isLoading = true;

	VideoQuality _quality = DEFAULT_QUALITY;

	late String _currentEpisodeName;
	late int _currentIndex;
	int _lastSecond = 0;
	Duration _duration = Duration(seconds: 0);
	int _position = 0;


	@override
	void initState() {
		super.initState();
		defaultEnterNativeFullscreen();

		_loadPlaylist();
		_openPlayer();

		_player.stream.buffering.listen((buffering) {
			_isBuffering = buffering;
			_updateIsLoading();
		});
		_player.stream.playing.listen((playing) {
			_isPlaying = playing;
			_updateIsLoading();
		});
		_player.stream.duration.listen((duration) => _duration = duration);
		_player.stream.position.listen((Duration position) {
			final inSeconds = position.inSeconds;
			_position = inSeconds;

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

	void _updateIsLoading() => setState(() {
		if (!_isPlaying && _isBuffering) {
			_isLoading = true;
		} else {
			_isLoading = false;
		}
	});

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
			setState(() => _isLoading = true);
			await _player.open(_playlist, play: false);
			while (_duration.inSeconds < 5) {
				print('opening');
				await Future.delayed(Duration(seconds: 1));
			}

			setState(() => _isLoading = true);
			_player.seek(Duration(seconds: widget.title.episodePosition!));
			while (_position != widget.title.episodePosition) {
				print('seeking');
				await Future.delayed(Duration(seconds: 1));
			}

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
					],
				),
			),
		);
	}

	Widget _buildControls(VideoState state) {
		if (!_showControls)
			return SizedBox();

		return Column(
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
						size: 50,
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
					size: 50,
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
