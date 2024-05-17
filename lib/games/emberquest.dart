import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_games_collection/common/constant.dart';
import 'package:flutter_games_collection/common/styles.dart';
import 'package:flutter_games_collection/widgets/base_scaffold_layout.dart';

class EmberQuestMenuPage extends StatefulWidget {
  const EmberQuestMenuPage({super.key});

  @override
  State<EmberQuestMenuPage> createState() => _EmberQuestMenuPageState();
}

//Ember Quest Menu Page
class _EmberQuestMenuPageState extends State<EmberQuestMenuPage> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffoldLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title
          Text(
            'Ember Quest',
            style: headingTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100),
          // Play Button
          ElevatedButton(
            onPressed: ()async{
              Get.to(
                () => const Scaffold(
                  body : GameWidget<EmberQuest>.controlled(
                    gameFactory: EmberQuest.new,
                  )
                )
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: transparent, backgroundColor: transparent, // Remove default button color
              padding: EdgeInsets.zero, // Remove default button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Add rounded corners
              ),
            ), // Navigate to SpaceShooterGame on tap
            child: Image.asset(
              CommonAssetImages.playbtn,
              width: 100.0,  // Adjust image width as needed
              height: 100.0, // Adjust image height as needed
            ),
          ),
          const SizedBox(height: 50),
          // Exit Button to list page
          ElevatedButton(
            onPressed: ()async{
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: transparent, backgroundColor: transparent, // Remove default button color
              padding: EdgeInsets.zero, // Remove default button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Add rounded corners
              ),
            ), // Navigate to SpaceShooterGame on tap
            child: Image.asset(
              CommonAssetImages.exitbtn,
              width: 100.0,  // Adjust image width as needed
              height: 100.0, // Adjust image height as needed
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class EmberQuest extends FlameGame{
  late EmberPlayer _ember;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      EmberQuestAssetImages.block,
      EmberQuestAssetImages.ember,
      EmberQuestAssetImages.ground,
      EmberQuestAssetImages.halfheart,
      EmberQuestAssetImages.heart,
      EmberQuestAssetImages.star,
      EmberQuestAssetImages.waterEnemy,
    ]);

    // Everything in this tutorial assumes that the position
    // of the `CameraComponent`s viewfinder (where the camera is looking)
    // is in the top left corner, that's why we set the anchor here.

    
    camera.viewfinder.anchor = Anchor.topLeft;
    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 70),
    );
    world.add(_ember);
  }
}

class EmberPlayer extends SpriteAnimationComponent with HasGameReference<EmberQuest> {
  EmberPlayer({
    required super.position,
  }) : super(
    size: Vector2.all(64), 
    anchor: Anchor.center
  );

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(EmberQuestAssetImages.ember),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
  }
}