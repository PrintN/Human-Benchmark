import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'main.dart';

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
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadAllResults();
  }

  static Future<void> _loadAllResults() async {
    final futures = testConfigs.map((c) => c.loadResults()).toList();
    await Future.wait(futures);
  }

  void _refresh() {
    setState(() {
      _loadFuture = _loadAllResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }
        if (snapshot.hasError) {
          return _ErrorScaffold(error: snapshot.error.toString());
        }
        return _StatisticsBody(onRefresh: _refresh);
      },
    );
  }
}

// MARK: - Loading / Error
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics'), centerTitle: true),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String error;
  const _ErrorScaffold({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics'), centerTitle: true),
      body: Center(child: Text('Error: $error')),
    );
  }
}

// MARK: - Main Body
class _StatisticsBody extends StatelessWidget {
  final VoidCallback onRefresh;
  const _StatisticsBody({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenu(context, value, onRefresh),
            itemBuilder: (context) => [
              _menuItem(context, 'share', Icons.share, 'Share'),
              _menuItem(context, 'delete', Icons.delete, 'Delete All'),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Legend(),
          const SizedBox(height: 24),
          ...testConfigs.map((config) => Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _StatSection(config: config),
              )),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(BuildContext context, String value, IconData icon, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white : Colors.black),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }

  void _handleMenu(BuildContext context, String value, VoidCallback onRefresh) {
    if (value == 'share') {
      _shareAllStats(context);
    } else if (value == 'delete') {
      _confirmDelete(context, onRefresh);
    }
  }
}

// MARK: - Legend
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _LegendDot(color: Colors.red),
          SizedBox(width: 8),
          Text('You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _LegendLine(),
          SizedBox(width: 8),
          Text('World', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine();

  @override
  Widget build(BuildContext context) {
    return Container(height: 2, width: 30, color: Colors.blue);
  }
}

// MARK: - Stat Section
class _StatSection extends StatelessWidget {
  final TestConfig config;

  const _StatSection({required this.config});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(config.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Avg: ${config.average.toStringAsFixed(config.precision)} ${config.unit}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: StatChart(
            globalDistribution: config.globalDistribution,
            labels: config.labels,
            userAverage: config.average,
          ),
        ),
      ],
    );
  }
}

// MARK: - Chart Widget
class StatChart extends StatelessWidget {
  final List<double> globalDistribution;
  final List<String> labels;
  final double userAverage;

  const StatChart({
    super.key,
    required this.globalDistribution,
    required this.labels,
    required this.userAverage,
  });

  @override
  Widget build(BuildContext context) {
    final xIndex = _findClosestLabelIndex();
    final percentile = globalDistribution[xIndex];

    return LineChart(
      LineChartData(
        gridData: _gridData(),
        titlesData: _titlesData(),
        borderData: _borderData(),
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          _worldLine(),
          _userDot(xIndex, percentile),
        ],
      ),
    );
  }

  int _findClosestLabelIndex() {
    int best = 0;
    double diff = double.infinity;
    for (int i = 0; i < labels.length; i++) {
      final val = double.tryParse(labels[i].replaceAll(RegExp(r'[^\d.]'), '')) ?? double.infinity;
      final d = (userAverage - val).abs();
      if (d < diff) {
        diff = d;
        best = i;
      }
    }
    return best;
  }

  FlGridData _gridData() => FlGridData(
        show: true,
        horizontalInterval: 20,
        verticalInterval: 1,
        getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        getDrawingVerticalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
      );

  FlTitlesData _titlesData() => FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i >= 0 && i < labels.length) {
                return Text(labels[i], style: const TextStyle(fontSize: 11));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 11)),
          ),
        ),
      );

  FlBorderData _borderData() => FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2)));

  LineChartBarData _worldLine() => LineChartBarData(
        spots: globalDistribution
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        isCurved: true,
        color: Colors.blueAccent,
        barWidth: 3,
        dotData: const FlDotData(show: false),
      );

  LineChartBarData _userDot(int x, double y) => LineChartBarData(
        spots: [FlSpot(x.toDouble(), y)],
        isCurved: false,
        color: Colors.red,
        barWidth: 0,
        dotData: FlDotData(
          show: true,
          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 7,
            color: Colors.red,
            strokeColor: Colors.redAccent,
            strokeWidth: 3,
          ),
        ),
      );
}

