import 'package:flutter/material.dart';


class ColorPickerDialog extends StatefulWidget {
	final Color? initialColor;
	final Function(ColorItem) onColorSelected;
  
	const ColorPickerDialog({
		Key? key,
		this.initialColor,
		required this.onColorSelected,
	}) : super(key: key);

	@override
	State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
	late List<ColorItem> _allColors;

	@override
	void initState() {
		super.initState();
		_loadColors();
	}

	void _loadColors() {
		_allColors = ColorItem.getAll();
	}

	@override
	Widget build(BuildContext context) {
		final sideSize = MediaQuery.of(context).size.height * 0.5;

		return Dialog(
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(20),
			),
			child: Container(
				width: sideSize,
				height: sideSize,
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						Text('Выберите цвет',
							style: Theme.of(context).textTheme.titleLarge,
						),
						const SizedBox(height: 16),
						Expanded(
							child: GridView.builder(
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: 4,
									crossAxisSpacing: 8,
									mainAxisSpacing: 8,
									childAspectRatio: 1,
								),
								itemCount: _allColors.length,
								itemBuilder: (context, index) {
									final colorItem = _allColors[index];
									final color = colorItem.color;
									final colorName = colorItem.name;
                  
									return GestureDetector(
										onTap: () {
											widget.onColorSelected(colorItem);
											Navigator.pop(context);
										},
										child: Container(
											decoration: BoxDecoration(
												color: color,
												borderRadius: BorderRadius.circular(12),
												border: Border.all(
													color: widget.initialColor == color
														? Theme.of(context).colorScheme.onSurface
														: Theme.of(context).colorScheme.outline,
													width: widget.initialColor == color? 5 : 2,
												),
												boxShadow: [
													if (widget.initialColor == color)
														BoxShadow(
															color: color.withOpacity(0.5),
															blurRadius: 8,
															spreadRadius: 2,
														),
												],
											),
											child: widget.initialColor == color
												? const Icon(Icons.check, color: Colors.white)
												: null,
										),
									);
								},
							),
						),
					],
				),
			),
		);
	}
}

class ColorItem {
	final String name;
	final Color color;
  
	ColorItem(this.name, this.color);


	static List<ColorItem> getAll() {
		return [
			ColorItem('red', Colors.red),
			ColorItem('pink', Colors.pink),
			ColorItem('purple', Colors.purple),
			ColorItem('deepPurple', Colors.deepPurple),
			ColorItem('indigo', Colors.indigo),
			ColorItem('blue', Colors.blue),
			ColorItem('lightBlue', Colors.lightBlue),
			ColorItem('cyan', Colors.cyan),
			ColorItem('green', Colors.green),
			ColorItem('lightGreen', Colors.lightGreen),
			ColorItem('lime', Colors.lime),
			ColorItem('yellow', Colors.yellow),
			ColorItem('amber', Colors.amber),
			ColorItem('orange', Colors.orange),
			ColorItem('deepOrange', Colors.deepOrange),
			ColorItem('brown', Colors.brown),
		];
	}

	static ColorItem fromString(String value) {
		return switch (value) {
			'red' => ColorItem('red', Colors.red),
			'pink' => ColorItem('pink', Colors.pink),
			'purple' => ColorItem('purple', Colors.purple),
			'deepPurple' => ColorItem('deepPurple', Colors.deepPurple),
			'indigo' => ColorItem('indigo', Colors.indigo),
			'blue' => ColorItem('blue', Colors.blue),
			'lightBlue' => ColorItem('lightBlue', Colors.lightBlue),
			'cyan' => ColorItem('cyan', Colors.cyan),
			'green' => ColorItem('green', Colors.green),
			'lightGreen' => ColorItem('lightGreen', Colors.lightGreen),
			'lime' => ColorItem('lime', Colors.lime),
			'yellow' => ColorItem('yellow', Colors.yellow),
			'amber' => ColorItem('amber', Colors.amber),
			'orange' => ColorItem('orange', Colors.orange),
			'deepOrange' => ColorItem('deepOrange', Colors.deepOrange),
			'brown' => ColorItem('brown', Colors.brown),
			_ => ColorItem('blue', Colors.blue)
		};
	}
}
