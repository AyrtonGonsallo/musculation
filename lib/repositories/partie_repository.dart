import 'package:hive/hive.dart';
import '../models/partie.dart';

class PartieRepository {
  static Box<Partie> get _box => Hive.box<Partie>('parties');

  static List<Partie> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) =>
        a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));
    return list;
  }



  static void add(String titre) {
    _box.add(
      Partie(
        id: DateTime.now().millisecondsSinceEpoch.remainder(0xFFFFFFFF),
        titre: titre,
      ),
    );
  }

  static void delete(Partie partie) {
    partie.delete();
  }
}
