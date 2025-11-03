import 'package:flutter/material.dart';

class FavoriteLocationCard extends StatelessWidget {
  final String cityName;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FavoriteLocationCard({
    Key? key,
    required this.cityName,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      elevation: 2,
      color: Colors.blueGrey[900],
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text(
          cityName,
          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
