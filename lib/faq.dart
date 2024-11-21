import 'package:flutter/material.dart';
import 'statistics.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004D99), Color(0xFF0073E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
              leading: const Icon(Icons.home, color: Color(0xFF004D99)),
              title: const Text('Human Benchmark'),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF004D99)),
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
              leading: const Icon(Icons.help, color: Color(0xFF004D99)),
              title: const Text('FAQ'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
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
                  child: Text(
                    'Yes, you can find the source code of Human Benchmark on GitHub.',
                    style: TextStyle(fontSize: 16.0),
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
                  child: Text(
                    'If you have encountered an issue, please open a new issue in the Human Benchmark GitHub repository.',
                    style: TextStyle(fontSize: 16.0),
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
  }
}
