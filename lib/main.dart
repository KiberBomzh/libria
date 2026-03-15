import 'package:flutter/material.dart';
import 'package:libria/services/anilibria_api.dart';


void main() {
	runApp(const MyApp());
}

var base_url = 'https://anilibria.top';
var libria = Anilibria(base_url + '/api/v1');




class MyApp extends StatelessWidget {
	const MyApp({super.key});

	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Libria',
			theme: ThemeData.dark(),
			home: const MyHomePage(title: 'Catalog'),
		);
	}
}

class MyHomePage extends StatefulWidget {
	const MyHomePage({super.key, required this.title});

	// This widget is the home page of your application. It is stateful, meaning
	// that it has a State object (defined below) that contains fields that affect
	// how it looks.

	// This class is the configuration for the state. It holds the values (in this
	// case the title) provided by the parent (in this case the App widget) and
	// used by the build method of the State. Fields in a Widget subclass are
	// always marked "final".

	final String title;

	@override
	State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	@override
	Widget build(BuildContext context) {
		// This method is rerun every time setState is called, for instance as done
		// by the _incrementCounter method above.
		//
		// The Flutter framework has been optimized to make rerunning build methods
		// fast, so that you can just rebuild anything that needs updating rather
		// than having to individually change instances of widgets.
		return Scaffold(
			appBar: AppBar(
				// TRY THIS: Try changing the color here to a specific color (to
				// Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
				// change color while the other colors stay the same.
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				// Here we take the value from the MyHomePage object that was created by
				// the App.build method, and use it to set our appbar title.
				title: Text(widget.title),
			),
			body: GridListScreen(),
		);
	}
}


class GridListScreen extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return FutureBuilder<Map<String, dynamic>>(
			future: libria.fetchCatalog(), // Асинхронный запрос
			builder: (context, snapshot) {
				// Проверка состояния загрузки
				if (snapshot.connectionState == ConnectionState.waiting) {
					return Center(child: CircularProgressIndicator());
				}
	  
				// Проверка на ошибки
				if (snapshot.hasError) {
					return Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(Icons.error_outline, size: 60, color: Colors.red),
								SizedBox(height: 16),
								Text('Ошибка загрузки: ${snapshot.error}'),
								SizedBox(height: 16),
								ElevatedButton(
									onPressed: () {
										// Перезагрузка через ключ или setState
									},
									child: Text('Повторить'),
								),
							],
						),
					);
				}
		
				// Проверка наличия данных
				if (!snapshot.hasData || snapshot.data!.isEmpty) {
					return Center(
						child: Text('Нет данных для отображения'),
					);
				}
		
				// Отображение данных
				final items = snapshot.data!['data'];
				return GridView.builder(
					padding: EdgeInsets.all(16),
					gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2,
						crossAxisSpacing: 16,
						mainAxisSpacing: 16,
						childAspectRatio: 0.6,
					),
					itemCount: items.length,
					itemBuilder: (context, index) {
						return Container(
							decoration: BoxDecoration(
								borderRadius: BorderRadius.circular(12),
								color: Colors.black,
								boxShadow: [
									BoxShadow(
										color: Colors.grey.withOpacity(0.2),
										spreadRadius: 1,
										blurRadius: 4,
										offset: Offset(0, 2),
									),
								],
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// Изображение фиксированной высоты
									ClipRRect(
										borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
										child: Image.network(
											base_url + items[index]['poster']['optimized']['preview'],
											height: 530, // Фиксированная высота изображения
											width: double.infinity,
											fit: BoxFit.cover,
											errorBuilder: (context, error, stackTrace) {
												return Container(
													height: 530,
													color: Colors.grey[300],
													child: Center(child: Icon(Icons.broken_image)),
												);
											},
										),
									),
									// Заголовок
									Padding(
										padding: EdgeInsets.all(12),
										child: Text(
											items[index]['name']['main'],
											style: TextStyle(
												fontSize: 16,
												fontWeight: FontWeight.w600,
											),
											maxLines: 2,
											overflow: TextOverflow.ellipsis,
										),
									),
								],
							),
						);
					},
				);
			},
		);
	}
}
