import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:just_audio/just_audio.dart';

class DualNBackTestScreen extends StatefulWidget {
  @override
  _DualNBackTestScreenState createState() => _DualNBackTestScreenState();

  static List<int> results = [];

  const DualNBackTestScreen({super.key});

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('dual_n_back_results') ?? [];
    results = savedResults.map((e) => int.tryParse(e) ?? 0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeAt(0);
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('dual_n_back_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dual_n_back_results');
    results.clear();
  }
}

class _DualNBackTestScreenState extends State<DualNBackTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _letters = [
    'B',
    'C',
    'F',
    'G',
    'K',
    'M',
    'R',
    'T',
    'U',
    'X',
  ];
  final List<Offset> _positions = [
    Offset(0.0, 0.0),
    Offset(1.0, 0.0),
    Offset(2.0, 0.0),
    Offset(0.0, 1.0),
    Offset(1.0, 1.0),
    Offset(2.0, 1.0),
    Offset(0.0, 2.0),
    Offset(1.0, 2.0),
    Offset(2.0, 2.0),
  ];

  List<Map<String, dynamic>> _sequence = [];
  int _currentStep = 0;
  int _currentLevel = 1;
  int _stepsCompleted = 0;
  bool _isTestRunning = false;
  int _sessionScore = 0;
  int correctCounter = 0;
  int wrongCounter = 0;
  int validMatchCounter = 0;
  bool _buttonsDisabled = false;

  final int stepsPerLevel = 10;

  @override
  void initState() {
    super.initState();
    DualNBackTestScreen.loadResults();
  }

  void _startTest() {
    setState(() {
      _isTestRunning = true;
      _currentStep = 0;
      _sessionScore = 0;
      correctCounter = 0;
      wrongCounter = 0;
      validMatchCounter = 0;
      _stepsCompleted = 0;
      _currentLevel = 1;
      _sequence = [];
    });
    _generateNextStep();
  }

  Future<void> _playLetterAudio(String letter) async {
    try {
      await _audioPlayer.setAsset('assets/letters/$letter.ogg');
      await _audioPlayer.play();
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  void _checkMatch(bool isAudio, {bool isBoth = false}) {
    if (_buttonsDisabled) return;

    setState(() {
      _buttonsDisabled = true;
    });

    if (_currentStep <= _currentLevel) return;

    final targetIndex = _currentStep - _currentLevel - 1;

    final currentStepData = _sequence[_currentStep - 1];
    final targetStepData = _sequence[targetIndex];

    final audioMatch = currentStepData['letter'] == targetStepData['letter'];
    final visualMatch =
        currentStepData['position'] == targetStepData['position'];

    bool match = false;
    if (isBoth) {
      match = audioMatch && visualMatch;
    } else if (isAudio) {
      match = audioMatch;
    } else {
      match = visualMatch;
    }

    setState(() {
      if (match) {
        correctCounter++;
        validMatchCounter++;
        _sessionScore++;
      } else {
        wrongCounter++;
      }
    });
  }

  Future<void> _generateNextStep() async {
    if (!_isTestRunning) return;

    setState(() {
      _buttonsDisabled = true;
    });

    if (_stepsCompleted >= stepsPerLevel) {
      _checkLevelCompletion();
      return;
    }

    final random = Random();
    final newLetter = _letters[random.nextInt(_letters.length)];
    final newPosition = random.nextInt(_positions.length);

    setState(() {
      _sequence.add({'letter': newLetter, 'position': newPosition});
    });

    await _playLetterAudio(newLetter);

    setState(() {
      _currentStep++;
      _stepsCompleted++;
      _buttonsDisabled = false;
    });

    await Future.delayed(const Duration(seconds: 3));
    _generateNextStep();
  }

  Future<void> _endTest() async {
    setState(() {
      _isTestRunning = false;
    });

    DualNBackTestScreen.results.add(_currentLevel);
    await DualNBackTestScreen.saveResults();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dual N-Back',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: _isTestRunning ? _buildTestUI() : _buildStartScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    final lastScore = DualNBackTestScreen.results.isNotEmpty
        ? 'Latest Level: ${DualNBackTestScreen.results.last}-Back'
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Dual N-Back Test!',
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
                  ]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Test your working memory. Match the audio and visual sequence by pressing "Audio Match" or "Visual Match" when you think it matches the sequence from N steps ago.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
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
    );
  }

  Future<void> _checkLevelCompletion() async {
    int maxPossibleCorrectAnswers = 0;

    for (int i = _currentLevel; i < _stepsCompleted; i++) {
      final targetIndex = i - _currentLevel;

      if (targetIndex >= 0) {
        final currentStepData = _sequence[i];
        final targetStepData = _sequence[targetIndex];

        final audioMatch =
            currentStepData['letter'] == targetStepData['letter'];
        final visualMatch =
            currentStepData['position'] == targetStepData['position'];

        if (audioMatch || visualMatch) {
          maxPossibleCorrectAnswers++;
        }
      }
    }

    final accuracy = maxPossibleCorrectAnswers > 0
        ? (correctCounter / maxPossibleCorrectAnswers) * 100
        : 0;

    if (accuracy >= 70 && _stepsCompleted >= stepsPerLevel) {
      setState(() {
        _currentLevel++;
        _stepsCompleted = 0;
        correctCounter = 0;
        wrongCounter = 0;
        validMatchCounter = 0;
      });
      await Future.delayed(const Duration(seconds: 3));
      _generateNextStep();
    } else if (_stepsCompleted >= stepsPerLevel) {
      _endTest();
    }
  }

  Widget _buildTestUI() {
    int maxPossibleCorrectAnswers = 0;

    for (int i = _currentLevel; i < _stepsCompleted; i++) {
      final targetIndex = i - _currentLevel;

      if (targetIndex >= 0) {
        final currentStepData = _sequence[i];
        final targetStepData = _sequence[targetIndex];

        final audioMatch =
            currentStepData['letter'] == targetStepData['letter'];
        final visualMatch =
            currentStepData['position'] == targetStepData['position'];

        if (audioMatch || visualMatch) {
          maxPossibleCorrectAnswers++;
        }
      }
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$_currentLevel-Back',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        const SizedBox(height: 10),
        Text('Correct: $correctCounter   Wrong: $wrongCounter',
            style: TextStyle(
                fontSize: 18, color: isDarkMode ? Colors.white : Colors.green)),
        const SizedBox(height: 10),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: _positions.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(5),
              color: _sequence.isNotEmpty && index == _sequence.last['position']
                  ? isDarkMode
                      ? Colors.white
                      : Colors.blue
                  : isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
            );
          },
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _buttonsDisabled ? null : () => _checkMatch(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Color.fromARGB(255, 24, 24, 24)
                        : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Audio Match',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _buttonsDisabled ? null : () => _checkMatch(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Color.fromARGB(255, 24, 24, 24)
                        : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Visual Match',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _buttonsDisabled
                  ? null
                  : () => _checkMatch(false, isBoth: true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? Color.fromARGB(255, 24, 24, 24) : Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Both',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}