import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerbalMemoryTestScreen extends StatefulWidget {
  @override
  _VerbalMemoryTestScreenState createState() => _VerbalMemoryTestScreenState();

  static List<double> results = [];

  const VerbalMemoryTestScreen({super.key});

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults =
        prefs.getStringList('verbal_memory_test_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('verbal_memory_test_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('verbal_memory_test_results');
    results.clear();
  }
}

class _VerbalMemoryTestScreenState extends State<VerbalMemoryTestScreen> {
  List<String> _words = [];
  final List<String> _shownWords = [];
  final Set<String> _shownWordsSet = {};
  final Set<String> _trueSeenWords = {};
  String _currentWord = '';
  bool _testStarted = false;
  bool _testEnded = false;
  int _totalRemembered = 0;
  int _shownWordsCount = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    VerbalMemoryTestScreen.loadResults();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final String response = await rootBundle.loadString('assets/words.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _words = List<String>.from(data);
    });
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _testEnded = false;
      _shownWords.clear();
      _shownWordsSet.clear();
      _trueSeenWords.clear();
      _currentWord = '';
      _totalRemembered = 0;
      _shownWordsCount = 0;
      _showNextWord();
    });
  }

  void _showNextWord() {
    if (_shownWords.length < _words.length) {
      String nextWord;
      bool shouldShowSeenWord = _random.nextDouble() < 0.3;

      if (shouldShowSeenWord && _shownWords.isNotEmpty) {
        nextWord = _shownWords[_random.nextInt(_shownWords.length)];
      } else {
        do {
          nextWord = _words[_random.nextInt(_words.length)];
        } while (_shownWordsSet.contains(nextWord) &&
            _shownWords.length < _words.length);
      }

      setState(() {
        _currentWord = nextWord;
      });
    } else {
      _endTest();
    }
  }

  void _endTest() async {
    setState(() {
      _testStarted = false;
      _testEnded = true;
    });

    VerbalMemoryTestScreen.results.add(_shownWordsCount.toDouble());
    await VerbalMemoryTestScreen.saveResults();
  }

  void _checkWordStatus(bool isSeen) {
    if (isSeen) {
      if (_trueSeenWords.contains(_currentWord) ||
          _shownWordsSet.contains(_currentWord)) {
        _totalRemembered++;
        setState(() {
          _shownWords.add(_currentWord);
          _shownWordsSet.add(_currentWord);
          _trueSeenWords.add(_currentWord);
          _shownWordsCount++;
        });
      } else {
        _endTest();
      }
    } else {
      if (!_shownWordsSet.contains(_currentWord)) {
        setState(() {
          _shownWords.add(_currentWord);
          _shownWordsSet.add(_currentWord);
          _shownWordsCount++;
        });
      } else {
        _endTest();
      }
    }

    if (!_testEnded) {
      _showNextWord();
    }
  }

  void _onSeen() {
    setState(() {
      _checkWordStatus(true);
    });
  }

  void _onNew() {
    setState(() {
      _checkWordStatus(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verbal Memory',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF004D99),
      ),
      body: Center(
        child: _testStarted ? _buildTestUI() : _buildStartScreen(context),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    final lastScore = VerbalMemoryTestScreen.results.isNotEmpty
        ? 'Latest Score: ${VerbalMemoryTestScreen.results.last.toStringAsFixed(0)}'
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
                'Welcome to the Verbal Memory Test!',
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
                'In this test, you will see a series of words. Press "Seen" if you remember a word and "New" if it’s new.',
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

  Widget _buildTestUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentWord,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004D99),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Words Shown: $_shownWordsCount",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _onSeen,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0073E6),
            padding:
                const EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
          ),
          child: const Text(
            "Seen",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: _onNew,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0073E6),
            padding:
                const EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
          ),
          child: const Text(
            "New",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_testEnded)
          ElevatedButton(
            onPressed: _startTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D99),
              padding:
                  const EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
            ),
            child: const Text(
              "Restart Test",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
