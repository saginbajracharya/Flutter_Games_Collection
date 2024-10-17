import 'package:flutter/material.dart';
import 'package:flutter_games_collection/common/styles.dart';
import 'package:flutter_games_collection/widgets/base_scaffold_layout.dart';
import 'package:get/get.dart';

import 'common/read_write_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final SettingsController settingsCon = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    settingsCon.loadSavedSettings();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldLayout(
      extendBehindAppBar: false,
      showScrollBar: true,
      appbar: AppBar(
        backgroundColor: transparent,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: white,
        ),
        title: Text('settings'.tr,style: textLargeWhite()),
        centerTitle: true,
      ),
      bodyContentAlignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language dropdown selection
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5), // Adjust the color and width as needed
                borderRadius: BorderRadius.circular(10), // Optional: to give rounded corners
              ),
              padding: const EdgeInsets.only(left: 20.0,right:20.0,top: 10.0,bottom: 5.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: settingsCon.selectedLanguage == "" ? 'en' : settingsCon.selectedLanguage,
                dropdownColor: black,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      settingsCon.selectedLanguage = newValue;
                    });
                    write(StorageKeys.selectedLocaleKey, newValue);
                    var locale = Locale(newValue);
                    Get.updateLocale(locale);
                  }
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'en',
                    child: Text('english'.tr, style: textSmallWhite()),
                  ),
                  DropdownMenuItem<String>(
                    value: 'jp',
                    child: Text('japanese'.tr, style: textSmallWhite()),
                  ),
                  DropdownMenuItem<String>(
                    value: 'np',
                    child: Text('nepal'.tr, style: textSmallWhite()),
                  ),
                ],
                underline: Container(), // Remove default underline
                icon: const Icon(Icons.arrow_drop_down, color: white),
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          // Music Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40, // Adjust the size based on your need
                height: 40,
                child: Checkbox(
                  value: settingsCon.isMusicEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      settingsCon.isMusicEnabled = value ?? false;
                    });
                  },
                  activeColor: green,
                  checkColor: white,
                ),
              ),
              const SizedBox(width: 10.0),
              Text('music'.tr, style: textSmallWhite()),
            ],
          ),
          const SizedBox(height: 30.0),
          // Sound Selection
          Row(
            children: [
              SizedBox(
                width: 40, // Adjust the size based on your need
                height: 40,
                child: Checkbox(
                  value: settingsCon.isSoundEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      settingsCon.isSoundEnabled = value ?? false;
                    });
                  },
                  activeColor: green,
                  checkColor: white,
                ),
              ),
              const SizedBox(width: 8.0),
              Text('sound'.tr, style: textSmallWhite()),
            ],
          ),
          const SizedBox(height: 30.0),
        ],
      ) 
    );
  }
}

class SettingsController extends GetxController{
  String selectedLanguage = 'en';
  bool isMusicEnabled = true;
  bool isSoundEnabled = true;

  loadSavedSettings()async{
    dynamic savedSelectedLocale = read(StorageKeys.selectedLocaleKey);
    selectedLanguage = savedSelectedLocale??'en';
  }
}