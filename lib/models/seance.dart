import 'package:hive/hive.dart';
import 'exercice.dart';

part 'seance.g.dart';

@HiveType(typeId: 3) // ⚠️ typeId unique
class Seance extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String jour;

  @HiveField(2)
  int duree;

  @HiveField(3)
  int caloriesBrulees;

  // 👇 liste ORDONNÉE (parfait pour drag & drop)
  @HiveField(4)
  List<Exercice> exercices;

  Seance({
    required this.id,
    required this.jour,
    required this.duree,
    required this.caloriesBrulees,
    required this.exercices,
  });
}
