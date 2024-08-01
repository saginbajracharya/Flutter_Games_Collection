import 'package:flutter_games_collection/settings_page.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_games_collection/game_list_page.dart';

import 'common/translations.dart';

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
  final SettingsController settingsCon = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    settingsCon.loadSavedSettings();
  }
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      popGesture                : false,
      useInheritedMediaQuery    : false,
      debugShowCheckedModeBanner: false,
      transitionDuration        : const Duration(milliseconds: 300),
      defaultTransition         : Transition.fadeIn,
      opaqueRoute               : true,
      translations              : AppTranslations(),
      locale                    : Locale(settingsCon.selectedLanguage==""?'en':settingsCon.selectedLanguage,''),
      fallbackLocale            : const Locale('en', ''),
      home                      : const GamesListPage(),
    );
  }
}
