import 'package:hive/hive.dart';
import '../models/seance.dart';

class SeanceRepository {
  static const String boxName = 'seances';

  Future<Box<Seance>> _openBox() async {
    return await Hive.openBox<Seance>(boxName);
  }

  Future<List<Seance>> getAll() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> add(Seance seance) async {
    final box = await _openBox();
    await box.add( seance);
  }

  /// Ajouter ou remplacer la séance
  Future<void> put(Seance seance) async {
    final box = await _openBox();

    await seance.save();
  }

  Future<void> delete(Seance seance) async {
    await seance.delete();
  }
}
