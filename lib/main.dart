import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:musculation/models/partie.dart';
import 'package:musculation/screens/exercices/exercices_screen.dart';
import 'package:musculation/screens/parametres/parametres_screen.dart';
import 'package:musculation/screens/parties/parties_screen.dart';
import 'package:musculation/screens/seances/seances_screen.dart';
import 'package:musculation/screens/sections/sections_screen.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:musculation/screens/stats/stats_screen.dart';

import 'models/exercice.dart';
import 'models/seance.dart';
import 'models/section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // 🔴 REGISTER AVANT openBox
  Hive.registerAdapter(SectionAdapter());
  Hive.registerAdapter(PartieAdapter());
  Hive.registerAdapter(ExerciceAdapter());
  Hive.registerAdapter(SeanceAdapter());

  // 🔴 OUVERTURE AVANT runApp
  await Hive.openBox<Section>('sections');
  await Hive.openBox<Partie>('parties');
  await Hive.openBox<Exercice>('exercices');
  await Hive.openBox<Seance>('seances');

  initializeDateFormatting('fr_FR', null).then((_) => runApp(const MyApp()));



}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musculation',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      home: const MyHomePage(title: 'The gym rat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      // 👇 MENU LATERAL
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Text(
                'The gym rat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Sections'),
              onTap: () {
                Navigator.pop(context); // ferme le menu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SectionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Parties'),
              onTap: () {
                Navigator.pop(context); // ferme le menu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PartiesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Exercices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExercicesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Séances'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SeancesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Parametres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ParametresScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Statistiques'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StatsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: NumberList(),


    );

  }
}


class NumberItem {
  final int id;
  NumberItem(this.id);
}

class NumberList extends StatefulWidget {
  const NumberList({super.key});

  @override
  State<NumberList> createState() => _NumberListState();
}

class _NumberListState extends State<NumberList> {
  // liste d'exemple
  List<NumberItem> numbers = List.generate(10, (index) => NumberItem(index + 1));

  @override
  Widget build(BuildContext context) {
    return AnimatedReorderableListView<NumberItem>(
      items: numbers,
      // animation à l'insertion
      enterTransition: [SlideInDown()],
      // animation à la suppression
      exitTransition: [SlideInUp()],
      // delay avant drag pour tester
      dragStartDelay: const Duration(milliseconds: 200),
      // pour savoir si 2 items sont identiques
      isSameItem: (a, b) => a.id == b.id,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          final item = numbers.removeAt(oldIndex);
          numbers.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final item = numbers[index];
        return Card(
          key: ValueKey(item.id),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Item ${item.id}'),
            trailing: const Icon(Icons.drag_handle),
          ),
        );
      },
    );
  }
}
