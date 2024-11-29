import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class InfoRetentionScreen extends StatefulWidget {
  const InfoRetentionScreen({Key? key}) : super(key: key);

  static List<double> results = [];

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('recall_test_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('recall_test_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recall_test_results');
    results.clear();
  }

  @override
  _InfoRetentionScreenState createState() => _InfoRetentionScreenState();
}

class _InfoRetentionScreenState extends State<InfoRetentionScreen> {
  late Map<String, dynamic> _currentArticle;
  bool _isLoading = true;
  bool _isQuizStarted = false;
  bool _isTestStarted = false;
  List<dynamic> _questions = [];
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  Map<int, String> _selectedAnswers = {};
  Map<int, bool> _answerStatus = {};
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await InfoRetentionScreen.loadResults();
    _loadArticles().then((articles) {
      _selectRandomArticle(articles);
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load articles: $error')));
    });
  }

  Future<List<Map<String, dynamic>>> _loadArticles() async {
    try {
      final String response =
          await rootBundle.loadString('assets/articles.json');
      final data = jsonDecode(response);
      return List<Map<String, dynamic>>.from(data['articles']);
    } catch (e) {
      print('Error loading articles: $e');
      return [];
    }
  }

  void _selectRandomArticle(List<Map<String, dynamic>> articles) {
    if (articles.isEmpty) {
      setState(() {
        _currentArticle = {
          'title': 'No Articles Available',
          'content': 'Please add some articles to proceed.',
          'questions': []
        };
        _questions.clear();
      });
      return;
    }
    final random = Random();
    final selectedIndex = random.nextInt(articles.length);
    setState(() {
      _currentArticle = articles[selectedIndex];
      _questions = List<dynamic>.from(_currentArticle['questions']);
      _totalQuestions = _questions.length;
    });
  }

  void _startTest() {
    setState(() {
      _isTestStarted = true;
    });

    _loadArticles().then((articles) {
      _selectRandomArticle(articles);
      setState(() {
        _isTestStarted = true;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load articles: $error')));
    });
  }

  void _startQuiz() {
    setState(() {
      _isQuizStarted = true;
      _correctAnswers = 0;
      _currentQuestionIndex = 0;
    });
  }

  Future<void> _finishQuiz() async {
    InfoRetentionScreen.results.add(_correctAnswers.toDouble());
    try {
      await InfoRetentionScreen.saveResults();
    } catch (e) {
      print("Error saving results: $e");
    }

    setState(() {
      _isQuizStarted = false;
      _isTestStarted = false;
      _questions.clear();
      _correctAnswers = 0;
      _selectedAnswers.clear();
      _answerStatus.clear();
      _currentQuestionIndex = 0;
    });
  }

  void _checkAnswer(
      String selectedAnswer, String correctAnswer, int questionIndex) {
    if (_selectedAnswers.containsKey(questionIndex)) return;

    setState(() {
      if (selectedAnswer == correctAnswer) {
        _answerStatus[questionIndex] = true;
        _correctAnswers++;
      } else {
        _answerStatus[questionIndex] = false;
      }
      _selectedAnswers[questionIndex] = selectedAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Retention'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isTestStarted
              ? _buildStartScreen()
              : (_isQuizStarted ? _buildQuizContent() : _buildArticleContent()),
    );
  }

  Widget _buildStartScreen() {
    final lastScore = InfoRetentionScreen.results.isNotEmpty
        ? 'Latest Score: ${InfoRetentionScreen.results.last.toStringAsFixed(0)}'
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
                'Welcome to the Info Retention Test!',
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
                'You will read a short article and then answer questions based on what you remember.',
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

  Widget _buildArticleContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentArticle['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _currentArticle['content'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
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
                  'Start Quiz',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_questions.isEmpty) {
      _finishQuiz();
      return const Center(child: Text('No questions available'));
    }

    final question = _questions[_currentQuestionIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            question['question'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...List.generate(4, (index) {
            final option = question['options'][index];
            final questionIndex = _currentQuestionIndex;
            final isSelected = _selectedAnswers[questionIndex] == option;
            final isCorrect = option == question['answer'];
            final isAnswered = _selectedAnswers.containsKey(questionIndex);

            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: _selectedAnswers[questionIndex],
                onChanged: (value) {
                  _checkAnswer(option, question['answer'], questionIndex);
                },
              ),
              tileColor: isAnswered
                  ? (isCorrect
                      ? Colors.green.withAlpha(76)
                      : (isSelected
                          ? Colors.red.withAlpha(76)
                          : Colors.red.withAlpha(76)))
                  : null,
            );
          }),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_currentQuestionIndex < _questions.length - 1) {
                    _currentQuestionIndex++;
                  } else {
                    _finishQuiz();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
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
                'Next',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
