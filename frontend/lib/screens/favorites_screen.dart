import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: provider.favorites.isEmpty
          ? Center(child: Text('No favorite locations yet', style: TextStyle(color: Colors.grey.shade600)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: provider.favorites.length,
              itemBuilder: (context, i) {
                final fav = provider.favorites[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(Icons.star_rounded, color: AppTheme.accent),
                    title: Text(fav.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(fav.address ?? '${fav.latitude.toStringAsFixed(4)}, ${fav.longitude.toStringAsFixed(4)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => provider.removeFavorite(fav.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final labelCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add favorite location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (e.g. Home)')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: latCtrl, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: lonCtrl, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final lat = double.tryParse(latCtrl.text);
                  final lon = double.tryParse(lonCtrl.text);
                  if (labelCtrl.text.trim().isEmpty || lat == null || lon == null) return;
                  ctx.read<FavoritesProvider>().addFavorite(label: labelCtrl.text.trim(), latitude: lat, longitude: lon);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
