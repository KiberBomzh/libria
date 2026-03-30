import 'package:flutter/material.dart';

import 'package:libria/services/preferences.dart';


class SettingsScreen extends StatefulWidget {
	SettingsScreen({super.key});

	@override
	State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
	bool _reverseEpisodesSorting = Preferences.getBool('reverse_episodes_sorting') ?? false;
	bool _isDarkTheme = Preferences.getBool('is_dark_theme') ?? false;


	@override
	Widget build(BuildContext) {
		return Scaffold(
			appBar: AppBar(title: Text('Настройки')),
			body: _buildBody(),
		);
	}

	Widget _buildBody() {
		return ListView(
			children: [
				_buildSwitchListItem(
					text: 'Темная тема',
					switchValue: _isDarkTheme,
					onChanged: (v) {
						setState(() { _isDarkTheme = v; });
						Preferences.setBool('is_dark_theme', v);
					},
				),
				_buildSwitchListItem(
					text: 'Обратная сортировка эпизодов',
					switchValue: _reverseEpisodesSorting,
					onChanged: (v) {
						setState(() { _reverseEpisodesSorting = v; });
						Preferences.setBool('reverse_episodes_sorting', v);
					},
				),
			],
		);
	}

	Widget _buildSwitchListItem({
		required String text,
		required bool switchValue,
		required ValueChanged<bool> onChanged,
	}) {
		return Container(
			margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
			child: Row(
				children: [
					Text(text),
					Expanded(child: Container()),
					Switch(
						value: switchValue,
						onChanged: onChanged,
					),
				],
			),
		);
	}
}
