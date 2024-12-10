import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import 'main.dart';
import 'faq.dart';
import 'reaction_time.dart';
import 'typing.dart';
import 'chimp.dart';
import 'number_memory.dart';
import 'hearing.dart';
import 'verbal_memory.dart';
import 'sequence_memory.dart';
import 'visual_memory.dart';
import 'aim_trainer.dart';
import 'info_retention.dart';
import 'intelligence_quotient.dart';
import 'dual_n-back.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    await ReactionTimeScreen.loadResults();
    await TypingScreen.loadResults();
    await NumberMemoryScreen.loadResults();
    await ChimpScreen.loadResults();
    await HearingTestScreen.loadResults();
    await VerbalMemoryTestScreen.loadResults();
    await SequenceMemoryTestScreen.loadResults();
    await VisualMemoryTestScreen.loadResults();
    await AimTrainerScreen.loadResults();
    await InfoRetentionScreen.loadResults();
    await IntelligenceQuotientScreen.loadResults();
    await DualNBackTestScreen.loadResults();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Statistics'),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Statistics'),
              centerTitle: true,
            ),
            body: Center(child: Text('Error loading data: ${snapshot.error}')),
          );
        }

        final List<int> reactionTimeValues = [
          0,
          1,
          15,
          55,
          25,
          4,
          0,
          0,
          0,
          0,
          0,
          0,
          100
        ];
        final List<int> typingSpeedValues = [
          35,
          50,
          30,
          10,
          4,
          1,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          100
        ];
        final List<int> numberMemoryValues = [
          0,
          4,
          10,
          50,
          10,
          5,
          0,
          0,
          0,
          0,
          0,
          0,
          100
        ];
        final List<int> chimpTestValues = [
          0,
          0,
          0,
          8,
          8,
          50,
          40,
          15,
          7,
          2,
          0,
          0,
          0,
          0,
          100
        ];
        final List<int> hearingTestValues = [
          0,
          0,
          0,
          0,
          0,
          0,
          2,
          10,
          30,
          45,
          50,
          20,
          5,
          1,
          0,
          100
        ];
        final List<int> verbalMemoryValues = [
          30,
          50,
          50,
          25,
          10,
          7,
          4,
          3,
          2,
          1,
          1,
          0,
          0,
          0,
          100
        ];
        final List<int> sequenceMemoryValues = [
          0,
          4,
          20,
          10,
          10,
          12,
          50,
          50,
          10,
          7,
          4,
          3,
          2,
          1,
          0,
          0,
          100
        ];
        final List<int> visualMemoryValues = [
          0,
          1,
          0,
          0,
          4,
          7,
          10,
          50,
          30,
          40,
          5,
          0,
          0,
          0,
          0,
          0,
          100
        ];
        final List<int> aimTrainerValues = [
          0,
          7,
          50,
          40,
          10,
          5,
          4,
          3,
          2,
          1,
          0,
          0,
          100
        ];
        final List<int> infoRetentionValues = [
          0,
          7,
          30,
          50,
          30,
          5,
          0,
          0,
          0,
          0,
          0,
          0,
          100
        ];
        final List<int> intelligenceQuotientValues = [
          0,
          0,
          0,
          0,
          8,
          60,
          12,
          2,
          1,
          1,
          0,
          0,
          100
        ];
        final List<int> dualNBackValues = [
          40,
          45,
          40,
          30,
          15,
          7,
          2,
          1,
          0,
          0,
          0,
          0,
          100
        ];

        final List<double> reactionTimeDistribution =
            _generateCustomDistribution(reactionTimeValues);
        final List<double> typingSpeedDistribution =
            _generateCustomDistribution(typingSpeedValues);
        final List<double> numberMemoryDistribution =
            _generateCustomDistribution(numberMemoryValues);
        final List<double> chimpTestDistribution =
            _generateCustomDistribution(chimpTestValues);
        final List<double> hearingTestDistribution =
            _generateCustomDistribution(hearingTestValues);
        final List<double> verbalMemoryDistribution =
            _generateCustomDistribution(verbalMemoryValues);
        final List<double> sequenceMemoryDistribution =
            _generateCustomDistribution(sequenceMemoryValues);
        final List<double> visualMemoryDistribution =
            _generateCustomDistribution(visualMemoryValues);
        final List<double> aimTrainerDistribution =
            _generateCustomDistribution(aimTrainerValues);
        final List<double> infoRetentionDistribution =
            _generateCustomDistribution(infoRetentionValues);
        final List<double> intelligenceQuotientDistribution =
            _generateCustomDistribution(intelligenceQuotientValues);
        final List<double> dualNBackDistribution =
            _generateCustomDistribution(dualNBackValues);

        final List<double> reactionTimeResults = ReactionTimeScreen.results;
        final List<double> typingSpeedResults = TypingScreen.results;
        final List<int> numberMemoryResults = NumberMemoryScreen.results;
        final List<int> chimpTestResults = ChimpScreen.results;
        final List<double> hearingTestResults = HearingTestScreen.results;
        final List<double> verbalMemoryResults = VerbalMemoryTestScreen.results;
        final List<double> sequenceMemoryResults =
            SequenceMemoryTestScreen.results;
        final List<double> visualMemoryResults = VisualMemoryTestScreen.results;
        final List<double> aimTrainerResults = AimTrainerScreen.results;
        final List<double> infoRetentionResults = InfoRetentionScreen.results;
        final List<int> intelligenceQuotientResults =
            IntelligenceQuotientScreen.results;
        final List<int> dualNBackResults = DualNBackTestScreen.results;

        final List<double> latestReactionTimeResults =
            _getLatestResults(reactionTimeResults);
        final List<double> latestTypingSpeedResults = _getLatestResults(
          typingSpeedResults.map((e) => e.roundToDouble()).toList(),
        );

        final double reactionTimeAverage = latestReactionTimeResults.isNotEmpty
            ? latestReactionTimeResults.reduce((a, b) => a + b) /
                latestReactionTimeResults.length
            : 0;

        final double typingSpeedAverage = latestTypingSpeedResults.isNotEmpty
            ? latestTypingSpeedResults.reduce((a, b) => a + b) /
                latestTypingSpeedResults.length
            : 0;

        final double numberMemoryAverage = numberMemoryResults.isNotEmpty
            ? numberMemoryResults.reduce((a, b) => a + b) /
                numberMemoryResults.length.toDouble()
            : 0;

        final double chimpTestAverage = chimpTestResults.isNotEmpty
            ? chimpTestResults.reduce((a, b) => a + b) /
                chimpTestResults.length.toDouble()
            : 0;

        final double hearingTestAverage = hearingTestResults.isNotEmpty
            ? hearingTestResults.reduce((a, b) => a + b) /
                hearingTestResults.length.toDouble()
            : 0;

        final double verbalMemoryAverage = verbalMemoryResults.isNotEmpty
            ? verbalMemoryResults.reduce((a, b) => a + b) /
                verbalMemoryResults.length.toDouble()
            : 0;

        final double sequenceMemoryAverage = sequenceMemoryResults.isNotEmpty
            ? sequenceMemoryResults.reduce((a, b) => a + b) /
                sequenceMemoryResults.length.toDouble()
            : 0;

        final double visualMemoryAverage = visualMemoryResults.isNotEmpty
            ? visualMemoryResults.reduce((a, b) => a + b) /
                visualMemoryResults.length.toDouble()
            : 0;

        final double aimTrainerAverage = aimTrainerResults.isNotEmpty
            ? aimTrainerResults.reduce((a, b) => a + b) /
                aimTrainerResults.length.toDouble()
            : 0;

        final double infoRetentionAverage = infoRetentionResults.isNotEmpty
            ? infoRetentionResults.reduce((a, b) => a + b) /
                infoRetentionResults.length.toDouble()
            : 0;

        final double intelligenceQuotientAverage =
            intelligenceQuotientResults.isNotEmpty
                ? intelligenceQuotientResults.reduce((a, b) => a + b) /
                    intelligenceQuotientResults.length.toDouble()
                : 0;

        final double dualNBackAverage = dualNBackResults.isNotEmpty
            ? dualNBackResults.reduce((a, b) => a + b) /
                dualNBackResults.length.toDouble()
            : 0;

        final List<String> typingSpeedLabels = [
          '10',
          '20',
          '30',
          '40',
          '50',
          '60',
          '70',
          '80',
          '90',
          '100',
          '110',
          ' '
        ];
        final List<String> reactionTimeLabels = [
          '100',
          '150',
          '200',
          '250',
          '300',
          '350',
          '400',
          '450',
          '500',
          ' '
        ];
        final List<String> chimpTestLabels = [
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          '11',
          '12',
          '13',
          '14',
          ' '
        ];
        final List<String> numberMemoryLabels = [
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          '11',
          ' '
        ];
        final List<String> hearingTestLabels = [
          '0.25',
          '0.5',
          '1',
          '2',
          '4',
          '8',
          '10',
          '12',
          '14',
          '16',
          '18',
          '20',
          '22',
          ' '
        ];
        final List<String> verbalMemoryLabels = [
          '10',
          '20',
          '30',
          '40',
          '50',
          '60',
          '70',
          '80',
          '90',
          '100',
          '120',
          '140',
          ' '
        ];
        final List<String> sequenceMemoryLabels = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          '11',
          '12',
          '13',
          '14',
          ' '
        ];
        final List<String> visualMemoryLabels = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          '11',
          '12',
          '13',
          '14',
          ' '
        ];
        final List<String> aimTrainerLabels = [
          '200',
          '250',
          '300',
          '350',
          '400',
          '450',
          '500',
          '550',
          '600',
          '650',
          ' '
        ];
        final List<String> infoRetentionLabels = [
          '0',
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          ' '
        ];
        final List<String> intelligenceQuotientLabels = [
          '0',
          '20',
          '40',
          '60',
          '80',
          '100',
          '120',
          '140',
          '160',
          '200',
          ' '
        ];
        final List<String> dualNBackLabels = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          ' '
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Statistics',
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
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String result) {
                  switch (result) {
                    case 'share':
                      _shareStatistics(
                        reactionTimeAverage: reactionTimeAverage,
                        typingSpeedAverage: typingSpeedAverage,
                        numberMemoryAverage: numberMemoryAverage,
                        chimpTestAverage: chimpTestAverage,
                        hearingTestAverage: hearingTestAverage,
                        verbalMemoryAverage: verbalMemoryAverage,
                        sequenceMemoryAverage: sequenceMemoryAverage,
                        visualMemoryAverage: visualMemoryAverage,
                        aimTrainerAverage: aimTrainerAverage,
                        infoRetentionAverage: infoRetentionAverage,
                        intelligenceQuotientAverage:
                            intelligenceQuotientAverage,
                        dualNBackAverage: dualNBackAverage,
                      );
                      break;
                    case 'delete':
                      _showDeleteConfirmationDialog(context);
                      break;
                    default:
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;

                  return [
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share,
                              color: isDarkMode ? Colors.white : Colors.black),
                          const SizedBox(width: 10),
                          Text('Share',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              color: isDarkMode ? Colors.white : Colors.black),
                          const SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
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
                                  colors: [
                                    Color(0xFF004D99),
                                    Color(0xFF0073E6)
                                  ],
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
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.help,
                          color: isDarkMode ? Colors.white : Color(0xFF004D99),
                        ),
                        title: const Text('FAQ'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FAQScreen()),
                          );
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
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'You',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: 30,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'World',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildStatisticSection(
                        'Reaction Time',
                        reactionTimeDistribution,
                        reactionTimeLabels,
                        'ms',
                        reactionTimeAverage),
                    _buildStatisticSection(
                        'Typing Speed',
                        typingSpeedDistribution,
                        typingSpeedLabels,
                        'WPM',
                        typingSpeedAverage),
                    _buildStatisticSection(
                        'Number Memory',
                        numberMemoryDistribution,
                        numberMemoryLabels,
                        'score',
                        numberMemoryAverage),
                    _buildStatisticSection('Chimp Test', chimpTestDistribution,
                        chimpTestLabels, 'score', chimpTestAverage),
                    _buildStatisticSection(
                        'Hearing Test',
                        hearingTestDistribution,
                        hearingTestLabels,
                        'KHz',
                        hearingTestAverage),
                    _buildStatisticSection(
                        'Verbal Memory',
                        verbalMemoryDistribution,
                        verbalMemoryLabels,
                        'score',
                        verbalMemoryAverage),
                    _buildStatisticSection(
                        'Sequence Memory',
                        sequenceMemoryDistribution,
                        sequenceMemoryLabels,
                        'score',
                        sequenceMemoryAverage),
                    _buildStatisticSection(
                        'Visual Memory',
                        visualMemoryDistribution,
                        visualMemoryLabels,
                        'level',
                        visualMemoryAverage),
                    _buildStatisticSection(
                        'Aim Trainer',
                        aimTrainerDistribution,
                        aimTrainerLabels,
                        'ms',
                        aimTrainerAverage),
                    _buildStatisticSection(
                        'Info Retention',
                        infoRetentionDistribution,
                        infoRetentionLabels,
                        'correct',
                        infoRetentionAverage),
                    _buildStatisticSection(
                        'Intelligence Quotient',
                        intelligenceQuotientDistribution,
                        intelligenceQuotientLabels,
                        'IQ',
                        intelligenceQuotientAverage),
                    _buildStatisticSection('Dual N-Back', dualNBackDistribution,
                        dualNBackLabels, 'level', dualNBackAverage),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticSection(String title, List<double> data,
      List<String> xAxisLabels, String unit, double average) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Average: ${average.toStringAsFixed(2)} $unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: LineChart(
            _buildDistributionChartData(data, xAxisLabels, unit, average),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  List<double> _generateCustomDistribution(List<int> values) {
    final List<double> distribution = [];
    final int maxValue = values.isNotEmpty ? values.reduce(max) : 1;
    for (int value in values) {
      double normalizedValue = (value / maxValue) * 100;
      distribution.add(normalizedValue);
    }
    return distribution;
  }

  LineChartData _buildDistributionChartData(List<double> data,
      List<String> xAxisLabels, String unit, double average) {
    final int labelsLength = xAxisLabels.length;

    int closestLabelIndex = 0;
    double closestLabelDifference = double.infinity;

    for (int i = 0; i < xAxisLabels.length; i++) {
      double labelValue =
          double.tryParse(xAxisLabels[i].replaceAll(RegExp(r'[^\d.]'), '')) ??
              0;

      double difference = (average - labelValue).abs();
      if (difference < closestLabelDifference) {
        closestLabelIndex = i;
        closestLabelDifference = difference;
      }
    }

    double yValueAtClosestLabel = data[closestLabelIndex];

    final redDot = LineChartBarData(
      spots: [FlSpot(closestLabelIndex.toDouble(), yValueAtClosestLabel)],
      isCurved: false,
      color: Colors.red,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 5,
          color: Colors.red,
          strokeWidth: 2,
          strokeColor: Colors.redAccent,
        ),
      ),
      belowBarData: BarAreaData(show: false),
      barWidth: 0,
    );

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 20,
        verticalInterval: 20,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final int index = value.toInt();
              if (index >= 0 && index < labelsLength) {
                return Text(xAxisLabels[index],
                    style: const TextStyle(fontSize: 12));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) =>
                Text('${value.toInt()}%', style: const TextStyle(fontSize: 12)),
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
      minX: 0,
      maxX: (labelsLength - 1).toDouble(),
      minY: data.reduce((a, b) => a < b ? a : b),
      maxY: data.reduce((a, b) => a > b ? a : b),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i])
          ],
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        redDot,
      ],
    );
  }

  List<double> _getLatestResults(List<double> results) {
    int count = results.length > 10 ? 10 : results.length;
    return results.sublist(results.length - count);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete All Results',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: const Text(
              'Are you sure you want to delete all results? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await ReactionTimeScreen.clearResults();
                await TypingScreen.clearResults();
                await NumberMemoryScreen.clearResults();
                await ChimpScreen.clearResults();
                await HearingTestScreen.clearResults();
                await VerbalMemoryTestScreen.clearResults();
                await SequenceMemoryTestScreen.clearResults();
                await VisualMemoryTestScreen.clearResults();
                await AimTrainerScreen.clearResults();
                await InfoRetentionScreen.clearResults();
                await IntelligenceQuotientScreen.clearResults();
                await DualNBackTestScreen.clearResults();
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _shareStatistics({
    required double reactionTimeAverage,
    required double typingSpeedAverage,
    required double numberMemoryAverage,
    required double chimpTestAverage,
    required double hearingTestAverage,
    required double verbalMemoryAverage,
    required double sequenceMemoryAverage,
    required double visualMemoryAverage,
    required double aimTrainerAverage,
    required double infoRetentionAverage,
    required double intelligenceQuotientAverage,
    required double dualNBackAverage,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
        recorder, Rect.fromPoints(const Offset(0, 0), const Offset(500, 550)));

    final Paint paint = Paint()..color = Colors.white;
    const Rect rect = Rect.fromLTWH(0, 0, 500, 550);
    canvas.drawRect(rect, paint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'Average',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 500);
    textPainter.paint(canvas, const Offset(50, 60));

    textPainter.text = TextSpan(
      text: '\n\nReaction Time: ${reactionTimeAverage.toStringAsFixed(2)} ms\n'
          'Typing Speed: ${typingSpeedAverage.toStringAsFixed(0)} WPM\n'
          'Number Memory: ${numberMemoryAverage.toStringAsFixed(0)} score\n'
          'Chimp Test: ${chimpTestAverage.toStringAsFixed(0)} score\n'
          'Hearing Test: ${hearingTestAverage.toStringAsFixed(2)} KHz\n'
          'Verbal Memory: ${verbalMemoryAverage.toStringAsFixed(0)} score\n'
          'Sequence Memory: ${sequenceMemoryAverage.toStringAsFixed(0)} score\n'
          'Visual Memory: ${visualMemoryAverage.toStringAsFixed(0)} score\n'
          'Aim Trainer: ${aimTrainerAverage.toStringAsFixed(0)} ms\n'
          'Info Retention: ${infoRetentionAverage.toStringAsFixed(0)} correct\n'
          'Intelligence Quotient: ${intelligenceQuotientAverage.toStringAsFixed(0)} IQ\n'
          'Dual N-Back: ${dualNBackAverage.toStringAsFixed(0)} level',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 500);
    textPainter.paint(canvas, const Offset(50, 60));

    final ByteData data = await rootBundle.load('assets/human-benchmark.webp');
    final ui.Image watermark =
        await decodeImageFromList(data.buffer.asUint8List());

    const double watermarkWidth = 60;
    const double watermarkHeight = 60;
    const double watermarkX = 40;
    const double watermarkY = 550 - watermarkHeight - 16;

    const Rect watermarkRect = Rect.fromLTWH(
      watermarkX,
      watermarkY,
      watermarkWidth,
      watermarkHeight,
    );
    canvas.drawImageRect(
      watermark,
      Rect.fromLTWH(
          0, 0, watermark.width.toDouble(), watermark.height.toDouble()),
      watermarkRect,
      Paint(),
    );

    final TextPainter watermarkTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Human Benchmark',
        style: TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    watermarkTextPainter.layout(minWidth: 0, maxWidth: 300);

    const double textX = watermarkX + watermarkWidth + 10;
    final double textY =
        watermarkY + (watermarkHeight - watermarkTextPainter.height) / 2;

    watermarkTextPainter.paint(canvas, Offset(textX, textY));

    final ui.Picture picture = recorder.endRecording();
    final ui.Image img = await picture.toImage(500, 700);
    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/statistics.png');
    await file.writeAsBytes(pngBytes);

    Share.shareXFiles(
      [XFile(file.path)],
      text: 'Check out my latest stats!',
      subject: 'My Latest Stats',
    );
  }
}

double _calculateAverage(List<double> data) {
  if (data.isEmpty) {
    return 0.0;
  }

  double sum = data.reduce((a, b) => a + b);
  return sum / data.length;
}
