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
        options.add('assets/iq/$i/$i-$j.webp');
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
    });
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence Quotient',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: Container(
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
                  'This test evaluates your cognitive abilities with 30 pattern-based questions. You have 20 minutes to complete the test.',
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
        color: Colors.white, // Changed background to white
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time left: ${_timeLeft ~/ 60}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                Text(
                  '${currentQuestionIndex + 1}/30',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                questions[currentQuestionIndex]['question'] as String,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(6, (index) {
                return GestureDetector(
                  onTap: () => _submitAnswer(index + 1),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3 - 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isAnswerSelected(index + 1)
                            ? Colors.blueAccent
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
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue button background
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
                      color: Colors.white, // White text color
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue button background
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
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
