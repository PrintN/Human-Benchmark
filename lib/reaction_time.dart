import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ReactionTimeScreen extends StatefulWidget {
  const ReactionTimeScreen({super.key});

  static List<double> results = [];

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('reaction_time_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('reaction_time_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reaction_time_results');
    results.clear();
  }

  @override
  _ReactionTimeScreenState createState() => _ReactionTimeScreenState();
}

class _ReactionTimeScreenState extends State<ReactionTimeScreen> {
  bool _started = false;
  bool _waitingForGreen = false;
  bool _tooSoon = false;
  late Stopwatch _stopwatch;
  Color _screenColor = Colors.blue;
  String _displayText = 'Click to start';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    ReactionTimeScreen.loadResults().then((_) {
      setState(() {
        if (ReactionTimeScreen.results.isNotEmpty) {
          _displayText =
              'Last Reaction Time: ${ReactionTimeScreen.results.first.toStringAsFixed(2)} ms';
        }
      });
    });
  }

  void _startTest() {
    _stopwatch.reset();
    _timer?.cancel();

    setState(() {
      _started = true;
      _waitingForGreen = true;
      _tooSoon = false;
      _screenColor = Colors.red;
      _displayText = 'Wait for green';
    });

    _timer = Timer(
        Duration(
            seconds: 2 +
                5 * (DateTime.now().millisecondsSinceEpoch % 5) ~/ 1000), () {
      if (_waitingForGreen) {
        setState(() {
          _screenColor = Colors.green;
          _stopwatch.start();
          _displayText = 'Click!';
        });
      }
    });
  }

  void _handleTap() {
    if (!_started) {
      return;
    }

    if (_waitingForGreen && _screenColor == Colors.red) {
      setState(() {
        _tooSoon = true;
        _screenColor = Colors.blue;
        _waitingForGreen = false;
        _displayText = 'Oops! You clicked too soon.';
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _started = false;
          _tooSoon = false;
          _displayText = 'Click to start';
        });
      });
    } else if (_screenColor == Colors.green) {
      _stopwatch.stop();
      final reactionTime = _stopwatch.elapsedMilliseconds.toDouble();

      ReactionTimeScreen.results.insert(0, reactionTime);
      ReactionTimeScreen.saveResults();

      setState(() {
        _started = false;
        _waitingForGreen = false;
        _screenColor = Colors.blue;
        // Update display text with the new latest time
        _displayText = ReactionTimeScreen.results.isNotEmpty
            ? 'Latest Time: ${ReactionTimeScreen.results.first.toStringAsFixed(2)} ms'
            : 'No previous results';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reaction Time',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: _started
          ? GestureDetector(
              onTap: _handleTap,
              child: Container(
                color: _screenColor,
                child: Center(
                  child: Text(
                    _displayText,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          : _buildStartScreen(context),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
                colors: [
                  Color.fromARGB(255, 3, 3, 3),
                  Color.fromARGB(255, 20, 20, 20)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF004D99), Color(0xFF0073E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Reaction Time Test!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black26,
                      offset: Offset(3.0, 3.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'This test measures your reaction speed to color changes. Tap as soon as the screen turns green. Tapping too early will restart the test. Aim for your fastest time!',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                ReactionTimeScreen.results.isNotEmpty
                    ? 'Last Reaction Time: ${ReactionTimeScreen.results.first.toStringAsFixed(2)} ms'
                    : 'No previous results',
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 16.0),
                  backgroundColor: isDarkMode
                      ? const Color.fromARGB(255, 24, 24, 24)
                      : const Color(0xFF004D99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black26,
                ),
                child: const Text(
                  'Start Test',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
