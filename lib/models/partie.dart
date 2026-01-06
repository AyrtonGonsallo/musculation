import 'package:hive/hive.dart';

part 'partie.g.dart';

@HiveType(typeId: 1)
class Partie extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String titre;

  Partie({
    required this.id,
    required this.titre,
  });

  // =========================
  // 🔁 JSON EXPORT / IMPORT
  // =========================

  /// Export pour sauvegarde / backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
  };

  /// Import depuis JSON
  factory Partie.fromJson(Map<String, dynamic> json) {
    return Partie(
      id: json['id'],
      titre: json['titre'],
    );
  }
}
