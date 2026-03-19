import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import 'package:libria/main.dart';


class TitleEpisodes extends StatefulWidget {
	int titleId;

	TitleEpisodes({
		Key? key,
		required this.titleId,
	}) : super(key: key);


	@override
	State<TitleEpisodes> createState() => _TitleState();
}

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
				backgroundColor: Theme.of(context).colorScheme.primary,
				title: const Text('Тайтл'),
				centerTitle: true,
			),
			body: _buildBody(),
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



		return _buildMain();
	}

	Widget _buildMain() {
		return ListView.builder(
			padding: const EdgeInsets.all(8),
			itemCount: _titleResponse['episodes'].length,
			itemBuilder: (context, index) {
				return EpisodeListItem(
					ordinal: _titleResponse['episodes'][index]['ordinal'],
					name: _titleResponse['episodes'][index]['name'],
					onTap: () {
						final intent = AndroidIntent(
							action: 'android.intent.action.VIEW',
							data: _titleResponse['episodes'][index]['hls_720'],
							type: 'video/mp4',
						);
						intent.launch();
					},
				);
			}
		);
	}
}


class EpisodeListItem extends StatelessWidget {
	final VoidCallback onTap;

	final int ordinal;
	final String? name;
	
	const EpisodeListItem({
		Key? key,
		required this.onTap,
		required this.ordinal,
		this.name,
	}) : super(key: key);


	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				border: Border(
					bottom: BorderSide(
						color: Colors.grey.withOpacity(0.1),
						width: 1.5,
					),
				),
			),
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: onTap,
					splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
					highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
					child: Padding(
						padding: EdgeInsets.symmetric(
							horizontal: 20,
							vertical: 10,
						),
						child: Row(
							children: [
								Container(
									width: 36,
									height: 36,
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
										border: Border.all(
											color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
											width: 2,
										),
									),
									child: Center(
										child: Text(ordinal.toString()),
									),
								),

								const SizedBox(width: 16),

								Expanded(
									child: Text(
										(name == null) ? '' : name.toString()
									),
								),
							],
						),
					),
				),
			),
		);
	}
}
