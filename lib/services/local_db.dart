import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import '../models/section.dart';
import '../models/partie.dart';
import '../models/exercice.dart';
import '../models/seance.dart';

class DatabaseExportService {
  static Future<void> exportDatabase(BuildContext context) async {
    // 📁 Choix du dossier
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choisir le dossier de sauvegarde',
    );

    if (directoryPath == null) return;

    // 📦 Boxes
    final sectionBox = Hive.box<Section>('sections');
    final partieBox = Hive.box<Partie>('parties');
    final exerciceBox = Hive.box<Exercice>('exercices');
    final seanceBox = Hive.box<Seance>('seances');

    // 🧱 Données
    final data = {
      'sections': sectionBox.values.map((s) => s.toJson()).toList(),
      'parties': partieBox.values.map((p) => p.toJson()).toList(),
      'exercices': exerciceBox.values.map((e) => e.toJson()).toList(),
      'seances': seanceBox.values.map((s) => s.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final filePath = p.join(directoryPath, 'backup_musculation.json');
    final file = File(filePath);

    await file.writeAsString(jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export réussi : $filePath')),
    );
  }
}

class DatabaseImportService {
  static Future<void> importDatabase(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Importer une sauvegarde',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(jsonString);

    final sectionBox = Hive.box<Section>('sections');
    final partieBox = Hive.box<Partie>('parties');
    final exerciceBox = Hive.box<Exercice>('exercices');
    final seanceBox = Hive.box<Seance>('seances');

    // ⚠️ VIDER AVANT IMPORT
    await sectionBox.clear();
    await partieBox.clear();
    await exerciceBox.clear();
    await seanceBox.clear();

    // 📥 ORDRE IMPORTANT
    for (final s in data['sections']) {
      final section = Section.fromJson(s);
      await sectionBox.put(section.id, section);
    }

    for (final p in data['parties']) {
      final partie = Partie.fromJson(p);
      await partieBox.put(partie.id, partie);
    }

    for (final e in data['exercices']) {
      final exercice = Exercice.fromJson(e);
      await exerciceBox.put(exercice.id, exercice);
    }

    for (final s in data['seances']) {
      final seance = Seance.fromJson(s);
      await seanceBox.put(seance.id, seance);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import terminé avec succès')),
    );
  }
}
