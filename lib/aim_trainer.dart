import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AimTrainerScreen extends StatefulWidget {
  @override
  _AimTrainerScreenState createState() => _AimTrainerScreenState();

  static List<double> results = [];

  const AimTrainerScreen({super.key});

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('aim_trainer_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('aim_trainer_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('aim_trainer_results');
    results.clear();
  }
}

class _AimTrainerScreenState extends State<AimTrainerScreen> {
  final Random _random = Random();
  final int _targetCount = 30;
  int _hits = 0;
  int _remainingTargets = 30;
  final List<int> _hitTimes = [];
  bool _testStarted = false;
  bool _testEnded = false;
  int _startTime = 0;
  Offset? _targetPosition;
  final double _targetSize = 80.0;
  bool _targetVisible = false;

  @override
  void initState() {
    super.initState();
    AimTrainerScreen.loadResults();
  }

  void _startTest() {
    setState(() {
      _hits = 0;
      _remainingTargets = _targetCount;
      _hitTimes.clear();
      _testStarted = true;
      _testEnded = false;
      _startTime = DateTime.now().millisecondsSinceEpoch;
      _showTarget();
    });
  }

  void _endTest() async {
    setState(() {
      _testEnded = true;
      _testStarted = false;
    });

    final averageTimeMs = _hitTimes.length >= 2
        ? _hitTimes
                .asMap()
                .entries
                .skip(1)
                .map((entry) => entry.value - _hitTimes[entry.key - 1])
                .reduce((a, b) => a + b) ~/
            (_hitTimes.length - 1)
        : 0;

    AimTrainerScreen.results.add(averageTimeMs.toDouble());
    await AimTrainerScreen.saveResults();
  }

  void _onTargetHit() {
    if (!_testStarted || _testEnded) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    _hitTimes.add(currentTime);

    setState(() {
      _hits++;
      _remainingTargets--;
      _targetVisible = false;
    });

    if (_hits >= _targetCount) {
      _endTest();
    } else {
      _showTarget();
    }
  }

  void _showTarget() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double maxX = width - _targetSize - 20;
    final double maxY = height - _targetSize - 80;

    double targetX = _random.nextDouble() * maxX;
    double targetY = _random.nextDouble() * maxY;

    setState(() {
      _targetPosition = Offset(targetX, targetY);
      _targetVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aim Trainer',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: _testStarted ? _buildTestUI() : _buildStartScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    final lastResult = AimTrainerScreen.results.isNotEmpty
        ? 'Latest Time: ${AimTrainerScreen.results.last.toStringAsFixed(2)} ms'
        : 'No previous results';

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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Aim Trainer!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black38,
                      offset: Offset(3.0, 3.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Click on the targets as they appear. Hit 30 targets quickly; your average click time will be recorded.',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                lastResult,
                style: const TextStyle(fontSize: 20, color: Colors.white),
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
                  elevation: 12,
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

  Widget _buildTestUI() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Targets Left: $_remainingTargets',
              style: TextStyle(
                  fontSize: 24,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_targetVisible && _targetPosition != null) ...[
          Positioned(
            left: _targetPosition!.dx,
            top: _targetPosition!.dy,
            child: GestureDetector(
              onTap: _onTargetHit,
              child: Container(
                width: _targetSize,
                height: _targetSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode
                      ? Color.fromARGB(255, 83, 83, 83)
                      : Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/target.webp',
                    width: _targetSize,
                    height: _targetSize,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_testEnded) ...[
          Positioned(
            bottom: 60,
            left: 50,
            child: Text(
              "Test Ended. Avg Time: ${AimTrainerScreen.results.last.toStringAsFixed(2)} ms",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 50,
            child: ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 16.0),
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 12,
                shadowColor: Colors.black26,
              ),
              child: const Text("Restart Test", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ],
    );
  }
}
