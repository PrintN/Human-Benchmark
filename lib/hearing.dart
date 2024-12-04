import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HearingTestScreen extends StatefulWidget {
  @override
  _HearingTestScreenState createState() => _HearingTestScreenState();

  static List<double> results = [];

  const HearingTestScreen({super.key});

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('hearing_test_results') ?? [];
    results = savedResults.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('hearing_test_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hearing_test_results');
    results.clear();
  }
}

class _HearingTestScreenState extends State<HearingTestScreen> {
  final List<int> _frequencies = [
    250,
    500,
    1000,
    2000,
    4000,
    8000,
    10000,
    12000,
    14000,
    16000,
    18000,
    20000,
    22000
  ];
  int _currentFrequencyIndex = 0;
  bool _testStarted = false;
  bool _testEnded = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _message = "Press Start to begin the test";
  List<double> _testResults = [];
  int _highestFrequency = 0;

  @override
  void initState() {
    super.initState();
    HearingTestScreen.loadResults();
  }

  Future<void> _playFrequency(int frequency, [int attempt = 1]) async {
    const int maxAttempts = 3;
    _message = "Playing tone at ${frequency / 1000} KHz";
    setState(() {});

    String mp3Path = 'assets/frequencies/$frequency.mp3';
    String wavPath = 'assets/frequencies/$frequency.wav';
    String assetPath;

    try {
      await _audioPlayer.stop();

      assetPath = await _audioPlayer
          .setAsset(mp3Path)
          .then((_) => mp3Path)
          .catchError((_) => wavPath);

      if (assetPath == wavPath) {
        await _audioPlayer.setAsset(wavPath);
      }

      _audioPlayer.play();
    } catch (e) {
      print("Failed to play sound: $e");

      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(seconds: 1));
        _playFrequency(frequency, attempt + 1);
      } else {
        setState(() {
          _message = "Failed to play tone. Please check the file.";
        });
      }
    }
  }

  void _onHeard() {
    setState(() {
      _message = "You heard the tone!";
      _testResults.add(_frequencies[_currentFrequencyIndex].toDouble());
      _highestFrequency = _frequencies[_currentFrequencyIndex];
      _nextFrequency();
    });
  }

  void _onNotHeard() {
    setState(() {
      _message = "You did not hear the tone!";
      _testResults.add(0.0);
      _endTest();
    });
  }

  void _nextFrequency() {
    if (_currentFrequencyIndex < _frequencies.length - 1) {
      _currentFrequencyIndex++;
      _playFrequency(_frequencies[_currentFrequencyIndex]);
    } else {
      _endTest();
    }
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _testEnded = false;
      _currentFrequencyIndex = 0;
      _testResults = [];
      _highestFrequency = 0;
      _message = "Testing your hearing...";
    });

    _playFrequency(_frequencies[_currentFrequencyIndex]);
  }

  void _endTest() async {
    setState(() {
      _testStarted = false;
      _testEnded = true;
      _message = "Test ended. Thank you!";
      _audioPlayer.stop();
    });

    HearingTestScreen.results.add(_highestFrequency / 1000.0);
    await HearingTestScreen.saveResults();
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
        title: const Text('Hearing Test',
            style: TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: _testStarted ? _buildTestUI() : _buildStartScreen(context),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    final lastScore = HearingTestScreen.results.isNotEmpty
        ? 'Latest Frequency Heard: ${(HearingTestScreen.results.last).toStringAsFixed(1)} KHz'
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
                'Welcome to the Hearing Test!',
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
                'You will hear a series of tones at different frequencies. Press the appropriate button if you hear each tone. The test measures the highest frequency you can hear.',
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

  Widget _buildTestUI() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            _message,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
        if (!_testEnded)
          Column(
            children: [
              ElevatedButton(
                onPressed: _onHeard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  backgroundColor: isDarkMode
                      ? Color.fromARGB(255, 24, 24, 24)
                      : const Color(0xFF004D99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black26,
                ),
                child: const Text(
                  "I Heard It",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onNotHeard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  backgroundColor: isDarkMode
                      ? Color.fromARGB(255, 24, 24, 24)
                      : const Color.fromARGB(255, 207, 13, 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black26,
                ),
                child: const Text(
                  "I Didn't Hear It",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        if (_testEnded)
          ElevatedButton(
            onPressed: _startTest,
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 8,
              shadowColor: Colors.black26,
            ),
            child: const Text(
              "Restart Test",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
