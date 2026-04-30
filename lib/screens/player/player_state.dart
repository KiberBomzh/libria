part of 'player.dart';


enum VideoQuality {
	hls_480,
	hls_720,
	hls_1080;

	String to_string() => switch (this) {
		(VideoQuality.hls_480) => '480p',
		(VideoQuality.hls_720) => '720p',
		(VideoQuality.hls_1080) => '1080p',
	};
}

enum DoubleTapDirection {
	forward,
	backward;
}

const VideoQuality DEFAULT_QUALITY = VideoQuality.hls_1080;


class _PlayerState extends State<PlayerScreen> {
	late final BetterPlayerController _controller;

	@override
	void initState() {
		final source = BetterPlayerDataSource(
			BetterPlayerDataSourceType.network,
			widget.episodes[widget.index]['hls_720'],
		);
		_controller = BetterPlayerController(
			const BetterPlayerConfiguration(
				autoPlay: true,
				fit: .contain,
			),
			betterPlayerDataSource: source,
		);

		super.initState();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black,
			body: BetterPlayer(controller: _controller),
		);
	}
}
/*
	late final _player = Player();
	late final _controller = VideoController(_player);
	late Playlist _playlist;

	bool _showControls = false;
	Timer? _showControlsTimer;

	bool _isLoading = true;
	Timer? _loadingTimer;

	VideoQuality _quality = DEFAULT_QUALITY;

	late Map<String, dynamic> _currentEpisode;
	late String _currentEpisodeName;
	late int _currentIndex;
	int _lastSecond = 0;
	Duration _duration = Duration(seconds: 0);
	int _position = 0;
	bool _isPlaying = false;

	bool _inOpening = false;
	bool _inEnding = false;

	late StreamSubscription _playingSubscription;
	late StreamSubscription _bufferingSubscription;
	late StreamSubscription _completedSubscription;
	late StreamSubscription _durationSubscription;
	late StreamSubscription _positionSubscription;


	bool _wasDoubleTap = false;
	Timer? _doubleTapTimer;
	DoubleTapDirection _doubleTapDirection = DoubleTapDirection.forward;


	@override
	void initState() {
		super.initState();
		defaultEnterNativeFullscreen();

		_currentIndex = widget.index;

		_currentEpisode = widget.episodes[_currentIndex];

		_loadQuality();
		_loadPlaylist();
		_openPlayer();
		_subscribeOnStreams();

		_loadEpisodeName();
		_setLastLink();

		widget.title.episodeIndex = widget.index;
		Preferences.setLastTitle(widget.title);
	}

	@override
	void dispose() {
		_player.dispose();

		_loadingTimer?.cancel();
		_doubleTapTimer?.cancel();
		_showControlsTimer?.cancel();

		_playingSubscription.cancel();
		_bufferingSubscription.cancel();
		_completedSubscription.cancel();
		_durationSubscription.cancel();
		_positionSubscription.cancel();
		defaultExitNativeFullscreen();
		super.dispose();
	}

	void _loadQuality() {
		if (widget.quality == null)
			return;

		final q = widget.quality!;
		if (q == 480) {
			_quality = VideoQuality.hls_480;
		} else if (q == 720) {
			_quality = VideoQuality.hls_720;
		} else if (q == 1080) {
			_quality = VideoQuality.hls_1080;
		}
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
				await Future.delayed(Duration(seconds: 1));
			}

			_player.seek(Duration(seconds: widget.title.episodePosition!));
			setState(() => _isLoading = true);
			while (_position != widget.title.episodePosition) {
				await Future.delayed(Duration(seconds: 1));
			}

			setState(() => _isLoading = true);
			_player.play();
		} else {
			await _player.open(_playlist);
		}
	}

	void _subscribeOnStreams() {
		_bufferingSubscription = _player.stream.buffering.listen((buffering) {
			setState(() => _isLoading = true);
		});
		_completedSubscription = _player.stream.completed.listen((isCompleted) {
			if (isCompleted) {
				if (_currentIndex < widget.episodes.length - 1) {
					_currentIndex++;
					widget.title.episodeIndex = _currentIndex;
					Preferences.setLastTitle(widget.title);
					_currentEpisode = widget.episodes[_currentIndex];
					_loadEpisodeName();
					_setLastLink();
				} else {
					Navigator.of(context).pop();
				}
			}
		});
		_playingSubscription = _player.stream.playing.listen((playing) => _isPlaying = playing);
		_durationSubscription = _player.stream.duration.listen((duration) => _duration = duration);
		_positionSubscription = _player.stream.position.listen((Duration position) {
			if (_isLoading && _position != 0)
				setState(() => _isLoading = false);

			_loadingTimer?.cancel();
			if (_isPlaying)
				_loadingTimer = Timer(Duration(milliseconds: 300), () {
					if (_isPlaying)
						setState(() => _isLoading = true);
				});


			final inSeconds = position.inSeconds;
			_position = inSeconds;
			_checkPosition();

			if (inSeconds < 1)
				return;

			if (inSeconds != widget.title.episodePosition) {
				widget.title.episodePosition = inSeconds;
				Preferences.setLastTitle(widget.title);
			}
		});
	}

	void _loadEpisodeName() => setState(() {
		final ordinal = _currentEpisode['ordinal'];
		final name = _currentEpisode['name'];

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
		if (_inOpening) {
			final end = _currentEpisode['opening']['stop'];
			if (end != null) {
				_player.seek(Duration(seconds: end! + 1));
			}
		} else if (_inEnding) {
			final end = _currentEpisode['ending']['stop'];
			if (end != null) {
				_player.seek(Duration(seconds: end! + 1));
			}
		}
	}

	void _checkPosition() {
		if (_position == 0)
			return;

		// Opening
		final opening_start = _currentEpisode['opening']['start'];
		final opening_end = _currentEpisode['opening']['stop'];
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
		final ending_start = _currentEpisode['ending']['start'];
		final ending_end = _currentEpisode['ending']['stop'];
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

	void _changeQuality(VideoQuality newQuality) {
		setState(() => _quality = newQuality);
		_loadPlaylist();
		_openPlayer();
		_setLastLink();
	}

	String _getPositionAsString() {
		final duration = _duration.inSeconds;
		final position = _position;

		final durationMinutes = (duration / 60).floor();
		final durationSeconds = duration % 60;

		final positionMinutes = (position / 60).floor();
		final positionSeconds = position % 60;


		final positionMinutesStr = (positionMinutes < 10) ? '0$positionMinutes' : positionMinutes.toString();
		final positionSecondsStr = (positionSeconds < 10) ? '0$positionSeconds' : positionSeconds.toString();
		final durationMinutesStr = (durationMinutes < 10) ? '0$durationMinutes' : durationMinutes.toString();
		final durationSecondsStr = (durationSeconds < 10) ? '0$durationSeconds' : durationSeconds.toString();

		return positionMinutesStr + ':' + positionSecondsStr + ' / ' + durationMinutesStr + ':' + durationSecondsStr;
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
		const doubleTapDuration = Duration(milliseconds: 500);


		return Scaffold(
			backgroundColor: Colors.black,
			body: GestureDetector(
				onTap: (!_wasDoubleTap)
					? () => setState(() {
						_showControls = !_showControls;
						_showControlsTimer?.cancel();
						if (_showControls) {
							_showControlsTimer = Timer(Duration(seconds: 5), (){
								setState(() => _showControls = false);
							});
						}
					})
					: null,
				onDoubleTapDown: (!_wasDoubleTap)
					? (details) {
						final screenWidth = MediaQuery.of(context).size.width;
						const shiftSeconds = 5;

						setState(() => _wasDoubleTap = true);
						_doubleTapTimer = Timer(doubleTapDuration, () => setState(() => _wasDoubleTap = false));

						_showControlsTimer?.cancel();
						setState(() => _showControls = false);

						if (details.globalPosition.dx < screenWidth / 2) {
							setState(() => _doubleTapDirection = DoubleTapDirection.backward);
							_player.seek(Duration(seconds: (_position - shiftSeconds).clamp(0, _duration.inSeconds)));
						} else {
							setState(() => _doubleTapDirection = DoubleTapDirection.forward);
							_player.seek(Duration(seconds: (_position + shiftSeconds).clamp(0, _duration.inSeconds)));
						}
					}
					: null,
				onTapDown: (_wasDoubleTap)
					? (details) {
						final screenWidth = MediaQuery.of(context).size.width;
						const shiftSeconds = 5;

						_doubleTapTimer?.cancel();
						_doubleTapTimer = Timer(doubleTapDuration, () => setState(() => _wasDoubleTap = false));

						if (details.globalPosition.dx < screenWidth / 2) {
							setState(() => _doubleTapDirection = DoubleTapDirection.backward);
							_player.seek(Duration(seconds: (_position - shiftSeconds).clamp(0, _duration.inSeconds)));
						} else {
							setState(() => _doubleTapDirection = DoubleTapDirection.forward);
							_player.seek(Duration(seconds: (_position + shiftSeconds).clamp(0, _duration.inSeconds)));
						}
					}
					: null,
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

						if (_wasDoubleTap)
							Center(
								child: Container(
									padding: EdgeInsets.all(12),
									decoration: BoxDecoration(
										color: Colors.black54,
										borderRadius: .circular(8),
									),
									child: Column(
										mainAxisSize: .min,
										children: [
											Row(
												mainAxisSize: .min,
												children: [
													Icon((_doubleTapDirection == DoubleTapDirection.forward)
														? Icons.fast_forward
														: Icons.fast_rewind,
														color: Colors.white
													),
													SizedBox(width: 8),
													Text((_doubleTapDirection == DoubleTapDirection.forward)
														? '+5'
														: '-5',
														style: TextStyle(color: Colors.white)
													),
												],
											),

											Text(_getPositionAsString(),
												style: TextStyle(color: Colors.white)
											),
										],
									),
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
						const SizedBox(height: 10),
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
				Spacer(),

				MenuAnchor(
					builder: (context, controller, child) {
						return TextButton(
							child: Row(
								children: [
									Icon(Icons.high_quality),
									const SizedBox(width: 5),
									Text(_quality.to_string())
								],
							),
							onPressed: () {
								if (controller.isOpen) {
									controller.close();
								} else {
									controller.open();
								}
							},
							style: TextButton.styleFrom(foregroundColor: Colors.white),
						);
					},
					menuChildren: [
						if (_currentEpisode['hls_480'] != null)
							MenuItemButton(
								child: Padding(
									padding: const EdgeInsets.symmetric(horizontal: 10),
									child: Text('480p'),
								),
								onPressed: () => _changeQuality(VideoQuality.hls_480),
							),

						if  (_currentEpisode['hls_720'] != null)
							MenuItemButton(
								child: Padding(
									padding: const EdgeInsets.symmetric(horizontal: 10),
									child: Text('720p'),
								),
								onPressed: () => _changeQuality(VideoQuality.hls_720),
							),

						if (_currentEpisode['hls_1080'] != null)
							MenuItemButton(
								child: Padding(
									padding: const EdgeInsets.symmetric(horizontal: 10),
									child: Text('1080p'),
								),
								onPressed: () => _changeQuality(VideoQuality.hls_1080),
							),
					],
				),
				const SizedBox(width: 10),
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
							_currentEpisode = widget.episodes[_currentIndex];
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
							_currentEpisode = widget.episodes[_currentIndex];
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
}*/
