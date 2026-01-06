import 'package:hive/hive.dart';
import 'partie.dart';
import 'section.dart';

part 'exercice.g.dart';

@HiveType(typeId: 2) // ⚠️ typeId unique
class Exercice extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String titre;

  @HiveField(2)
  String gif;

  @HiveField(3)
  String lienVideo;

  @HiveField(4)
  String categorie;

  // 🔗 Liens vers Section & Partie par ID
  @HiveField(5)
  int sectionId;

  @HiveField(6)
  int partieId;

  @HiveField(7)
  String conseils;

  @HiveField(8)
  String gif_local;

  Exercice({
    required this.id,
    required this.titre,
    required this.gif,
    required this.lienVideo,
    required this.categorie,
    required this.sectionId,
    required this.partieId,
    required this.conseils,
    required this.gif_local,
  });

  // =========================
  // 🔁 JSON EXPORT / IMPORT
  // =========================

  /// Export pour sauvegarde / partage / backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'gif': gif,
    'gif_local': gif_local,
    'lienVideo': lienVideo,
    'categorie': categorie,
    'sectionId': sectionId,
    'partieId': partieId,
    'conseils': conseils,
  };

  /// Import depuis JSON
  factory Exercice.fromJson(Map<String, dynamic> json) {
    return Exercice(
      id: json['id'],
      titre: json['titre'],
      gif: json['gif'] ?? '',
      lienVideo: json['lienVideo'] ?? '',
      categorie: json['categorie'] ?? '',
      sectionId: json['sectionId'],
      partieId: json['partieId'],
      conseils: json['conseils'] ?? '',
      gif_local: json['gif_local'] ?? '',
    );
  }

  // =========================
  // 🔗 ACCESSEURS RELATIONNELS
  // =========================

  Section? get section {
    final box = Hive.box<Section>('sections');
    return box.values.firstWhere(
          (s) => s.id == sectionId,
      orElse: () => Section(id: 0, titre: 'Non défini'),
    );
  }

  Partie? get partie {
    final box = Hive.box<Partie>('parties');
    return box.values.firstWhere(
          (p) => p.id == partieId,
      orElse: () => Partie(id: 0, titre: 'Non défini'),
    );
  }
}