// MARK: - Test Config
class TestConfig {
  final String title;
  final String unit;
  final int precision;
  final List<String> labels;
  final List<double> globalDistribution;
  final Future<void> Function() loadResults;
  final List<num> Function()? getResults;
  final Future<void> Function()? clearResults;

  const TestConfig({
    required this.title,
    required this.unit,
    this.precision = 1,
    required this.labels,
    required this.globalDistribution,
    required this.loadResults,
    required this.getResults,
    this.clearResults,
  });

  double get average {
    final results = getResults?.call() ?? <num>[];
    final latest = results.length > 5 ? results.sublist(results.length - 5) : results;
    return latest.isEmpty
        ? 0.0
        : latest.map((e) => e.toDouble()).reduce((a, b) => a + b) / latest.length;
  }
}

// MARK: - Test Configurations
final List<TestConfig> testConfigs = [
  TestConfig(
    title: 'Reaction Time',
    unit: 'ms',
    precision: 0,
    labels: ['100', '150', '200', '250', '300', '350', '400', '450', '500'],
    globalDistribution: [0, 5, 30, 50, 20, 10, 5, 2, 0],
    loadResults: ReactionTimeScreen.loadResults,
    getResults: () => ReactionTimeScreen.results,
    clearResults: ReactionTimeScreen.clearResults,
  ),
  TestConfig(
    title: 'Typing Speed',
    unit: 'WPM',
    precision: 0,
    labels: ['10', '20', '30', '40', '50', '60', '70', '80', '90', '100', '110'],
    globalDistribution: [40, 50, 20, 10, 5, 1, 0, 0, 0, 0, 0],
    loadResults: TypingScreen.loadResults,
    getResults: () => TypingScreen.results.map((e) => e.round()).toList(),
    clearResults: TypingScreen.clearResults,
  ),
  TestConfig(
    title: 'Number Memory',
    unit: 'score',
    precision: 0,
    labels: ['4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'],
    globalDistribution: [0, 2, 5, 10, 20, 50, 40, 30, 20, 15, 10],
    loadResults: NumberMemoryScreen.loadResults,
    getResults: () => NumberMemoryScreen.results,
    clearResults: NumberMemoryScreen.clearResults,
  ),
  TestConfig(
    title: 'Chimp Test',
    unit: 'score',
    precision: 0,
    labels: ['3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'],
    globalDistribution: [2, 5, 10, 10, 25, 40, 50, 40, 30, 20, 10, 5],
    loadResults: ChimpScreen.loadResults,
    getResults: () => ChimpScreen.results,
    clearResults: ChimpScreen.clearResults,
  ),
  TestConfig(
    title: 'Hearing Test',
    unit: 'KHz',
    precision: 2,
    labels: ['0.25', '0.5', '1', '2', '4', '8', '10', '12', '14', '16', '18', '20', '22'],
    globalDistribution: [0, 0, 0, 0, 0, 0, 2, 5, 30, 50, 30, 10, 5],
    loadResults: HearingTestScreen.loadResults,
    getResults: () => HearingTestScreen.results,
    clearResults: HearingTestScreen.clearResults,
  ),
  TestConfig(
    title: 'Verbal Memory',
    unit: 'score',
    precision: 0,
    labels: ['10', '20', '30', '40', '50', '60', '70', '80', '90', '100'],
    globalDistribution: [20, 50, 40, 25, 15, 10, 6, 5, 4, 3],
    loadResults: VerbalMemoryTestScreen.loadResults,
    getResults: () => VerbalMemoryTestScreen.results,
    clearResults: VerbalMemoryTestScreen.clearResults,
  ),
  TestConfig(
    title: 'Sequence Memory',
    unit: 'score',
    precision: 0,
    labels: ['3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'],
    globalDistribution: [0, 2, 5, 10, 20, 40, 50, 30, 20, 15, 10, 7],
    loadResults: SequenceMemoryTestScreen.loadResults,
    getResults: () => SequenceMemoryTestScreen.results,
    clearResults: SequenceMemoryTestScreen.clearResults,
  ),
  TestConfig(
    title: 'Visual Memory',
    unit: 'level',
    precision: 0,
    labels: ['3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'],
    globalDistribution: [0, 0, 2, 15, 40, 50, 40, 30, 20, 10, 7, 5],
    loadResults: VisualMemoryTestScreen.loadResults,
    getResults: () => VisualMemoryTestScreen.results,
    clearResults: VisualMemoryTestScreen.clearResults,
  ),
  TestConfig(
    title: 'Aim Trainer',
    unit: 'ms',
    precision: 0,
    labels: ['200', '250', '300', '350', '400', '450', '500', '550', '600'],
    globalDistribution: [2, 15, 25, 40, 50, 40, 25, 15, 10],
    loadResults: AimTrainerScreen.loadResults,
    getResults: () => AimTrainerScreen.results,
    clearResults: AimTrainerScreen.clearResults,
  ),
  TestConfig(
    title: 'Info Retention',
    unit: 'correct',
    precision: 0,
    labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
    globalDistribution: [2, 5, 10, 40, 50, 40, 25, 10, 5],
    loadResults: InfoRetentionScreen.loadResults,
    getResults: () => InfoRetentionScreen.results,
    clearResults: InfoRetentionScreen.clearResults,
  ),
  TestConfig(
    title: 'Intelligence Quotient',
    unit: 'IQ',
    precision: 0,
    labels: ['60', '80', '100', '120', '140', '160', '180', '200'],
    globalDistribution: [2, 20, 60, 10, 2, 1, 0.75, 0.5],
    loadResults: IntelligenceQuotientScreen.loadResults,
    getResults: () => IntelligenceQuotientScreen.results,
    clearResults: IntelligenceQuotientScreen.clearResults,
  ),
  TestConfig(
    title: 'Dual N-Back',
    unit: 'level',
    precision: 0,
    labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
    globalDistribution: [2, 20, 30, 50, 40, 20, 10, 7, 4, 2],
    loadResults: DualNBackTestScreen.loadResults,
    getResults: () => DualNBackTestScreen.results,
    clearResults: DualNBackTestScreen.clearResults,
  ),
];

