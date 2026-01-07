import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/page_search.dart';
import 'pages/page_request.dart';
import 'pages/page_work.dart';
import 'pages/page_message.dart';
import 'pages/page_account.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yorozuya App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0 ;
  static final List<Widget> _pages = <Widget>[
    const PageSearch(),
    const PageRequest(),
    const PageWork(),
    const PageMessage(),
    const PageAccount(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: 24.0,
        // 5つのアイテムを均等に配置するための設定
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue, // 選択時の色（適宜変更してください）
        unselectedItemColor: Colors.grey,
        // 以前のコードのラベルスタイル
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '探す'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'いらい'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'はたらく'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'メッセージ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'アカウント'),
        ],
      ),
    );
  }
}
