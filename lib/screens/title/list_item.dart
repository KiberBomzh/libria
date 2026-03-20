part of 'title.dart';


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
