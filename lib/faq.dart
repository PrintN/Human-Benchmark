import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard functionality
import 'statistics.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  // Function to copy the URL to the clipboard
  Future<void> _copyToClipboard(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied to clipboard!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      bool isDarkMode = themeProvider.isDarkMode;

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'FAQ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDarkMode ? Colors.black : Color(0xFF004D99),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: Drawer(
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              bool isDarkMode = themeProvider.isDarkMode;

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
                      leading: Icon(
                        Icons.home,
                        color: isDarkMode ? Colors.white : Color(0xFF004D99),
                      ),
                      title: const Text('Human Benchmark'),
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.bar_chart,
                        color: isDarkMode ? Colors.white : Color(0xFF004D99),
                      ),
                      title: const Text('Statistics'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StatisticsScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help,
                        color: isDarkMode ? Colors.white : Color(0xFF004D99),
                      ),
                      title: const Text('FAQ'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.brightness_6,
                        color: isDarkMode ? Colors.white : Color(0xFF004D99),
                      ),
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
              ExpansionTile(
                title: Text(
                  'What is Human Benchmark?',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Human Benchmark is an app designed to test and improve your cognitive abilities, with various tests like reaction time & typing speed.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Who made this app?',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'This app was made by PrintN, heavily inspired by the original humanbenchmark.com',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Is this app open source?',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        _copyToClipboard(context,
                            'https://github.com/PrintN/Human-Benchmark');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Yes, you can find the source code here: ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'https://github.com/PrintN/Human-Benchmark/',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Can I use this app offline?',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Yes, Human Benchmark is designed to work 100% offline.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Found an issue?',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        _copyToClipboard(
                          context,
                          'https://github.com/PrintN/Human-Benchmark/issues',
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text:
                              'If you have encountered an issue, please open a new issue here: ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'https://github.com/PrintN/Human-Benchmark/issues',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'How is the average calculated?',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'For each test, Human Benchmark stores only the latest 5 results, from which the average is calculated.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
