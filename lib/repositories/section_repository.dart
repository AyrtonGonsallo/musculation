import 'package:hive/hive.dart';
import '../models/section.dart';

class SectionRepository {
  static Box<Section> get _box => Hive.box<Section>('sections');

  static List<Section> getAll() => _box.values.toList();

  static void add(String titre) {
    _box.add(
      Section(
        id: DateTime.now().millisecondsSinceEpoch,
        titre: titre,
      ),
    );
  }

  static void delete(Section section) {
    section.delete();
  }
}
