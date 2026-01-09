import 'package:flutter/material.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:intl/intl.dart';

import '../../models/exercice.dart';
import '../../models/seance.dart';
import '../../repositories/exercice_repository.dart';
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
  TimeOfDay? selectedTime;
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController _searchExerciceCtrl = TextEditingController();


  List<Exercice> allExercices = [];
  Exercice? selectedExercice;

  TimeOfDay timeOfDayFromString(String duree) {
    final parts = duree.split(':'); // ["01","02","33"]
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }


  @override
  void initState() {
    super.initState();
    // copie locale pour drag & drop
    exercices = List.from(widget.seance.exercices);
    _loadExercices();
    // Si tu stockes encore la durée en string
    if (widget.seance.duree.isNotEmpty) {
      selectedTime = timeOfDayFromString(widget.seance.duree);
    }
    final _fvar = selectedTime != null
    ? 'Durée: ${selectedTime!.hour}h ${selectedTime!
        .minute}min'
        : 'Choisir une durée';
    print(_fvar);
  }

  Future<void> _saveOrder() async {
    widget.seance.exercices = List.from(exercices);
    print("id ${widget.seance.id}");
    await seanceRepo.put(widget.seance); // <-- ici on utilise put

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ordre des exercices sauvegardé')),
    );
  }

  Future<void> _loadExercices() async {
    final list = await ExerciceRepository.getAll()
      ..sort((a, b) => a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));
    setState(() {
      allExercices = list;
    });
    print("loaded");
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Séance du ${dateFormat.format(widget.seance.jour)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit,color:Colors.blue),
                      tooltip: 'Modifier durée, exercices & calories',
                      onPressed: _openEditSeanceDialog,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),


                const SizedBox(height: 8),
                Text('Durée: ${widget.seance.duree}',
                    style: const TextStyle(fontSize: 16)),
                Text('Calories brûlées: ${widget.seance.caloriesBrulees} kcal',
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


  void _openEditSeanceDialog() async {
    caloriesController.text =
        widget.seance.caloriesBrulees?.toString() ?? '';

    TimeOfDay timeOfDayFromString(String duree) {
      final parts = duree.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    selectedExercice = null;


    showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
              builder: (context, setModalState) {


                return AlertDialog(
                  title: const Text('Modifier la séance'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ⏱️ Durée
                      ListTile(
                        title: Text(
                          selectedTime != null
                              ? 'Durée: ${selectedTime!.hour}h ${selectedTime!
                              .minute}min'
                              : 'Choisir une durée',
                        ),
                        trailing: const Icon(Icons.timer),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ??
                                const TimeOfDay(hour: 1, minute: 0),
                          );

                          if (picked != null) {
                            setState(() => selectedTime = picked);
                          }
                        },

                      ),

                      // 🔥 Calories
                      TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories brûlées (kcal)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Exercice>(
                        isExpanded: true,
                        hint: const Text('Choisir un exercice'),
                        value: selectedExercice,
                        items: allExercices.map((e) {
                          final alreadyAdded =
                          exercices.any((ex) => ex.id == e.id);

                          return DropdownMenuItem<Exercice>(
                            value: e,
                            enabled: !alreadyAdded, // bloque doublons
                            child: Text(
                              alreadyAdded ? '${e.titre} (déjà ajouté)' : e.titre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedExercice = value);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Exercice',
                        ),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (selectedTime != null) {
                            final dureeString = '${selectedTime!
                                .hour
                                .toString()
                                .padLeft(2, '0')}:${selectedTime!.minute
                                .toString().padLeft(2, '0')}:00';
                            widget.seance.duree = dureeString;
                          }
                          widget.seance.caloriesBrulees = int.tryParse(
                              caloriesController.text) ?? 0;
                        });

                        if(selectedExercice != null ){
                          exercices.add(selectedExercice!);
                          _saveOrder();
                        }

                        widget.seance.save(); // Hive ou DB
                        Navigator.pop(context);
                      },
                      child: const Text('Valider'),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

}
