import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_games_collection/managers/segment_manager.dart';
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

class EmberQuest extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents{
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;
  double objectSpeed = 0.0;
  late EmberPlayer _ember;

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void initializeGame() {
    // Assume that size.x < 3200
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);
    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }
    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 128),
    );
    world.add(_ember);
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case const (GroundBlock):
          world.add(
            GroundBlock(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
        case const (PlatformBlock):
          add(
            PlatformBlock(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
        case const (Star):
          world.add(
            Star(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
        case const (WaterEnemy):
          world.add(
            WaterEnemy(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
      }
    }
  }

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
    initializeGame();
  }
}

class EmberPlayer extends SpriteAnimationComponent with KeyboardHandler, CollisionCallbacks, HasGameReference<EmberQuest> {
  EmberPlayer({
    required super.position,
  }) : super(
    size: Vector2.all(64), 
    anchor: Anchor.center
  );
  
  final Vector2 velocity = Vector2.zero();
  final Vector2 fromAbove = Vector2(0, -1);
  final double moveSpeed = 200;
  final double gravity = 15;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;
  int horizontalDirection = 0;
  bool isOnGround = false;
  bool hasJumped = false;
  bool hitByEnemy = false;

  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    position += velocity * dt;
    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }
    // Apply basic gravity
    velocity.y += gravity;
    // Determine if ember has jumped
    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }
    // Prevent ember from jumping to crazy fast as well as descending too fast and 
    // crashing through the ground or a platform.
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);
    game.objectSpeed = 0;
    // Prevent ember from going backwards at screen edge.
    if (position.x - 36 <= 0 && horizontalDirection < 0) {
      velocity.x = 0;
    }
    // Prevent ember from going beyond half screen.
    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      game.objectSpeed = -moveSpeed;
    }
    position += velocity * dt;
    super.update(dt);
  }

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
    add(CircleHitbox());
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft))
    ? -1
    : 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight))
    ? 1
    : 0;
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;
        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();
        // If collision normal is almost upwards,
        // ember must be on ground.
        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }
        // Resolve collision by moving ember along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }
    if (other is Star) {
      other.removeFromParent();
    }
    if (other is WaterEnemy) {
      hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  // This method runs an opacity effect on ember
  // to make it blink.
  void hit() {
    if (!hitByEnemy) {
      hitByEnemy = true;
    }
    add(
      OpacityEffect.fadeOut(
      EffectController(
        alternate: true,
        duration: 0.1,
        repeatCount: 6,
      ),
      )..onComplete = () {
        hitByEnemy = false;
      },
    );
  }
}

class GroundBlock extends SpriteComponent with HasGameReference<EmberQuest> {
  final Vector2 gridPosition;
  double xOffset;

  final UniqueKey _blockKey = UniqueKey();
  final Vector2 velocity = Vector2.zero();

  GroundBlock({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    final groundImage = game.images.fromCache(EmberQuestAssetImages.ground);
    sprite = Sprite(groundImage);
    position = Vector2(
      gridPosition.x * size.x + xOffset,
      game.size.y - gridPosition.y * size.y,
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
    if (gridPosition.x == 9 && position.x > game.lastBlockXPosition) {
      game.lastBlockKey = _blockKey;
      game.lastBlockXPosition = position.x + size.x;
    }
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x) {
      removeFromParent();
      if (gridPosition.x == 0) {
        game.loadGameSegments(
          Random().nextInt(segments.length),
          game.lastBlockXPosition,
        );
      }
    }
    if (gridPosition.x == 9) {
      if (game.lastBlockKey == _blockKey) {
        game.lastBlockXPosition = position.x + size.x - 10;
      }
    }
    super.update(dt);
  }
}

class PlatformBlock extends SpriteComponent with HasGameReference<EmberQuest> {
  final Vector2 velocity = Vector2.zero();
  final Vector2 gridPosition;
  double xOffset;

  PlatformBlock({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    final platformImage = game.images.fromCache(EmberQuestAssetImages.block);
    sprite = Sprite(platformImage);
    position = Vector2((gridPosition.x * size.x) + xOffset,
      game.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x) removeFromParent();
    super.update(dt);
  }
}

class Star extends SpriteComponent with HasGameReference<EmberQuest> {
  final Vector2 gridPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();

  Star({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  void onLoad() {
    final starImage = game.images.fromCache(EmberQuestAssetImages.star);
    sprite = Sprite(starImage);
    position = Vector2(
      (gridPosition.x * size.x) + xOffset + (size.x / 2),
      game.size.y - (gridPosition.y * size.y) - (size.y / 2),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
    add(
      SizeEffect.by(
        Vector2(-24, -24),
        EffectController(
          duration: .75,
          reverseDuration: .5,
          infinite: true,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x) removeFromParent();
    super.update(dt);
  }
}

class WaterEnemy extends SpriteAnimationComponent with HasGameReference<EmberQuest> {
  final Vector2 gridPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();

  WaterEnemy({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(EmberQuestAssetImages.waterEnemy),
      SpriteAnimationData.sequenced(
        amount: 2,
        textureSize: Vector2.all(16),
        stepTime: 0.70,
      ),
    );
    position = Vector2(
      (gridPosition.x * size.x) + xOffset,
      game.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
    add(
      MoveEffect.by(
        Vector2(-2 * size.x, 0),
        EffectController(
          duration: 3,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x) removeFromParent();
    super.update(dt);
  }
}