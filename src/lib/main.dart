import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CsvGraphApp());
}

class CsvGraphApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Graph Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CsvGraphPage(),
    );
  }
}

class CsvGraphPage extends StatefulWidget {
  @override
  _CsvGraphPageState createState() => _CsvGraphPageState();
}

class _CsvGraphPageState extends State<CsvGraphPage> {
  List<FlSpot> _dataPoints = [];

  Future<void> _pickAndLoadCsv() async {
    // ファイルピッカーを開いてCSVファイルを選択
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      _parseCsv(content);
    } else {
      // ユーザーがファイル選択をキャンセルした場合
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ファイルの選択がキャンセルされました。')),
      );
    }
  }

  void _parseCsv(String content) {
    List<FlSpot> tempData = [];
    List<String> lines = content.split('\n');

    if (lines.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSVファイルのフォーマットが正しくありません。')),
      );
      return;
    }

    // 1行目のヘッダーを確認
    List<String> headers = lines[0].split(',');
    if (headers.length < 2 ||
        headers[0].trim() != 'No.' ||
        headers[1].trim() != 'Speed') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSVファイルのヘッダーが正しくありません。')),
      );
      return;
    }

    // 2行目以降をパース
    for (int i = 1; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue; // 空行をスキップ

      List<String> parts = line.split(',');
      if (parts.length < 2) continue; // 不完全な行をスキップ

      try {
        int no = int.parse(parts[0].trim());
        double speedCm = double.parse(parts[1].trim());

        // cm/min を m/min に変換
        double speed = speedCm / 100.0;

        // 時間を秒単位に変換（No. * 5ms）
        double timeInSeconds = (no * 5) / 1000.0;

        tempData.add(FlSpot(timeInSeconds, speed));
      } catch (e) {
        // パースエラーが発生した場合はスキップ
        continue;
      }
    }

    setState(() {
      _dataPoints = tempData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ステップ速度表示'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _dataPoints.isEmpty
                ? Center(child: Text('CSVファイルを読み込んでください。'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          // 上部のタイトルを非表示
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          // 右側のタイトルを非表示
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          // 下部のタイトルと単位の設定
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: _calculateXInterval(),
                              getTitlesWidget: (value, meta) {
                                // 値のみ表示
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('${value.toStringAsFixed(2)}'),
                                );
                              },
                            ),
                            axisNameWidget: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('[s]'),
                            ),
                            axisNameSize: 20,
                          ),
                          // 左側のタイトルと単位の設定
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: _calculateYInterval(),
                              getTitlesWidget: (value, meta) {
                                // 値のみ表示
                                return Text('${value.toStringAsFixed(1)}');
                              },
                            ),
                            axisNameWidget: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text('[m/min]'),
                            ),
                            axisNameSize: 20,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        minX: _dataPoints.first.x,
                        maxX: _dataPoints.last.x,
                        minY: _getMinY(),
                        maxY: _getMaxY(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _dataPoints,
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _pickAndLoadCsv,
                icon: Icon(Icons.file_upload),
                label: Text('CSV読み込み'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMinY() {
    double minY = _dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    return minY - 1; // マージンを追加
  }

  double _getMaxY() {
    double maxY = _dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return maxY + 1; // マージンを追加
  }

  double _calculateXInterval() {
    double totalTime = _dataPoints.last.x - _dataPoints.first.x;
    return totalTime / 5; // 適当な間隔を設定
  }

  double _calculateYInterval() {
    double maxY = _getMaxY();
    return (maxY / 5).ceilToDouble();
  }
}
