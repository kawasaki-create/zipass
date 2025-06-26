import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zipass/routes/home_route.dart';
import 'package:zipass/routes/saved_route.dart';
import 'package:zipass/routes/tutorial_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zipass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Noto Sans JP',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Zipass'),
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
  int _selectedIndex = 0;
  var _bottomNavigationBarItems = <BottomNavigationBarItem>[];

  //アイコン情報
  static const _RootWidgetIcons = [Icons.home, Icons.save];
  //アイコン文字列
  static const _RootWidgetItemNames = ['ホーム', '保存済み'];

  late var _routes = [
    Home(),
    Saved(),
    Tutorial(),
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavigationBarItems = List.generate(
      _RootWidgetItemNames.length,
      (index) => BottomNavigationBarItem(
        icon: Icon(_RootWidgetIcons[index]),
        label: _RootWidgetItemNames[index],
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _routes,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: '保存済み',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Tutorial()),
          );
        },
        icon: const Icon(Icons.help_outline),
        label: const Text('ヘルプ'),
        tooltip: 'チュートリアルを表示',
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
