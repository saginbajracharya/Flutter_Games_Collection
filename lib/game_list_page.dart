import 'dart:ui';

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
import 'package:ultimate_particle_fx/particles_enum/movement_direction.dart';
import 'package:ultimate_particle_fx/particles_enum/particle_shapes.dart';
import 'package:ultimate_particle_fx/particles_enum/spawn_position.dart';
import 'package:ultimate_particle_fx/particles_enum/touch_type.dart';
import 'package:ultimate_particle_fx/ultimate_particle_fx.dart';
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
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-60,
        child: UltimateParticleFx(
          neverEnding: true,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          velocity: const Offset(0, 0),
          position: const Offset(0, 0),
          colors : const [Colors.green,Colors.yellow,Colors.red,Colors.blue],
          maxSize: 10.0,
          minSize: 5.0,
          lifespan: 2000,
          maxParticles: 100,
          speed: 0.4,
          rotation: 0,
          shapes: const [
            ParticleShape.circle, 
            ParticleShape.square, 
            ParticleShape.triangle,
            ParticleShape.star,
            ParticleShape.hexagon,
            ParticleShape.diamond,
            ParticleShape.pentagon,
            ParticleShape.ellipse,
            ParticleShape.cross,
            ParticleShape.heart,
            ParticleShape.octagon,
          ],
          gradient: const LinearGradient(
            colors: [Colors.red,Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0]
          ),
          allowParticlesExitSpawnArea : false,
          spawnAreaPosition : const Offset(0, 0),
          spawnPosition : SpawnPosition.random,
          movementDirection : MovementDirection.random,
          spawnAreaWidth: MediaQuery.of(context).size.width,
          spawnAreaHeight: MediaQuery.of(context).size.height,
          spawnAreaColor : Colors.transparent,
          touchType: TouchType.push,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Center(
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
              ),
            ),
          ),
        ),
      ) 
    );
  }
}
