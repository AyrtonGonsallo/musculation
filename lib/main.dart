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
             DrawerHeader(
              decoration: const BoxDecoration(
              color: Colors.brown,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The Gym Rat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              leading: const Icon(Icons.person_add),
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
              leading: const Icon(Icons.query_stats),
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

      body: HomeScreen(),


    );

  }
}



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Gym Rat'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _HomeBox(
              title: 'Exercices',
              imagePath: 'assets/images/exercice.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExercicesScreen(),
                  ),
                );
              },
            ),
            _HomeBox(
              title: 'Parties',
              imagePath: 'assets/images/parties.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PartiesScreen(),
                  ),
                );
              },
            ),
            _HomeBox(
              title: 'Séances',
              imagePath: 'assets/images/seances.png',
              onTap: () {
                // Navigator.push(...)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SeancesScreen(),
                  ),
                );
              },
            ),
            _HomeBox(
              title: 'Sections',
              imagePath: 'assets/images/sections.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SectionsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBox extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _HomeBox({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


