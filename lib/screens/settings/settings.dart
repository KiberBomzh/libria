import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:libria/services/settings_provider.dart';
import 'package:libria/functions/ask_quality.dart';

import 'package:libria/screens/settings/color_picker_dialog.dart';


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
				_buildListItem(context,
					child: _buildSwitchListItem(context,
						text: 'Темная тема',
						switchValue: settings.isDarkTheme ?? false,
						onChanged: settings.setDarkTheme,
					),
				),

				_buildListItem(context,
					onTap: () => showDialog<void>(
						context: context,
						builder: (context) => ColorPickerDialog(
							initialColor: settings.colorAccent,
							onColorSelected: settings.setColorAccent,
						),
					),
					child: Row(
						children: [
							Center(
								child: _buildText(context, 'Цветовой акцент приложения'),
							),
							Expanded(child: Container()),
						],
					),
				),

				_buildListItem(context,
					child: _buildSwitchListItem(context,
						text: 'Обратная сортировка эпизодов',
						switchValue: settings.reverseEpisodesSorting,
						onChanged: settings.setReverseEpisodesSorting,
					),
				),

				_buildListItem(context,
					onTap: () async {
						final int? q = await showQualityDialog(context,
							isAvailable480: true,
							isAvailable720: true,
							isAvailable1080: true,
						);
						if (q == null)
							return;

						await settings.setDefaultVideoQuality(q!);
					},
					child: Row(
						children: [
							Center(
								child: _buildText(context, 'Качество по умолчанию'),
							),
							Expanded(child: Container()),
						],
					),
				),

				_buildListItem(context,
					onTap: () => settings.resetToDefault(),
					child: Row(
						children: [
							Center(
								child: _buildText(context, 'Сбросить к настройкам по умолчанию'),
							),
							Expanded(child: Container()),
						],
					),
				),
			],
		);
	}

	Widget _buildListItem(BuildContext context, {required Widget child, VoidCallback? onTap}) {
		return Container(
			height: 70,
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: onTap,
					splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
					highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
					child: Container(
						padding: const EdgeInsets.symmetric(horizontal: 15),
						child: child,
					),
				),
			),
		);
	}

	Widget _buildSwitchListItem(BuildContext context,
	{
		required String text,
		required bool switchValue,
		required ValueChanged<bool> onChanged,
	}) {
		return Row(
			children: [
				_buildText(context, text),
				Expanded(child: Container()),
				Switch(
					value: switchValue,
					onChanged: onChanged,
				),
			],
		);
	}

	Widget _buildText(BuildContext context, String text) {
		return Text(text,
			overflow: TextOverflow.ellipsis,
			style: Theme.of(context).textTheme.bodyLarge,
		);
	}
}
