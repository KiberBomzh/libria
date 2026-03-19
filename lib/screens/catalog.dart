import 'package:flutter/material.dart';
import 'package:libria/main.dart';


class Catalog extends StatefulWidget {
	Catalog({super.key});

	@override
	State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
	Map<String, dynamic> _catalogResponse = {};

	bool _isLoading = false;
	bool _isError = false;
	String _errorMessage = '';


	@override
	void initState() {
		super.initState();
		_loadTitles();
	}


	Future<void> _loadTitles() async {
		setState(() {
			_isLoading = true;
			_isError = false;
		});

		try {
			final resp = await libria.fetchCatalog();
			setState(() {
				_catalogResponse = resp;
				_isLoading = false;
			});
		} catch(e) {
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
				title: const Text('Каталог'),
				centerTitle: true,
			),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		if (_isLoading && _catalogResponse.isEmpty) {
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
						Text( 'Ошибка загрузки: $_errorMessage', 
							textAlign: TextAlign.center,
						),
						const SizedBox(height: 16),
						ElevatedButton(
							onPressed: _loadTitles,
							child: const Text('Попробовать снова'),	
						),
					],
				),
			);
		}


		// Main
		return RefreshIndicator(
			onRefresh: _loadTitles,
			color: Theme.of(context).colorScheme.primary,
			child: _buildGridView(),
		);
	}

	Widget _buildGridView() {
		return GridView.builder(
			padding: const EdgeInsets.all(12),
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: _calculateCrossAxisCount(MediaQuery.of(context).size.width),
				crossAxisSpacing: 12,
				mainAxisSpacing: 12,
				childAspectRatio: 0.6,
			),
			itemCount: _catalogResponse['data'].length,
			itemBuilder: (context, index) {
				final name = _catalogResponse['data'][index]['name']['main'];
				final img_url = base_url + _catalogResponse['data'][index]['poster']['optimized']['preview'];

				return CatalogGridItem(
					titleCoverUrl: img_url,
					titleName: name,
					onTap: () {
						// TODO
					}
				);
			}
		);
	}

	// Адаптивное количество колонок в зависимости от ширины экрана
	int _calculateCrossAxisCount(double screenWidth) {
		if (screenWidth > 1200) {
			return 6;  // Очень широкий экран
		} else if (screenWidth > 800) {
			return 4;  // Планшет
		} else if (screenWidth > 600) {
			return 3;  // Маленький планшет / большой телефон
		} else {
			return 2;  // Обычный телефон
		}
	}
}




class CatalogGridItem extends StatelessWidget {
	final String titleCoverUrl;
	final String titleName;
	final VoidCallback onTap;

	const CatalogGridItem({
		Key? key,
		required this.titleCoverUrl,
		required this.titleName,
		required this.onTap
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: Card(
				color: Colors.grey[900],
				elevation: 4,
				clipBehavior: Clip.antiAlias,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(12),
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Cover
						Expanded(
							flex: 9,
							child: Container(
								width: double.infinity,
								child: Image.network( titleCoverUrl,
									fit: BoxFit.cover,
									loadingBuilder: (context, child, loadingProgress) {
										if (loadingProgress == null) return child;

										return Center(
											child: CircularProgressIndicator(
												value: loadingProgress.expectedTotalBytes != null
													? loadingProgress.cumulativeBytesLoaded /
													  loadingProgress.expectedTotalBytes!
													: null,
											),
										);
									},
									errorBuilder: (context, error, stackTrace) {
										return Container(
											color: Colors.grey[300],
											child: Center(
												child: Icon( Icons.broken_image,
													size: 50,
													color: Colors.grey[600],
												),
											),
										);
									}
								),
							),
						),

						// Title
						Expanded(
							flex: 2,
							child: Container(
								padding: const EdgeInsets.all(8),
								child: Text( titleName,
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
								),
							),
						),
					],
				),
			),
		);
	}
}
