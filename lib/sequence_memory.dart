import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SequenceMemoryTestScreen extends StatefulWidget {
  @override
  _SequenceMemoryTestScreenState createState() =>
      _SequenceMemoryTestScreenState();

  static List<double> results = [];

  const SequenceMemoryTestScreen({super.key});

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults =
        prefs.getStringList('sequence_memory_test_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('sequence_memory_test_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sequence_memory_test_results');
    results.clear();
  }
}

class _SequenceMemoryTestScreenState extends State<SequenceMemoryTestScreen> {
  final List<int> _sequence = [];
  final List<int> _userInput = [];
  int _currentStep = -1;
  bool _isShowingSequence = true;
  bool _testEnded = false;
  bool _testStarted = false;
  int _score = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    SequenceMemoryTestScreen.loadResults();
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _testEnded = false;
      _sequence.clear();
      _userInput.clear();
      _currentStep = -1;
      _score = 0;
      _addNextToSequence();
    });
  }

  void _addNextToSequence() {
    _sequence.add(_random.nextInt(9));
    _showSequence();
  }

  Future<void> _showSequence() async {
    setState(() {
      _isShowingSequence = true;
    });

    for (int index in _sequence) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _currentStep = index;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _currentStep = -1;
      });
    }

    setState(() {
      _isShowingSequence = false;
      _currentStep = -1;
      _userInput.clear();
    });
  }

  void _onSquareTapped(int index) async {
    if (_isShowingSequence || _testEnded) return;

    setState(() {
      _currentStep = index;
    });
    await Future.delayed(const Duration(milliseconds: 250));
    setState(() {
      _currentStep = -1;
    });

    setState(() {
      _userInput.add(index);
    });

    if (_userInput[_userInput.length - 1] != _sequence[_userInput.length - 1]) {
      _endTest();
    } else if (_userInput.length == _sequence.length) {
      _score++;
      _addNextToSequence();
    }
  }

  void _endTest() async {
    setState(() {
      _testEnded = true;
      _testStarted = false;
    });

    SequenceMemoryTestScreen.results.add(_score.toDouble());
    await SequenceMemoryTestScreen.saveResults();
  }

  Widget _buildSquare(int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isHighlighted = index == _currentStep;

    return GestureDetector(
      onTap: () => _onSquareTapped(index),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? LinearGradient(
                  colors: isDarkMode
                      ? [
                          Color.fromARGB(255, 255, 255, 255),
                          const Color.fromARGB(255, 202, 202, 202)
                        ]
                      : [Color.fromARGB(255, 68, 218, 255), Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey[700]!, Colors.grey[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isHighlighted
                  ? Colors.white.withOpacity(0.7)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    final lastScore = SequenceMemoryTestScreen.results.isNotEmpty
        ? 'Latest Score: ${SequenceMemoryTestScreen.results.last.toStringAsFixed(0)}'
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Sequence Memory Test!',
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
                'Tap the squares in the order they light up. The sequence will get longer with each success.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sequence Memory',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: _testStarted ? _buildTestUI() : _buildStartScreen(),
      ),
    );
  }

  Widget _buildTestUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              "Current Sequence Length: $_score",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 340,
            height: 340,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(9, (index) => _buildSquare(index)),
            ),
          ),
          const SizedBox(height: 20),
          if (_testEnded) ...[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Test Ended. You reached a sequence of $_score.",
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _testEnded = false;
                  _startTest();
                });
              },
              child: const Text("Restart Test"),
            ),
          ]
        ],
      ),
    );
  }
}
