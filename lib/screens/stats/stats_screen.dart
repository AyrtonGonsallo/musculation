import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../models/seance.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Seance> seances = [];

  @override
  void initState() {
    super.initState();
    final box = Hive.box<Seance>('seances');
    seances = box.values.toList();
    // Tri chronologique
    seances.sort((a, b) => a.jour.compareTo(b.jour));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Statistiques')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Évolution des calories par séance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 200, child: CaloriesChart()),

            const SizedBox(height: 32),

            const Text('Nombre de séances par semaine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 200, child: SeancesParSemaineChart()),
          ],
        ),
      ),
    );
  }
}

// -----------------------------
// Graphique Calories par séance
// -----------------------------
class CaloriesChart extends StatelessWidget {
  const CaloriesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final seances = Hive.box<Seance>('seances').values.toList()
      ..sort((a, b) => a.jour.compareTo(b.jour));

    final spots = List.generate(
      seances.length,
          (i) => FlSpot(i.toDouble(), seances[i].caloriesBrulees.toDouble()),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= seances.length) return const SizedBox();
                final date = seances[index].jour;
                return Text('${date.day}/${date.month}');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

// -----------------------------
// Graphique Nombre de séances par semaine
// -----------------------------
class SeancesParSemaineChart extends StatelessWidget {
  const SeancesParSemaineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final seances = Hive.box<Seance>('seances').values.toList();

    // Compte le nombre de séances par semaine
    Map<String, int> counts = {};
    for (var s in seances) {
      // clé = année + numéro de semaine
      final week = weekNumber(s.jour);
      final key = '${s.jour.year}-W$week';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final keys = counts.keys.toList()..sort();

    final spots = List.generate(
      keys.length,
          (i) => FlSpot(i.toDouble(), counts[keys[i]]!.toDouble()),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= keys.length) return const SizedBox();
                return Text(keys[index].replaceAll('W', ' S'));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.green,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  // Fonction pour obtenir le numéro de semaine ISO
  int weekNumber(DateTime date) {
    final dayOfYear = int.parse(
        DateFormat("D").format(date)); // attention: nécessite intl
    final w = ((dayOfYear - date.weekday + 10) / 7).floor();
    return w;
  }
}
