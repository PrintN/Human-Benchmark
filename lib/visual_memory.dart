import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisualMemoryTestScreen extends StatefulWidget {
  @override
  _VisualMemoryTestScreenState createState() => _VisualMemoryTestScreenState();

  static List<double> results = [];

  const VisualMemoryTestScreen({super.key});

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults =
        prefs.getStringList('visual_memory_test_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('visual_memory_test_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('visual_memory_test_results');
    results.clear();
  }
}

class _VisualMemoryTestScreenState extends State<VisualMemoryTestScreen> {
  List<int> _litSquares = [];
  final Set<int> _userInput = {};
  final Set<int> _correctlyIdentified = {};
  int _boardSize = 3;
  bool _isShowingSquares = true;
  bool _testEnded = false;
  bool _testStarted = false;
  int _score = 0;
  Timer? _progressTimer;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    VisualMemoryTestScreen.loadResults();
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _testEnded = false;
      _litSquares.clear();
      _userInput.clear();
      _correctlyIdentified.clear();
      _isShowingSquares = true;
      _boardSize = 3;
      _score = 0;
      _progress = 1.0;
      _generateAndShowSquares();
    });
  }

  void _generateAndShowSquares() async {
    final allSquares = List.generate(_boardSize * _boardSize, (index) => index);
    allSquares.shuffle();

    final numSquaresToShow = min(_boardSize * _boardSize, _boardSize + 2);
    _litSquares = allSquares.take(numSquaresToShow).toList();

    setState(() {
      _isShowingSquares = true;
      _progress = 1.0;
    });

    _startProgressTimer();

    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _isShowingSquares = false;
    });

    _progressTimer?.cancel();
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progress = 1.0;

    const duration = Duration(seconds: 5);
    const interval = Duration(milliseconds: 50);

    _progressTimer = Timer.periodic(interval, (timer) {
      final elapsed = timer.tick * interval.inMilliseconds;
      final progressPercent = 1.0 - (elapsed / duration.inMilliseconds);

      if (progressPercent <= 0.0) {
        setState(() {
          _progress = 0.0;
        });
        timer.cancel();
        setState(() {
          _isShowingSquares = false;
        });
      } else {
        setState(() {
          _progress = progressPercent;
        });
      }
    });
  }

  void _onSquareTapped(int index) {
    if (_testEnded || _isShowingSquares) return;

    if (_litSquares.contains(index)) {
      setState(() {
        _userInput.add(index);
        _correctlyIdentified.add(index);
      });

      final correctSquares = _litSquares.toSet();
      if (_userInput.difference(correctSquares).isNotEmpty) {
        _endTest();
      } else if (_userInput.length == correctSquares.length) {
        _score++;
        if (_score % 3 == 0) {
          setState(() {
            _boardSize++;
          });
        }
        _userInput.clear();
        _correctlyIdentified.clear();
        _generateAndShowSquares();
      }
    } else {
      _endTest();
    }
  }

  void _endTest() async {
    setState(() {
      _testEnded = true;
      _testStarted = false;
    });

    VisualMemoryTestScreen.results.add(_score.toDouble());
    await VisualMemoryTestScreen.saveResults();
  }

  Widget _buildSquare(int index) {
    bool isLit = _litSquares.contains(index);
    bool isHighlighted = isLit && _isShowingSquares;
    bool isCorrectlyIdentified = _correctlyIdentified.contains(index);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onSquareTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isHighlighted
              ? (isDarkMode ? Colors.white : Colors.blueAccent)
              : isCorrectlyIdentified
                  ? (isDarkMode ? Colors.white : Colors.blueAccent)
                  : isDarkMode
                      ? const Color.fromARGB(255, 34, 34, 34)
                      : const Color.fromARGB(255, 29, 29, 29),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: isHighlighted
              ? LinearGradient(
                  colors: isDarkMode
                      ? [
                          const Color.fromARGB(255, 255, 255, 255),
                          const Color.fromARGB(255, 255, 255, 255)!
                        ]
                      : [Colors.blueAccent, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Center(
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    final lastScore = VisualMemoryTestScreen.results.isNotEmpty
        ? 'Latest Level: ${VisualMemoryTestScreen.results.last.toStringAsFixed(0)}'
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
                'Welcome to the Visual Memory Test!',
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
                'Tap the squares that light up briefly. The board size will increase as you advance.',
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
        title: const Text('Visual Memory',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: _testStarted ? _buildTestUI() : _buildStartScreen(),
      ),
    );
  }

  Widget _buildTestUI() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Current Level: $_score",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        if (_isShowingSquares) ...[
          const Text(
            "Remember the highlighted squares!",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Container(
            width: 200,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
                color: Colors.blueAccent,
                valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                    ? Color.fromARGB(255, 28, 28, 29)
                    : Colors.blueAccent),
              ),
            ),
          ),
        ] else ...[
          const Text(
            "Tap the squares you remember!",
            style: TextStyle(fontSize: 20),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: 80.0 * _boardSize + 16.0 * (_boardSize - 1),
          height: 80.0 * _boardSize + 16.0 * (_boardSize - 1),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: _boardSize,
            children: List.generate(
                _boardSize * _boardSize, (index) => _buildSquare(index)),
          ),
        ),
        const SizedBox(height: 20),
        if (_testEnded) ...[
          Text(
            "Test Ended. You reached level $_score.",
            style: const TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            onPressed: _startTest,
            child: const Text("Restart Test"),
          ),
        ],
      ],
    );
  }
}
