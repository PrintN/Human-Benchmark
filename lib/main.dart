import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'statistics.dart';
import 'faq.dart';

import 'reaction_time.dart';
import 'typing.dart';
import 'chimp.dart';
import 'number_memory.dart';
import 'hearing.dart';
import 'verbal_memory.dart';
import 'sequence_memory.dart';
import 'visual_memory.dart';
import 'aim_trainer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Human Benchmark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004D99),
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.black26,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF004D99),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = true; 

  @override
  void initState() {
    super.initState();
    _loadLayoutPreference();
  }

  Future<void> _loadLayoutPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = prefs.getBool('isGridView') ?? true; 
    });
  }

  Future<void> _saveLayoutPreference(bool isGridView) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isGridView', isGridView);
  }

  void _onButtonClick(Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        title: const Padding(
          padding: EdgeInsets.only(top: 1.0),
          child: Text(
            'Human Benchmark',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: IconButton(
              icon: Icon(_isGridView ? Icons.dashboard : Icons.list),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
                _saveLayoutPreference(_isGridView);
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004D99), Color(0xFF0073E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/human-benchmark-no-background.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF004D99)),
              title: const Text('Human Benchmark'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF004D99)),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Color(0xFF004D99)),
              title: const Text('FAQ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isGridView ? _buildGridView() : _buildListView(),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: [
        _buildGridButton(
          context,
          'Reaction Time',
          Icons.timer,
          const ReactionTimeScreen(),
        ),
        _buildGridButton(
          context,
          'Typing',
          Icons.keyboard,
          const TypingScreen(),
        ),
        _buildGridButton(
          context,
          'Chimp Test',
          Icons.pets,
          const ChimpScreen(),
        ),
        _buildGridButton(
          context,
          'Number Memory',
          Icons.format_list_numbered_sharp,
          const NumberMemoryScreen(),
        ),
        _buildGridButton(
          context,
          'Hearing Test',
          Icons.hearing,
          const HearingTestScreen(),
        ),
        _buildGridButton(
          context,
          'Verbal Memory',
          Icons.abc,
          const VerbalMemoryTestScreen(),
        ),
        _buildGridButton(
          context,
          'Sequence Memory',
          Icons.grid_on,
          const SequenceMemoryTestScreen(),
        ),
        _buildGridButton(
          context,
          'Visual Memory',
          Icons.visibility,
          const VisualMemoryTestScreen(),
        ),
        _buildGridButton(
          context,
          'Aim Trainer',
          Icons.ads_click,
          const AimTrainerScreen(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildListButton(
          context,
          'Reaction Time',
          Icons.timer,
          const ReactionTimeScreen(),
        ),
        _buildListButton(
          context,
          'Typing',
          Icons.keyboard,
          const TypingScreen(),
        ),
        _buildListButton(
          context,
          'Chimp Test',
          Icons.pets,
          const ChimpScreen(),
        ),
        _buildListButton(
          context,
          'Number Memory',
          Icons.format_list_numbered,
          const NumberMemoryScreen(),
        ),
        _buildListButton(
          context,
          'Hearing Test',
          Icons.hearing,
          const HearingTestScreen(),
        ),
        _buildListButton(
          context,
          'Verbal Memory',
          Icons.abc,
          const VerbalMemoryTestScreen(),
        ),
        _buildListButton(
          context,
          'Sequence Memory',
          Icons.grid_on,
          const SequenceMemoryTestScreen(),
        ),
        _buildListButton(
          context,
          'Visual Memory',
          Icons.visibility,
          const VisualMemoryTestScreen(),
        ),
        _buildListButton(
          context,
          'Aim Trainer',
          Icons.ads_click,
          const AimTrainerScreen(),
        ),
      ],
    );
  }

  Widget _buildGridButton(BuildContext context, String title, IconData icon, Widget destination) {
    return GestureDetector(
      onTap: () => _onButtonClick(destination),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF004D99), Color(0xFF0073E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50.0, color: Colors.white),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListButton(BuildContext context, String title, IconData icon, Widget destination) {
    return ListTile(
      leading: Icon(icon, size: 50.0, color: const Color(0xFF004D99)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20.0, color: Color(0xFF004D99), fontWeight: FontWeight.w500),
      ),
      onTap: () => _onButtonClick(destination),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF004D99)),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    );
  }
}