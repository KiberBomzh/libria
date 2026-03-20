part of 'catalog.dart';


class SearchDialog {
	static Future<String?> show(BuildContext context) async {
		final controller = TextEditingController();
		String searchQuery = '';

		return showDialog<String>(
			context: context,
			barrierDismissible: true,
			builder: (context) {
				return AlertDialog(
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(20),
					),
					title: Row(
						children: [
							Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
							const SizedBox(width: 8),
							const Text('Поиск'),
						],
					),
					content: TextField(
						controller: controller,
						autofocus: true,
						decoration: InputDecoration(
							hintText: 'Введите название тайтла...',
							prefixIcon: const Icon(Icons.search, color: Colors.grey),
							suffixIcon: ValueListenableBuilder<TextEditingValue>(
								valueListenable: controller,
								builder: (context, value, _) {
									return value.text.isNotEmpty
										? IconButton(
											icon: const Icon(Icons.clear, color: Colors.grey),
											onPressed: () {
												controller.clear();
												searchQuery = '';
											},
										)
										: const SizedBox.shrink();
								},
							),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide(color: Colors.grey.shade300),
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide(
									color: Theme.of(context).colorScheme.primary,
									width: 2,
								),
							),
						),
						onChanged: (value) {
							searchQuery = value;
						},
						onSubmitted: (value) {
							Navigator.of(context).pop(value);
						},
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.of(context).pop(),
							child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
						),
						ElevatedButton(
							onPressed: () => Navigator.of(context).pop(controller.text),
							style: ElevatedButton.styleFrom(
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
							),
							child: const Text('Поиск'),
						),
					],
				);
			},
		);
	}
}
