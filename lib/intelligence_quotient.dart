import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class IntelligenceQuotientScreen extends StatefulWidget {
  const IntelligenceQuotientScreen({super.key});

  static List<int> results = [];

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('iq_results') ?? [];
    results = savedResults.map((e) => int.tryParse(e) ?? 0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('iq_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('iq_results');
    results.clear();
  }

  @override
  _IntelligenceQuotientScreenState createState() =>
      _IntelligenceQuotientScreenState();
}

class _IntelligenceQuotientScreenState
    extends State<IntelligenceQuotientScreen> {
  late List<Map<String, dynamic>> questions;
  late Map<String, int> answers;
  int currentQuestionIndex = 0;
  late Stopwatch _stopwatch;
  bool _isTestStarted = false;
  bool _isTestCompleted = false;
  int _timeLeft = 1200;
  int score = 0;
  Map<int, int> selectedAnswers = {};
  bool _isFinishButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _loadTestData();
    _stopwatch = Stopwatch();
    _startTimer();
  }

  Future<void> _loadTestData() async {
    final String jsonString =
        await rootBundle.loadString('assets/iq/answers.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    final List<Map<String, dynamic>> questionsList = [];
    for (int i = 1; i <= 30; i++) {
      List<String> options = [];
      for (int j = 1; j <= 6; j++) {
        final optionPath = 'assets/iq/$i/$i-$j.webp';
        if (await _assetExists(optionPath)) {
          options.add(optionPath);
        }
      }
      questionsList.add({
        'question': 'assets/iq/$i/test$i.webp',
        'options': options,
        'correctAnswer': jsonData[i.toString()] as int,
      });
    }

    setState(() {
      questions = questionsList;
      answers = jsonData.cast<String, int>();
    });
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _startTest() {
    setState(() {
      _isTestStarted = true;
    });
    _stopwatch.start();
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      }
      if (currentQuestionIndex == 29) {
        _isFinishButtonVisible = true;
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
      if (currentQuestionIndex < 29) {
        _isFinishButtonVisible = false;
      }
    });
  }

  void _submitAnswer(int selectedAnswer) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = selectedAnswer;
    });
    if (selectedAnswer == answers[(currentQuestionIndex + 1).toString()]) {
      score++;
    }
    if (_areAllQuestionsAnswered()) {
      _finishTest();
    }
  }

  void _finishTest() {
    _stopwatch.stop();
    setState(() {
      _isTestCompleted = true;
    });

    final iqScore = _calculateIQScore(
      correctAnswers: score,
      timeTaken: _stopwatch.elapsed.inSeconds,
    );

    IntelligenceQuotientScreen.results.add(iqScore);
    _sendResultsToStatistics(iqScore);
  }

  int _calculateIQScore({required int correctAnswers, required int timeTaken}) {
    const maxIQ = 160;
    const minIQ = 80;
    const maxQuestions = 30;
    const maxTime = 1200;

    final accuracyScore = (correctAnswers / maxQuestions) * 100;
    final timeEfficiency = 100 - ((timeTaken / maxTime) * 100);
    final weightedScore = (0.6 * accuracyScore) + (0.2 * timeEfficiency);
    final iqScore = minIQ +
        ((weightedScore / 100) * (maxIQ - minIQ))
            .clamp(0, maxIQ - minIQ)
            .toInt();

    return iqScore;
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && _isTestStarted) {
        setState(() {
          _timeLeft--;
        });
      } else if (_timeLeft == 0 || _areAllQuestionsAnswered()) {
        _finishTest();
      }
    });
  }

  bool _areAllQuestionsAnswered() {
    return selectedAnswers.length == questions.length;
  }

  Future<void> _sendResultsToStatistics(int iqScore) async {
    IntelligenceQuotientScreen.results.add(iqScore);
    await IntelligenceQuotientScreen.saveResults();
  }

  bool _isAnswerSelected(int index) {
    return selectedAnswers[currentQuestionIndex] == index;
  }

  Widget _buildStartScreen(BuildContext context) {
    final lastScore = IntelligenceQuotientScreen.results.isNotEmpty
        ? 'Latest Score: ${IntelligenceQuotientScreen.results.last}'
        : 'No previous results';

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence Quotient',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: Container(
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
                  'Welcome to the Intelligence Quotient Test!',
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
                  'This test evaluates your cognitive abilities with 30 pattern-based questions. You have 20 minutes to complete the test. This is not an official IQ test.',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTestStarted || _isTestCompleted) {
      return _buildStartScreen(context);
    }

    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Intelligence Quotient',
          style:
              TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time left: ${_timeLeft ~/ 60}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
                Text(
                  '${currentQuestionIndex + 1}/30',
                  style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    questions[currentQuestionIndex]['question'] as String,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              color: isDarkMode ? Colors.white54 : Colors.black54,
              thickness: 1.5,
              indent: 0,
              endIndent: 0,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                questions[currentQuestionIndex]['options'].length,
                (index) {
                  bool isSelected = _isAnswerSelected(index + 1);
                  return GestureDetector(
                    onTap: () => _submitAnswer(index + 1),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 3 - 20,
                          height: MediaQuery.of(context).size.height * 0.13,
                          decoration: BoxDecoration(
                            color:
                                isDarkMode ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? (isDarkMode
                                      ? const Color.fromARGB(255, 131, 131, 131)
                                      : Colors.blueAccent)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              questions[currentQuestionIndex]['options'][index]
                                  as String,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: MediaQuery.of(context).size.width / 3 - 20,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 119, 119, 119)
                                      .withOpacity(0.5)
                                  : Colors.blue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _previousQuestion,
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
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: currentQuestionIndex == questions.length - 1
                        ? _finishTest
                        : _nextQuestion,
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
                    child: Text(
                      currentQuestionIndex == questions.length - 1
                          ? 'Finish'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
