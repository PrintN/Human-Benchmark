import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
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
import 'info_retention.dart';
import 'intelligence_quotient.dart';
import 'dual_n-back.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Human Benchmark',
            theme: themeProvider.isDarkMode
                ? ThemeData.dark().copyWith(
                    primaryColor: Colors.black,
                    scaffoldBackgroundColor: Colors.black,
                    appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(color: Colors.white),
                    ),
                    buttonTheme: const ButtonThemeData(
                      buttonColor: Colors.white,
                      textTheme: ButtonTextTheme.primary,
                    ),
                    cardColor: Colors.black,
                    listTileTheme: const ListTileThemeData(
                      iconColor: Colors.white,
                      textColor: Colors.white,
                    ),
                  )
                : ThemeData.light().copyWith(
                    primaryColor: const Color(0xFF004D99),
                    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Color(0xFF004D99),
                      foregroundColor: Colors.white,
                    ),
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(color: Colors.black),
                    ),
                    buttonTheme: const ButtonThemeData(
                      buttonColor: Color(0xFF004D99),
                      textTheme: ButtonTextTheme.primary,
                    ),
                    cardColor: Colors.white,
                    listTileTheme: const ListTileThemeData(
                      iconColor: Color(0xFF004D99),
                      textColor: Colors.black,
                    ),
                  ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
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
        title: Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final fontSize = screenWidth > 400 ? 28.0 : 20.0;
              return Text(
                'Human Benchmark',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  letterSpacing: 1.2,
                ),
              );
            },
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
                ));
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
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            bool isDarkMode = themeProvider.isDarkMode;

            return Container(
              color: isDarkMode
                  ? Colors.black
                  : const Color(
                      0xFFF5F5F5), // Apply background color to the entire drawer
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF004D99), Color(0xFF0073E6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isDarkMode ? Colors.black : null,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/human-benchmark-no-background.webp',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: isDarkMode ? Colors.white : Color(0xFF004D99),
                    ),
                    title: const Text('Human Benchmark'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.bar_chart,
                      color: isDarkMode ? Colors.white : Color(0xFF004D99),
                    ),
                    title: const Text('Statistics'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StatisticsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.help,
                      color: isDarkMode ? Colors.white : Color(0xFF004D99),
                    ),
                    title: const Text('FAQ'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FAQScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.brightness_6,
                      color: isDarkMode ? Colors.white : Color(0xFF004D99),
                    ),
                    title: const Text('Toggle Dark/Light Mode'),
                    onTap: () {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                ],
              ),
            );
          },
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
          'Typing Speed',
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
        _buildGridButton(
          context,
          'Info Retention',
          Icons.menu_book_outlined,
          const InfoRetentionScreen(),
        ),
        _buildGridButton(
          context,
          'Intelligence Quotient',
          Icons.lightbulb,
          const IntelligenceQuotientScreen(),
        ),
        _buildGridButton(
          context,
          'Dual N-Back',
          Icons.tab,
          const DualNBackTestScreen(),
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
          'Typing Speed',
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
        _buildListButton(
          context,
          'Info Retention',
          Icons.menu_book_outlined,
          const InfoRetentionScreen(),
        ),
        _buildListButton(
          context,
          'Intelligence Quotient',
          Icons.lightbulb,
          const IntelligenceQuotientScreen(),
        ),
        _buildListButton(
          context,
          'Dual N-Back',
          Icons.tab,
          const DualNBackTestScreen(),
        ),
      ],
    );
  }

  Widget _buildGridButton(
      BuildContext context, String title, IconData icon, Widget destination) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onButtonClick(destination),
      child: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 12, 12, 12),
                    Color.fromARGB(255, 23, 23, 24)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
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
            Icon(
              icon,
              size: 50.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListButton(
      BuildContext context, String title, IconData icon, Widget destination) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon,
          size: 50.0,
          color: isDarkMode ? Colors.white : const Color(0xFF004D99)),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 20.0,
            color: isDarkMode ? Colors.white : const Color(0xFF004D99),
            fontWeight: FontWeight.w500),
      ),
      onTap: () => _onButtonClick(destination),
      trailing: Icon(Icons.arrow_forward_ios,
          color: isDarkMode ? Colors.white : const Color(0xFF004D99)),
      tileColor:
          isDarkMode ? const Color.fromARGB(255, 19, 18, 18) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : const Color(0xFFE0E0E0)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    );
  }
}
