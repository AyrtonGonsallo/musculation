import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/local_db.dart';

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Exporter la base de données'),
              onPressed: () async {
                await DatabaseExportService.exportDatabase(context);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Importer une base de données'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await DatabaseImportService.importDatabase(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
