import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChimpScreen extends StatefulWidget {
  const ChimpScreen({super.key});

  static List<int> results = [];

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('chimp_test_results') ?? [];
    results = savedResults.map((e) => int.tryParse(e) ?? 0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('chimp_test_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chimp_test_results');
    results.clear();
  }

  @override
  _ChimpScreenState createState() => _ChimpScreenState();
}

class _ChimpScreenState extends State<ChimpScreen> {
  bool _testStarted = false;
  bool _testEnded = false;
  int _score = 0;
  List<int> _sequence = [];
  List<int> _displaySequence = [];
  int _numberCount = 4;
  bool _showingNumbers = true;
  int _expectedNumber = 1;
  final Random _random = Random();
  final List<Offset> _positions = [];

  @override
  void initState() {
    super.initState();
    ChimpScreen.loadResults();
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _testEnded = false;
      _score = 0;
      _numberCount = 4;
      _expectedNumber = 1;
    });

    _generateSequence();
    _generateNonOverlappingPositions();
    _showSequence();
  }

  void _endTest() {
    setState(() {
      _testStarted = false;
      _testEnded = true;
    });

    ChimpScreen.results.add(_score);
    ChimpScreen.saveResults();
  }

  void _generateSequence() {
    _sequence = List.generate(_numberCount, (index) => index + 1);
    _displaySequence = List.from(_sequence);
    _displaySequence.shuffle();
  }

  void _generateNonOverlappingPositions() {
    _positions.clear();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    const double boxSize = 100.0;

    for (int i = 0; i < _numberCount; i++) {
      Offset newPosition;
      bool hasOverlap;

      do {
        hasOverlap = false;
        double x = _random.nextDouble() * (screenWidth - boxSize);
        double y = _random.nextDouble() * (screenHeight - boxSize - 150);
        newPosition = Offset(x, y);

        for (final position in _positions) {
          if ((newPosition - position).distance < boxSize + 10) {
            hasOverlap = true;
            break;
          }
        }
      } while (hasOverlap);

      _positions.add(newPosition);
    }
  }

  void _showSequence() {
    setState(() {
      _showingNumbers = true;
    });
  }

  void _onNumberTap(int number) {
    if (_showingNumbers) {
      setState(() {
        _showingNumbers = false;
      });
    }

    if (number == _expectedNumber) {
      setState(() {
        _expectedNumber++;
        int index = _sequence.indexOf(number); 
        _sequence.removeAt(index); 
        _positions.removeAt(index); 
        if (_expectedNumber > _numberCount) {
          if (_score == 0) {
            _score = _numberCount; 
          } else {
            _score++; 
          }
          _numberCount++;
          _generateSequence();
          _generateNonOverlappingPositions();
          _expectedNumber = 1;
          _showSequence();
        }
      });
    } else {
      _endTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chimp Test', style: TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: _testStarted
          ? Stack(
              children: [
                if (!_testEnded)
                  ...List.generate(_sequence.length, (index) {
                    return Positioned(
                      left: _positions[index].dx,
                      top: _positions[index].dy,
                      child: GestureDetector(
                        onTap: () => _onNumberTap(_sequence[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _showingNumbers ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          height: 100,
                          width: 100,
                          child: Center(
                            child: Text(
                              _showingNumbers ? '${_sequence[index]}' : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                if (_testEnded)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Test Ended!',
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          'Your Score: $_score',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : _buildStartScreen(context),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    final lastScore = ChimpScreen.results.isNotEmpty
        ? 'Latest Score: ${ChimpScreen.results.last}'
        : 'No previous results';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
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
                'Welcome to the Chimp Test!',
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
                'In this test, click the numbers in ascending order as quickly as possible. The sequence will be briefly shown for you to recall.',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                lastScore,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  backgroundColor: const Color(0xFF004D99),
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