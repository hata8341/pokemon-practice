import 'package:flutter/material.dart';
import 'package:pokepoke/models/favorite.dart';
import 'package:pokepoke/models/pokemon.dart';
import 'package:pokepoke/models/theme_mode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './poke_list.dart';
import './settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final themeModeNotifier = ThemeModeNotifier(pref);
  final pokemonsNotifer = PokemonsNotifer();
  final favoritesNotifier = FavoritesNotifier();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeModeNotifier>(
        create: (context) => themeModeNotifier,
      ),
      ChangeNotifierProvider<PokemonsNotifer>(
        create: (context) => pokemonsNotifer,
      ),
      ChangeNotifierProvider<FavoritesNotifier>(
        create: (context) => favoritesNotifier,
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
        builder: (context, mode, child) => MaterialApp(
              title: 'Pokemon Flutter',
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: mode.mode,
              home: const TopPage(),
            ));
  }
}

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  int currentbnb = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 画面の表示を設定に切り替えた場合でもpokeListの状態保持するためにindexedStackを使用
        child: IndexedStack(
          children: const [PokeList(), Settings()],
          index: currentbnb,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => {
          setState(
            () {
              print(index);
              currentbnb = index;
            },
          )
        },
        currentIndex: currentbnb,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
