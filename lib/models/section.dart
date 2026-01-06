import 'package:hive/hive.dart';

part 'section.g.dart'; // 👈 ICI, juste après les imports

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
}
