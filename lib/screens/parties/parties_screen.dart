import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/partie.dart';
import '../../repositories/partie_repository.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  void _openAddPartiePopup() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajouter une partie'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Titre de la partie',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

              setState(() {
                PartieRepository.add(controller.text.trim());
              });

              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parties = PartieRepository.getAll();

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,title: const Text('Parties')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPartiePopup,
        child: const Icon(Icons.add),
      ),
      body: parties.isEmpty
          ? const Center(child: Text('Aucune partie'))
          : ValueListenableBuilder(
        valueListenable: Hive.box<Partie>('parties').listenable(),
        builder: (_, Box<Partie> box, __) {
          final parties = box.values.toList();

          if (parties.isEmpty) {
            return const Center(child: Text('Aucune partie'));
          }

          return ListView.separated(
            itemCount: parties.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final partie = parties[i];

              return ListTile(
                title: Text(partie.titre),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => partie.delete(),
                ),
              );
            },
          );
        },
      )
      ,
    );
  }
}
