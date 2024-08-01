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
      extendBehindAppBar: true,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DropdownButton<String>(
              isExpanded: true,
              value: settingsCon.selectedLanguage==""?'en':settingsCon.selectedLanguage,
              dropdownColor: black,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    settingsCon.selectedLanguage = newValue;
                  });
                  write(StorageKeys.selectedLocaleKey,newValue);
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
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: settingsCon.isMusicEnabled,
                    onChanged: (bool? value) {
                      setState(() {
                        settingsCon.isMusicEnabled = value ?? false;
                      });
                    },
                    activeColor: green,
                    checkColor: white,
                  ),
                  const SizedBox(width: 8.0),
                  Text('music'.tr, style: textSmallWhite()),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: settingsCon.isSoundEnabled,
                    onChanged: (bool? value) {
                      setState(() {
                        settingsCon.isSoundEnabled = value ?? false;
                      });
                    },
                    activeColor: green,
                    checkColor: white,
                  ),
                  const SizedBox(width: 8.0),
                  Text('sound'.tr, style: textSmallWhite()),
                ],
              ),
            ],
          ),
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