import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_games_collection/game_list_page.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

// MyApp with GetMaterialApp 
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      popGesture                : false,
      useInheritedMediaQuery    : false,
      debugShowCheckedModeBanner: false,
      transitionDuration        : Duration(milliseconds: 300),
      defaultTransition         : Transition.fadeIn,
      opaqueRoute               : true,
      supportedLocales          : [
        Locale('en', ''),       // English, no country code
        Locale('ne', ''),       // Nepali, no country code
      ],
      fallbackLocale            : Locale('en', ''),
      home                      : GamesListPage(),
    );
  }
}
