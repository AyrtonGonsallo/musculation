import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/exercice.dart';
import '../../models/partie.dart';
import '../../models/section.dart';
import '../../repositories/exercice_repository.dart';
import 'exercice_detail_screen.dart';

class ExercicesScreen extends StatefulWidget {
  const ExercicesScreen({super.key});

  @override
  State<ExercicesScreen> createState() => _ExercicesScreenState();
}

class _ExercicesScreenState extends State<ExercicesScreen> {

  void _openAddExercicePopup() {
    final titreController = TextEditingController();
    final lienController = TextEditingController();
    final gifController = TextEditingController();
    final categorieController = TextEditingController();

    // WYSIWYG pour conseils
    final conseilsController = QuillController.basic();

    // Dropdown IDs
    int? selectedSectionId;
    int? selectedPartieId;

    final sections = Hive.box<Section>('sections').values.toList();
    final parties = Hive.box<Partie>('parties').values.toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajouter un exercice'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titreController, decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: gifController, decoration: const InputDecoration(labelText: 'Gif URL')),
              TextField(controller: lienController, decoration: const InputDecoration(labelText: 'Lien vidéo')),
              TextField(controller: categorieController, decoration: const InputDecoration(labelText: 'Catégorie')),

              const SizedBox(height: 10),
              // Dropdown Section
              DropdownButtonFormField<int>(
                value: selectedSectionId,
                decoration: const InputDecoration(labelText: 'Section'),
                items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.titre))).toList(),
                onChanged: (val) => selectedSectionId = val,
              ),

              const SizedBox(height: 10),
              // Dropdown Partie
              DropdownButtonFormField<int>(
                value: selectedPartieId,
                decoration: const InputDecoration(labelText: 'Partie'),
                items: parties.map((p) => DropdownMenuItem(value: p.id, child: Text(p.titre))).toList(),
                onChanged: (val) => selectedPartieId = val,
              ),

              const SizedBox(height: 10),
              // WYSIWYG conseils
              SizedBox(
                height: 150,
                child: QuillEditor.basic(
                  controller: conseilsController,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (titreController.text.trim().isEmpty) return;

              final exercice = Exercice(
                id: DateTime.now().millisecondsSinceEpoch,
                titre: titreController.text.trim(),
                gif: gifController.text.trim(),
                lienVideo: lienController.text.trim(),
                categorie: (categorieController.text.trim()),
                sectionId: selectedSectionId ?? 0,
                partieId: selectedPartieId ?? 0,
                conseils: conseilsController.document.toPlainText(), // ou .toDelta() si tu veux stocker le delta JSON
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
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,title: const Text('Exercices')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExercicePopup,
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Exercice>('exercices').listenable(),
        builder: (context, Box<Exercice> box, _) {
          final exercices = box.values.toList();

          if (exercices.isEmpty) return const Center(child: Text('Aucun exercice'));

          return ListView.separated(
            itemCount: exercices.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = exercices[i];

              return ListTile(
                title: Text(e.titre),
                subtitle: Text('Catégorie: ${e.categorie}, Section: ${e.section?.titre}, Partie: ${e.partie?.titre}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // ⚡️ Important pour ne pas étirer
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                      tooltip: 'Voir',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciceDetailScreen(exercice: e),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Supprimer',
                      onPressed: () => e.delete(),
                    ),
                  ],
                ),
                onTap: () {
                  // plus tard: popup détail ou édition
                },
              );
            },
          );
        },
      ),
    );
  }
}
