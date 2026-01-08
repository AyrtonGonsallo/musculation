import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/section.dart';
import '../../repositories/section_repository.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  void _openAddSectionPopup() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajouter une section'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Titre de la section',
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
                SectionRepository.add(controller.text.trim());
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
    final sections = SectionRepository.getAll();

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,title: const Text('Sections')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSectionPopup,
        child: const Icon(Icons.add),
      ),
      body: sections.isEmpty
          ? const Center(child: Text('Aucune section'))
          : ValueListenableBuilder(
        valueListenable: Hive.box<Section>('sections').listenable(),
        builder: (_, Box<Section> box, __) {
          final sections = box.values.toList()..sort((a, b) =>
              a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));;

          if (sections.isEmpty) {
            return const Center(child: Text('Aucune section'));
          }

          return ListView.separated(
            itemCount: sections.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final section = sections[i];

              return ListTile(
                title: Text("${section.id} - ${section.titre}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => section.delete(),
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
