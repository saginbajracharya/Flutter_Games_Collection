import 'package:flutter/material.dart';
import 'package:flutter_games_collection/games/epictd.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title
          Text('Fluter Games Collection',style: headingTextStyle),
          const SizedBox(height: 20),
          Text('3 in 1',style: headingTextStyle),
          const SizedBox(height: 50),
          // Space Shooter
          CustomListItem(
            trailingText: '1', 
            titleText: 'Space Shooter', 
            onTap: () async{  
              Get.to(()=>const SpaceShooterMenuPage());
            },
          ),
          // Ember Quest
          CustomListItem(
            trailingText: '2', 
            titleText: 'Ember Quest', 
            onTap: () async{  
              Get.to(()=>const EmberQuestMenuPage());
            },
          ),
          // Ember Quest
          CustomListItem(
            trailingText: '3', 
            titleText: 'Epic TD', 
            onTap: () async{  
              Get.to(()=>const EpicTdMenuPage());
            },
          )
        ],
      ) 
    );
  }
}
