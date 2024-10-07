import 'package:flutter/material.dart';
import 'package:flutter_games_collection/games/charactermovement.dart';
import 'package:flutter_games_collection/games/epictd.dart';
import 'package:flutter_games_collection/games/pushpuzzle.dart';
import 'package:flutter_games_collection/settings_page.dart';
import 'package:get/get.dart';
import 'package:flutter_games_collection/games/emberquest.dart';
import 'package:flutter_games_collection/games/spaceshooter.dart';
import 'package:flutter_games_collection/widgets/base_scaffold_layout.dart';
import 'package:flutter_games_collection/widgets/custom_list_item.dart';
import 'common/styles.dart';

// All List of Games
class GamesListPage extends StatefulWidget {
  const GamesListPage({super.key});

  @override
  State<GamesListPage> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffoldLayout(
      extendBehindAppBar: true,
      appbar: AppBar(
        centerTitle: true,
        backgroundColor: transparent,
        actions: [
          IconButton(
            onPressed: (){
              Get.to(()=>const SettingsPage());
            }, 
            icon: const Icon(Icons.settings,color: white)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text('title'.tr,style: textLargeWhite()),
          const SizedBox(height: 20),
          Text('subTitle'.tr,style: textLargeWhite()),
          const SizedBox(height: 50),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Space Shooter
              CustomListItem(
                trailingText: '1', 
                titleText: 'game1Title'.tr, 
                onTap: () async{  
                  Get.to(()=>const SpaceShooterMenuPage());
                },
              ),
              // Ember Quest
              CustomListItem(
                trailingText: '2', 
                titleText: 'game2Title'.tr, 
                onTap: () async{  
                  Get.to(()=>const EmberQuestMenuPage());
                },
              ),
              // Epic TD
              CustomListItem(
                trailingText: '3', 
                titleText: 'game3Title'.tr, 
                onTap: () async{  
                  Get.to(()=>const EpicTdMenuPage());
                },
              ),
              // Push Puzzle
              CustomListItem(
                trailingText: '4', 
                titleText: 'game4Title'.tr, 
                onTap: () async{  
                  Get.to(()=>const PushPuzzleMenuPage());
                },
              ),
              // Character Movement
              CustomListItem(
                trailingText: '5', 
                titleText: 'game5Title'.tr, 
                onTap: () async{  
                  Get.to(()=>const CharacterMovementMenuPage());
                },
              )
            ],
          ),
        ],
      ) 
    );
  }
}
