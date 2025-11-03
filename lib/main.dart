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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadTheme(),
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Human Benchmark',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// MARK: - Theme
class AppTheme {
  static final Color _primary = const Color(0xFF004D99);
  static final Color _secondary = const Color(0xFF0073E6);
  static final Color _lightBg = const Color(0xFFF5F5F5);
  static final Color _darkBg = Colors.black;

  static final ThemeData light = ThemeData.light().copyWith(
    primaryColor: _primary,
    scaffoldBackgroundColor: _lightBg,
    appBarTheme: AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: Colors.white,
    listTileTheme: ListTileThemeData(
      iconColor: _primary,
      textColor: Colors.black87,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: _primary,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
    ),
  );

  static final ThemeData dark = ThemeData.dark().copyWith(
    primaryColor: _darkBg,
    scaffoldBackgroundColor: _darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    cardColor: const Color.fromARGB(255, 30, 30, 30),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.white,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.white70,
    ),
  );
}

// MARK: - Theme Provider
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}

// MARK: - Test Item Model
class TestItem {
  final String title;
  final IconData icon;
  final Widget screen;

  const TestItem(this.title, this.icon, this.screen);
}

// MARK: - Test Data
final List<TestItem> tests = [
  TestItem('Reaction Time', Icons.timer, const ReactionTimeScreen()),
  TestItem('Typing Speed', Icons.keyboard, const TypingScreen()),
  TestItem('Chimp Test', Icons.pets, const ChimpScreen()),
  TestItem('Number Memory', Icons.format_list_numbered, const NumberMemoryScreen()),
  TestItem('Hearing Test', Icons.hearing, const HearingTestScreen()),
  TestItem('Verbal Memory', Icons.abc, const VerbalMemoryTestScreen()),
  TestItem('Sequence Memory', Icons.grid_on, const SequenceMemoryTestScreen()),
  TestItem('Visual Memory', Icons.visibility, const VisualMemoryTestScreen()),
  TestItem('Aim Trainer', Icons.ads_click, const AimTrainerScreen()),
  TestItem('Info Retention', Icons.menu_book_outlined, const InfoRetentionScreen()),
  TestItem('Intelligence Quotient', Icons.lightbulb, const IntelligenceQuotientScreen()),
  TestItem('Dual N-Back', Icons.tab, const DualNBackTestScreen()),
];

// MARK: - Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isGridView = prefs.getBool('isGridView') ?? true);
  }

  Future<void> _saveLayout(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', value);
  }

  void _toggleLayout() {
    setState(() {
      _isGridView = !_isGridView;
      _saveLayout(_isGridView);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final width = MediaQuery.of(context).size.width;
            return Text(
              'Human Benchmark',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: width > 400 ? 28 : 20,
                letterSpacing: 1.2,
              ),
            );
          },
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.dashboard : Icons.list),
            onPressed: _toggleLayout,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: _isGridView
            ? _GridViewTests(isDark: isDark)
            : _ListViewTests(isDark: isDark),
      ),
    );
  }
}

// MARK: - Grid View
class _GridViewTests extends StatelessWidget {
  final bool isDark;
  const _GridViewTests({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _GridTestButton(test: test, isDark: isDark);
      },
    );
  }
}

class _GridTestButton extends StatelessWidget {
  final TestItem test;
  final bool isDark;

  const _GridTestButton({required this.test, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => test.screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0C0C0C), const Color(0xFF171718)]
                : [const Color(0xFF004D99), const Color(0xFF0073E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(test.icon, size: 50, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              test.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - List View
class _ListViewTests extends StatelessWidget {
  final bool isDark;
  const _ListViewTests({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _ListTestButton(test: test, isDark: isDark);
      },
    );
  }
}

class _ListTestButton extends StatelessWidget {
  final TestItem test;
  final bool isDark;

  const _ListTestButton({required this.test, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : const Color(0xFF004D99);
    return Card(
      color: isDark ? const Color.fromARGB(255, 19, 18, 18) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0),
        ),
      ),
      child: ListTile(
        leading: Icon(test.icon, size: 50, color: color),
        title: Text(
          test.title,
          style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => test.screen),
        ),
      ),
    );
  }
}

// MARK: - Drawer
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF004D99);

    return Drawer(
      child: Container(
        color: isDark ? Colors.black : const Color(0xFFF5F5F5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: isDark
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF004D99), Color(0xFF0073E6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isDark ? Colors.black : null,
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
              leading: Icon(Icons.home, color: iconColor),
              title: const Text('Home'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: iconColor),
              title: const Text('Statistics'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.help, color: iconColor),
              title: const Text('FAQ'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FAQScreen()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.brightness_6, color: iconColor),
              title: const Text('Toggle Dark/Light Mode'),
              onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}