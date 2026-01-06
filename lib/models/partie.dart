import 'package:hive/hive.dart';

part 'partie.g.dart'; // 👈 ICI, juste après les imports

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
}
