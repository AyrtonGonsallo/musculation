import 'package:flutter/material.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:intl/intl.dart';

import '../../models/exercice.dart';
import '../../models/seance.dart';
import '../../repositories/seance_repository.dart';
import '../exercices/exercice_detail_screen.dart';


class SeanceDetailScreen extends StatefulWidget {
  final Seance seance;

  const SeanceDetailScreen({super.key, required this.seance});

  @override
  State<SeanceDetailScreen> createState() => _SeanceDetailScreenState();
}

class _SeanceDetailScreenState extends State<SeanceDetailScreen> {
  late List<Exercice> exercices;
  final SeanceRepository seanceRepo = SeanceRepository();
  final DateFormat dateFormat = DateFormat("EEEE d MMMM yyyy", "fr_FR");

  @override
  void initState() {
    super.initState();
    // copie locale pour drag & drop
    exercices = List.from(widget.seance.exercices);
  }

  Future<void> _saveOrder() async {
    widget.seance.exercices = List.from(exercices);
    print("id ${widget.seance.id}");
    await seanceRepo.put(widget.seance); // <-- ici on utilise put

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ordre des exercices sauvegardé')),
    );
  }


  String formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    return d.toString().split('.').first.padLeft(8, "0"); // HH:MM:SS
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title:  Text('Séance: ${widget.seance.jour.toLocal().toString().split(' ')[0]}')),
      body: Column(
        children: [
          // Header séance avec durée et calories
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Séance du ${dateFormat.format(widget.seance.jour)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Durée: ${widget.seance.duree}',
                    style: const TextStyle(fontSize: 16)),
                Text('Calories brûlées: ${widget.seance.caloriesBrulees}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Exercices:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    ElevatedButton.icon(
                      onPressed: _saveOrder,
                      icon: const Icon(Icons.save),
                      label: const Text('Sauvegarder'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Liste réordonnable
          Expanded(
            child: AnimatedReorderableListView<Exercice>(
              items: exercices,
              dragStartDelay: const Duration(milliseconds: 200),
              isSameItem: (a, b) => a.id == b.id,
              enterTransition: [SlideInDown()],
              exitTransition: [SlideInUp()],
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final item = exercices.removeAt(oldIndex);
                  exercices.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final e = exercices[index];
                return Card(
                  key: ValueKey(e.id),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(e.titre),
                    subtitle: Text(
                        'Catégorie: ${e.categorie}, Section: ${e.section!.titre}, Partie: ${e.partie!.titre}'),

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
                          onPressed: () {
                            setState(() {
                              exercices.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
