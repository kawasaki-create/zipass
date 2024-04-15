import 'package:flutter/material.dart';
import 'package:zipass/routes/home_route.dart';
import 'package:zipass/routes/saved_route.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  int _selectedIndex = 0;
  var _bottomNavigationBarItems = <BottomNavigationBarItem>[];

  //アイコン情報
  static const _RootWidgetIcons = [Icons.home, Icons.save];
  //アイコン文字列
  static const _RootWidgetItemNames = ['ホーム', '保存済み'];

  late var _routes = [
    Home(),
    Saved(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ボトムナビゲーションバーのアイテムを更新
    _bottomNavigationBarItems = List.generate(
      _RootWidgetItemNames.length,
      (index) => index == _selectedIndex ? _UpdateActiveState(index) : _UpdateDeactiveState(index),
    );
  }

  /// インデックスのアイテムをアクティベートする
  BottomNavigationBarItem _UpdateActiveState(int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        _RootWidgetIcons[index],
        color: Colors.black87,
      ),
      label: _RootWidgetItemNames[index],
    );
  }

  /// インデックスのアイテムをディアクティベートする
  BottomNavigationBarItem _UpdateDeactiveState(int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        _RootWidgetIcons[index],
        color: Colors.black26,
      ),
      label: _RootWidgetItemNames[index],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavigationBarItems[_selectedIndex] = _UpdateDeactiveState(_selectedIndex);
      _bottomNavigationBarItems[index] = _UpdateActiveState(index);
      _selectedIndex = index;

      // 旅行一覧のインデックスを1に設定
      if (index == 1) {
        _selectedIndex = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Column(
        children: [
          Expanded(
            child: _routes.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _bottomNavigationBarItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
