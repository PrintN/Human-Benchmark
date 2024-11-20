import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class NumberMemoryScreen extends StatefulWidget {
  const NumberMemoryScreen({super.key});

  static List<int> results = [];

  static Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('number_memory_results') ?? [];
    results = savedResults.map((e) => int.tryParse(e) ?? 0).toList();
  }

  static Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    if (results.length > 5) {
      results.removeLast();
    }
    final resultsStrings = results.map((e) => e.toString()).toList();
    await prefs.setStringList('number_memory_results', resultsStrings);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('number_memory_results');
    results.clear();
  }

  @override
  _NumberMemoryScreenState createState() => _NumberMemoryScreenState();
}

class _NumberMemoryScreenState extends State<NumberMemoryScreen>
    with SingleTickerProviderStateMixin {
  bool _gameStarted = false;
  bool _gameEnded = false;
  int _score = 0;
  String _sequence = '';
  String _userInput = '';
  int _numberCount = 1;
  bool _showingNumbers = true;
  int _displayTime = 1;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    NumberMemoryScreen.loadResults();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _displayTime),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showingNumbers = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameEnded = false;
      _score = 0;
      _numberCount = 1;
      _displayTime = 1;
    });

    _generateSequence();
    _showSequence();
  }

  void _endGame() {
    setState(() {
      _gameStarted = false;
      _gameEnded = true;
    });

    NumberMemoryScreen.results.add(_score);
    NumberMemoryScreen.saveResults();
  }

  void _generateSequence() {
    final random = Random();
    final digits = List.generate(_numberCount, (index) => random.nextInt(10));
    _sequence = digits.join('');
    print('Generated sequence: $_sequence');
  }

  void _showSequence() {
    setState(() {
      _showingNumbers = true;
      _controller.duration = Duration(seconds: _displayTime);
      _controller.reset();
      _controller.forward();
    });

    Future.delayed(Duration(seconds: _displayTime), () {
      if (mounted) {
        setState(() {
          _showingNumbers = false;
        });
      }
    });
  }

  void _onSubmit() {
    if (_userInput != _sequence) {
      _endGame();
      return;
    }

    setState(() {
      _score++;
      _numberCount++;
      _displayTime++;
      _generateSequence();
      _userInput = '';
      _showSequence();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Number Memory',
          style:
              TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
        ),
      ),
      body: _gameStarted
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004D99), Color(0xFF0073E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_gameEnded)
                      Column(
                        children: [
                          Text(
                            'Score: $_score',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black26,
                                  offset: Offset(3.0, 3.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          _showingNumbers
                              ? Column(
                                  children: [
                                    Text(
                                      _sequence,
                                      style: const TextStyle(
                                        fontSize: 48,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black26,
                                            offset: Offset(3.0, 3.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTimerBar(),
                                  ],
                                )
                              : Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: 350,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 6,
                                            spreadRadius: 3,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter number here',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _userInput = value;
                                          });
                                        },
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    ElevatedButton(
                                      onPressed: _onSubmit,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32.0, vertical: 16.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        elevation: 10,
                                        shadowColor: Colors.black26,
                                        backgroundColor:
                                            const Color(0xFF004D99),
                                      ),
                                      child: const Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    if (_gameEnded)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Game Over!',
                            style: TextStyle(
                              fontSize: 36,
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
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your Score: $_score',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black26,
                                  offset: Offset(3.0, 3.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )
          : _buildStartScreen(context),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    final lastScore = NumberMemoryScreen.results.isNotEmpty
        ? 'Latest Score: ${NumberMemoryScreen.results.last}'
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
                'Welcome to the Number Memory Game!',
                style: TextStyle(
                  fontSize: 36,
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
              const SizedBox(height: 30),
              const Text(
                'You will briefly see a sequence of numbers. Your task is to remember and enter the sequence correctly. The length will increase with each round. Good luck!',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Text(
                lastScore,
                style: const TextStyle(fontSize: 22, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startGame,
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
                  'Start Game',
                  style: TextStyle(
                    fontSize: 24,
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

  Widget _buildTimerBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 20,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 300 * _animation.value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
