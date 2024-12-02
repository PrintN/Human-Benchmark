import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class TypingScreen extends StatefulWidget {
  const TypingScreen({super.key});

  static List<double> results = [];

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('typing_speed_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('typing_speed_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('typing_speed_results');
    results.clear();
  }

  @override
  _TypingScreenState createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  late String _textToType;
  final TextEditingController _textController = TextEditingController();
  final Stopwatch _stopwatch = Stopwatch();
  bool _isTestStarted = false;
  bool _isTestCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await TypingScreen.loadResults();
    _loadSentences().then((sentences) {
      _generateRandomText(sentences);
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<List<String>> _loadSentences() async {
    try {
      final String response =
          await rootBundle.loadString('assets/sentences.json');
      final data = jsonDecode(response);
      return List<String>.from(data['sentences']);
    } catch (e) {
      print('Error loading sentences: $e');
      return [];
    }
  }

  void _generateRandomText(List<String> sentences) {
    if (sentences.isEmpty) {
      setState(() {
        _textToType = 'No sentences available';
        _isLoading = false;
      });
      return;
    }
    final random = Random();
    setState(() {
      _textToType = sentences[random.nextInt(sentences.length)];
    });
  }

  void _checkCompletion(String value) {
    if (!_isTestStarted && value.isNotEmpty) {
      _startTest();
    }

    if (value == _textToType) {
      _stopwatch.stop();
      final elapsedTime = _stopwatch.elapsedMilliseconds / 1000.0;
      final wordCount = _textToType
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;
      final wpm = (elapsedTime > 0) ? (wordCount / elapsedTime) * 60.0 : 0.0;
      TypingScreen.results.add(wpm);
      TypingScreen.saveResults();
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isTestStarted = false;
          _isTestCompleted = false;
        });
      });
    }
  }

  void _startTest() {
    setState(() {
      _isTestStarted = true;
      _isTestCompleted = false;
      _textController.clear();
      _stopwatch.reset();
      _stopwatch.start();
    });

    _loadSentences().then((sentences) {
      _generateRandomText(sentences);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Speed',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: _isTestStarted
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isTestCompleted)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Type the following text:',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              _buildTextOverlay(),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _textController,
                                onChanged: (value) {
                                  setState(() {
                                    _checkCompletion(value);
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Start typing here...',
                                  hintStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                            ],
                          ),
                      ],
                    ),
            )
          : _buildStartScreen(context),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    final lastTypingSpeed = TypingScreen.results.isNotEmpty
        ? 'Latest Score: ${TypingScreen.results.last.toStringAsFixed(2)} WPM'
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
                'Welcome to the Typing Speed Test!',
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
                'This test measures your typing speed and accuracy. Type the provided text as quickly as possible. Your speed will be recorded in words per minute (WPM).',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                lastTypingSpeed,
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

  Widget _buildTextOverlay() {
    String userInput = _textController.text;
    List<TextSpan> textSpans = [];

    for (int i = 0; i < _textToType.length; i++) {
      Color textColor;

      if (i < userInput.length) {
        if (userInput[i] == _textToType[i]) {
          textColor = Colors.green;
        } else {
          textColor = Colors.red;
        }
      } else {
        textColor = Colors.grey;
      }

      textSpans.add(TextSpan(
        text: _textToType[i],
        style: TextStyle(color: textColor),
      ));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
