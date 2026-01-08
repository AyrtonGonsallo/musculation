import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musculation/screens/seances/seance_detail_screen.dart';

import '../../models/exercice.dart';
import '../../models/seance.dart';
import '../../repositories/exercice_repository.dart';
import '../../repositories/seance_repository.dart';

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  final SeanceRepository seanceRepo = SeanceRepository();
  final ExerciceRepository exerciceRepo = ExerciceRepository();

  List<Seance> seances = [];
  List<Exercice> allExercices = [];
  final DateFormat dateFormat = DateFormat("EEEE d MMMM yyyy", "fr_FR");

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController caloriesController = TextEditingController();

  final Set<int> selectedExerciceIds = {};

  @override
  void initState() {
    super.initState();
    _loadSeances();
    _loadExercices();
  }

  Future<void> _loadSeances() async {
    final list = await seanceRepo.getAll();
    setState(() {
      seances = list;
    });
  }

  Future<void> _loadExercices() async {
    final list = await ExerciceRepository.getAll()..sort((a, b) =>
        a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));;
    setState(() {
      allExercices = list;
    });
  }

  Future<void> _addSeance() async {
    if (selectedDate == null || selectedTime == null || selectedExerciceIds.isEmpty) return;

    final dureeString = '${selectedTime!.hour.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')}:00';
    final seance = Seance(
      id: DateTime.now().millisecondsSinceEpoch.remainder(0xFFFFFFFF),
      jour: selectedDate!,
      duree: dureeString,
      caloriesBrulees: int.tryParse(caloriesController.text) ?? 0,
      exercices: allExercices.where((e) => selectedExerciceIds.contains(e.id)).toList(),
    );

    await seanceRepo.add(seance);
    _resetForm();
    await _loadSeances();
    Navigator.of(context).pop();
  }

  void _resetForm() {
    selectedDate = null;
    selectedTime = null;
    caloriesController.clear();
    selectedExerciceIds.clear();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text('Nouvelle séance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DatePicker
                ListTile(
                  title: Text(selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : 'Choisir le jour'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setStateDialog(() => selectedDate = picked);
                  },
                ),

                // TimePicker pour durée
                ListTile(
                  title: Text(selectedTime != null ? '${selectedTime!.hour.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')}' : 'Choisir durée'),
                  trailing: const Icon(Icons.timer),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 0, minute: 30),
                    );
                    if (picked != null) setStateDialog(() => selectedTime = picked);
                  },
                ),

                // Calories
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calories brûlées'),
                ),

                const SizedBox(height: 16),
                const Text('Exercices:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...allExercices.map((e) {
                  return CheckboxListTile(
                    title: Text(e.titre),
                    value: selectedExerciceIds.contains(e.id),
                    onChanged: (val) {
                      setStateDialog(() {
                        if (val == true) {
                          selectedExerciceIds.add(e.id);
                        } else {
                          selectedExerciceIds.remove(e.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  _resetForm();
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler')),
            ElevatedButton(onPressed: _addSeance, child: const Text('Ajouter')),
          ],
        );
      }),
    );
  }

  Future<void> _deleteSeance(Seance s) async {
    await seanceRepo.delete(s);
    await _loadSeances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Séances')),
      body: ListView.builder(
        itemCount: seances.length,
        itemBuilder: (_, i) {
          final s = seances[i];
          return ListTile(
            title: Text('${dateFormat.format(s.jour)} - ${s.duree}'),
            subtitle: Text('Calories: ${s.caloriesBrulees}, Exercices: ${s.exercices.length}'),
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
                        builder: (_) => SeanceDetailScreen(seance: s),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSeance(s),
                ),
              ],
            ),
            onTap: () {
              // Plus tard : détail séance ou drag & drop exercices
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