// MARK: - Share & Delete
void _shareAllStats(BuildContext context) async {
  final stats = testConfigs.map((c) =>
      '${c.title}: ${c.average.toStringAsFixed(c.precision)} ${c.unit}'
  ).join('\n');
  final text = 'My Human Benchmark Stats:\n\n$stats\n\nShared via Human Benchmark App';

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 500, 700));
  final paint = Paint()..color = Colors.white;
  canvas.drawRect(const Rect.fromLTWH(0, 0, 500, 700), paint);

  final titlePainter = TextPainter(textDirection: TextDirection.ltr);
  titlePainter.text = const TextSpan(
    text: 'Human Benchmark Stats',
    style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold),
  );
  titlePainter.layout();
  titlePainter.paint(canvas, const Offset(20, 40));

  final bodyPainter = TextPainter(textDirection: TextDirection.ltr, maxLines: 20);
  bodyPainter.text = TextSpan(text: stats, style: const TextStyle(color: Colors.black, fontSize: 20));
  bodyPainter.layout(maxWidth: 460);
  bodyPainter.paint(canvas, const Offset(20, 100));

  try {
    final data = await rootBundle.load('assets/human-benchmark.webp');
    final image = await decodeImageFromList(data.buffer.asUint8List());
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      const Rect.fromLTWH(20, 600, 60, 60),
      Paint(),
    );
    final wmText = TextPainter(textDirection: TextDirection.ltr);
    wmText.text = const TextSpan(text: 'Human Benchmark', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold));
    wmText.layout();
    wmText.paint(canvas, const Offset(90, 620));
  } catch (_) {
    // Ignore if asset missing
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(500, 700);
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  final bytes = png!.buffer.asUint8List();

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/stats.png')..writeAsBytesSync(bytes);

  Share.shareXFiles([XFile(file.path)], text: text);
}

void _confirmDelete(BuildContext context, VoidCallback onRefresh) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Delete All Results?', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final clearFutures = testConfigs
                .where((c) => c.clearResults != null)
                .map((c) => c.clearResults!())
                .toList();
            await Future.wait(clearFutures);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All results deleted')));
              onRefresh();
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}