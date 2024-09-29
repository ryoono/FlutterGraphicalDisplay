import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter(){
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;
      // print(_counter);
      read_csv();
      _counter++;
      print(_counter);

      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['csv'],
      // );
      
      // var file = new File('../../../');
      // Future<String> contents = file.readAsString();
      // print(contents);
      // contents.then((content) => print(content));
    });
  }

  // awaitを使う時の設定
  // https://zenn.dev/flutteruniv_dev/articles/5a1fb9cdca854e
  Future<void> read_csv() async {
    
    // ファイル選択
    // https://qiita.com/krohigewagma/items/ab2beea3b00cb8c3f62b
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    print(result?.files.first.path);

    // nullチェック方法
    // https://github.com/flutter/flutter/issues/92792
    String hoge = result?.files.first.path ?? "";

    // ファイル読み込み
    // https://jp-seemore.com/app/17142/
    if( hoge != "" ){
      var file = File(hoge);
      var content = await file.readAsString();
      print(content);
    }
    else{
      print("file not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('折れ線グラフ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: screenWidth * 0.95,
          height: screenWidth * 0.95 * 0.65,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(1, 0),
                    FlSpot(2, 400),
                    FlSpot(3, 650),
                    FlSpot(4, 800),
                    FlSpot(5, 870),
                    FlSpot(6, 920),
                    FlSpot(7, 960),
                    FlSpot(8, 980),
                    FlSpot(9, 990),
                    FlSpot(10, 995),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                ),
              ],
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  axisNameWidget: Text(
                    "ステップ速度",
                  ),
                  axisNameSize: 35.0,
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              maxY: 1000,
              minY: 0,
            ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     // TRY THIS: Try changing the color here to a specific color (to
    //     // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
    //     // change color while the other colors stay the same.
    //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //     // Here we take the value from the MyHomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     title: Text(widget.title),
    //   ),
    //   body: Center(
    //     // Center is a layout widget. It takes a single child and positions it
    //     // in the middle of the parent.
    //     child: Column(
    //       // Column is also a layout widget. It takes a list of children and
    //       // arranges them vertically. By default, it sizes itself to fit its
    //       // children horizontally, and tries to be as tall as its parent.
    //       //
    //       // Column has various properties to control how it sizes itself and
    //       // how it positions its children. Here we use mainAxisAlignment to
    //       // center the children vertically; the main axis here is the vertical
    //       // axis because Columns are vertical (the cross axis would be
    //       // horizontal).
    //       //
    //       // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
    //       // action in the IDE, or press "p" in the console), to see the
    //       // wireframe for each widget.
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         const Text(
    //           'You have pushed the button this many times:',
    //         ),
    //         Text(
    //           '$_counter',
    //           style: Theme.of(context).textTheme.headlineMedium,
    //         ),
    //       ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
  }
}
