import 'package:hive/hive.dart';
import '../models/exercice.dart';

class ExerciceRepository {
  static Box<Exercice> get _box => Hive.box<Exercice>('exercices');

  static List<Exercice> getAll() => _box.values.toList();

  static void add(Exercice exercice) {
    _box.add(exercice);
  }

  static void delete(Exercice exercice) {
    exercice.delete();
  }
}
