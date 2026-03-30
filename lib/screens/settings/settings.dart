import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:libria/services/settings_provider.dart';


class SettingsScreen extends StatelessWidget {
	SettingsScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Настройки')),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		final settings = context.watch<SettingsProvider>();

		return ListView(
			children: [
				_buildSwitchListItem(
					text: 'Темная тема',
					switchValue: settings.isDarkTheme ?? false,
					onChanged: settings.setDarkTheme,
				),
				_buildSwitchListItem(
					text: 'Обратная сортировка эпизодов',
					switchValue: settings.reverseEpisodesSorting,
					onChanged: settings.setReverseEpisodesSorting,
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
