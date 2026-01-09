import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/exercice.dart';
import '../../models/partie.dart';
import '../../models/section.dart';
import '../../repositories/exercice_repository.dart';
import 'exercice_detail_screen.dart';

const List<String> exerciceCategories = [
  'Exercice de base',
  'Exercice d\'isolation',
  'Renforcement',
  'Échauffement',
];


class ExercicesScreen extends StatefulWidget {
  const ExercicesScreen({super.key});

  @override
  State<ExercicesScreen> createState() => _ExercicesScreenState();
}

class _ExercicesScreenState extends State<ExercicesScreen> {

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  void _openAddExercicePopup() {
    final titreController = TextEditingController();
    final lienController = TextEditingController();
    final gifController = TextEditingController();
    final categorieController = TextEditingController();



    // WYSIWYG pour conseils
    final conseilsController =
    TextEditingController();

    // Dropdown IDs
    int? selectedSectionId;
    int? selectedPartieId;
    String? selectedCategorie;
    String? gifLocalPath; // chemin du gif uploadé

    Future<void> pickGif() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          gifLocalPath = result.files.single.path!;
        });
      }
    }


    final sections = Hive.box<Section>('sections').values.toList()..sort((a, b) =>
        a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));;
    final parties = Hive.box<Partie>('parties').values.toList()..sort((a, b) =>
        a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un exercice'),
        content: SizedBox(
          // Limite la hauteur pour permettre le scroll si nécessaire
          height: MediaQuery.of(context).size.height * 0.8,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titreController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                // GIF local
                OutlinedButton.icon(
                  icon: const Icon(Icons.gif_box),
                  label: Text(gifLocalPath == null ? 'Image GIF locale' : 'Image GIF locale sélectionnée'),
                  onPressed: pickGif,
                ),
                if (gifLocalPath != null) ...[
                  const SizedBox(height: 10),
                  Image.file(
                    File(gifLocalPath!),
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ],
                TextField(
                  controller: lienController,
                  decoration: const InputDecoration(labelText: 'Lien vidéo'),
                ),
                const SizedBox(height: 10),
                // Catégorie
                DropdownButtonFormField<String>(
                  value: selectedCategorie,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: exerciceCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategorie = val),
                ),
                const SizedBox(height: 10),
                // Section
                DropdownButtonFormField<int>(
                  value: selectedSectionId,
                  decoration: const InputDecoration(labelText: 'Section'),
                  items: sections
                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.titre)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedSectionId = val),
                ),
                const SizedBox(height: 10),
                // Partie
                DropdownButtonFormField<int>(
                  value: selectedPartieId,
                  decoration: const InputDecoration(labelText: 'Partie'),
                  items: parties
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.titre)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedPartieId = val),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),
                // Conseils WYSIWYG
                const Text("Conseils :"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: conseilsController,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: "Conseils d'exécution...",
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),

              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (titreController.text.trim().isEmpty) return;

              final exercice = Exercice(
                id: DateTime.now().millisecondsSinceEpoch.remainder(0xFFFFFFFF),
                titre: titreController.text.trim(),
                gif: gifController.text.trim(),
                lienVideo: lienController.text.trim(),
                categorie: selectedCategorie ?? '',
                sectionId: selectedSectionId ?? 0,
                partieId: selectedPartieId ?? 0,
                conseils: conseilsController.text,
                gif_local: gifLocalPath ?? '',
              );

              ExerciceRepository.add(exercice);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Exercices'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExercicePopup,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 🔍 BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _query = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Rechercher par titre, catégorie, section, partie',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 📃 LISTE
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Exercice>('exercices').listenable(),
              builder: (context, Box<Exercice> box, _) {
                final exercices = box.values.where((e) {
                  if (_query.isEmpty) return true;

                  return e.titre.toLowerCase().contains(_query) ||
                      (e.categorie?.toLowerCase().contains(_query) ?? false) ||
                      (e.section?.titre.toLowerCase().contains(_query) ?? false) ||
                      (e.partie?.titre.toLowerCase().contains(_query) ?? false);
                }).toList()
                  ..sort((a, b) =>
                      a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));

                if (exercices.isEmpty) {
                  return const Center(child: Text('Aucun exercice trouvé'));
                }

                return ListView.separated(
                  itemCount: exercices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final e = exercices[i];

                    return ListTile(
                      title: Text(e.titre),
                      subtitle: Text(
                        'Catégorie: ${e.categorie} | '
                            'Section: ${e.section?.titre ?? '-'} | '
                            'Partie: ${e.partie?.titre ?? '-'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExerciceDetailScreen(exercice: e),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => e.delete(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
