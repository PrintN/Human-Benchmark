import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'statistics.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final bool isDarkMode = themeProvider.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'FAQ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            centerTitle: true,
            backgroundColor: isDarkMode ? Colors.black : const Color(0xFF004D99),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: Drawer(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final bool isDarkMode = themeProvider.isDarkMode;

                return Container(
                  color: isDarkMode ? Colors.black : const Color(0xFFF5F5F5),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: isDarkMode
                              ? null
                              : const LinearGradient(
                                  colors: [Color(0xFF004D99), Color(0xFF0073E6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: isDarkMode ? Colors.black : null,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/human-benchmark-no-background.webp',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.home,
                            color: isDarkMode ? Colors.white : const Color(0xFF004D99)),
                        title: const Text('Home'),
                        onTap: () => Navigator.pushNamed(context, '/'),
                      ),
                      ListTile(
                        leading: Icon(Icons.bar_chart,
                            color: isDarkMode ? Colors.white : const Color(0xFF004D99)),
                        title: const Text('Statistics'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StatisticsScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.help,
                            color: isDarkMode ? Colors.white : const Color(0xFF004D99)),
                        title: const Text('FAQ'),
                        onTap: () => Navigator.pop(context),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.brightness_6,
                            color: isDarkMode ? Colors.white : const Color(0xFF004D99)),
                        title: const Text('Toggle Dark/Light Mode'),
                        onTap: () {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildFAQTile(
                  context,
                  question: 'What is Human Benchmark?',
                  answer: const Text('Human Benchmark is a mobile app designed to test and improve your cognitive abilities through a variety of interactive challenges, including reaction time, typing speed, memory, and more.'),
                ),
                _buildFAQTile(
                  context,
                  question: 'Who developed this app?',
                  answer: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      children: [
                        const TextSpan(text: 'This app was developed by PrintN and is heavily inspired by the original website: '),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () => _copyToClipboard(
                                context, 'https://humanbenchmark.com'),
                            child: const Text(
                              'humanbenchmark.com',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFAQTile(
                  context,
                  question: 'Is the source code open source?',
                  answer: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      children: [
                        const TextSpan(text: 'Yes! The full source code is available on GitHub: '),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () => _copyToClipboard(
                                context, 'https://github.com/PrintN/Human-Benchmark'),
                            child: const Text(
                              'github.com/PrintN/Human-Benchmark',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFAQTile(
                  context,
                  question: 'Does the app work offline?',
                  answer: const Text('Yes, Human Benchmark is fully functional offline. All tests and statistics are stored locally on your device.'),
                ),
                _buildFAQTile(
                  context,
                  question: 'I found a bug. How do I report it?',
                  answer: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      children: [
                        const TextSpan(
                            text: 'Please report issues on GitHub. Create a new issue here: '),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () => _copyToClipboard(
                                context, 'https://github.com/PrintN/Human-Benchmark/issues'),
                            child: const Text(
                              'github.com/PrintN/Human-Benchmark/issues',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFAQTile(
                  context,
                  question: 'How is the average score calculated?',
                  answer: const Text('For each test, only your most recent 5 results are stored. The average is calculated from these 5 attempts.'),
                ),
                _buildFAQTile(
                  context,
                  question: 'How can I support the development of this app?',
                  answer: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      children: [
                        const TextSpan(
                            text:
                                'Thank you for your support! You can contribute by donating here: '),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () =>
                                _copyToClipboard(context, 'https://printn.dev/donate'),
                            child: const Text(
                              'printn.dev/donate',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQTile(
    BuildContext context, {
    required String question,
    required Widget answer,
  }) {
    final bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return ExpansionTile(
      iconColor: isDarkMode ? Colors.white : Colors.black,
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            child: answer,
          ),
        ),
      ],
    );
  }
}