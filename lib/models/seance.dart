import 'package:hive/hive.dart';
import 'exercice.dart';

part 'seance.g.dart';

@HiveType(typeId: 4)
class Seance extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime jour; // date complète

  @HiveField(2)
  String duree; // hh:mm:ss

  @HiveField(3)
  int caloriesBrulees;

  @HiveField(4)
  List<Exercice> exercices;



  Seance({
    required this.id,
    required this.jour,
    required this.duree,
    required this.caloriesBrulees,
    required this.exercices,
  });

  // =========================
  // 🔁 JSON EXPORT / IMPORT
  // =========================

  /// Export pour sauvegarde
  Map<String, dynamic> toJson() => {
    'id': id,
    'jour': jour.toIso8601String(),
    'duree': duree,
    'caloriesBrulees': caloriesBrulees,
    'exercices': exercices.map((e) => e.toJson()).toList(),
  };

  /// Import depuis JSON
  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['id'],
      jour: DateTime.parse(json['jour']),
      duree: json['duree'],
      caloriesBrulees: json['caloriesBrulees'],
      exercices: (json['exercices'] as List)
          .map((e) => Exercice.fromJson(e))
          .toList(),
    );
  }
}
