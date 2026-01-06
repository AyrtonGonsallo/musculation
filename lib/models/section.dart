import 'package:hive/hive.dart';

part 'section.g.dart'; // 👈 après les imports

@HiveType(typeId: 0)
class Section extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String titre;

  Section({
    required this.id,
    required this.titre,
  });

  // =========================
  // 🔁 JSON EXPORT / IMPORT
  // =========================

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
  };

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      titre: json['titre'],
    );
  }
}
