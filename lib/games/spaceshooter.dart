import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_games_collection/common/constant.dart';
import 'package:flutter_games_collection/common/styles.dart';
import 'package:flutter_games_collection/managers/play_pause_manager.dart';
import 'package:flutter_games_collection/managers/score_state_manager.dart';
import 'package:flutter_games_collection/widgets/base_scaffold_layout.dart';

final ScoreStateManager scoreStateManager = Get.put(ScoreStateManager());
final PlayPauseManager playPauseManager = Get.put(PlayPauseManager());

// Menu Page
// Title And Play Button
class SpaceShooterMenuPage extends StatefulWidget {
  const SpaceShooterMenuPage({super.key});

  @override
  State<SpaceShooterMenuPage> createState() => _SpaceShooterMenuPageState();
}

class _SpaceShooterMenuPageState extends State<SpaceShooterMenuPage> {

  @override
  void initState() {
    super.initState();
    scoreStateManager.spaceShooterScore.value=0;
    scoreStateManager.readSpaceShooterHighScore();
  }

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
            'game1Title'.tr,
            style: textHugeWhite(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100),
          // Play Button
          ElevatedButton(
            onPressed: ()async{
              Get.to(
                () => Scaffold(
                  body : GameWidget(
                    game: SpaceShooterGame(),
                    overlayBuilderMap: {
                      'ScoreOverlay': (context, game) {
                        return Padding(
                          padding: const EdgeInsets.only(top:40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Back Button
                              Align(
                                alignment: Alignment.topRight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Get.back();
                                  }, 
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    foregroundColor: transparent, 
                                    backgroundColor: transparent, // Remove default button color
                                    padding: EdgeInsets.zero, // Remove default button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Add rounded corners
                                    ),
                                  ), // Navigate to SpaceShooterGame on tap
                                  child: Image.asset(
                                    CommonAssetImages.backbtn,
                                    width: 50.0,  // Adjust image width as needed
                                    height: 50.0, // Adjust image height as needed
                                  ),
                                )
                              ),
                              // Score
                              Align(
                                alignment: Alignment.topCenter,
                                child: Obx(() => Padding(
                                  padding: const EdgeInsets.only(top:12.0),
                                  child: Text(
                                    '${'score'.tr}${scoreStateManager.spaceShooterScore}',
                                    style: textSmallWhite(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ),
                              ),
                              // Play/Pause Button
                              Align(
                                alignment: Alignment.topRight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if(playPauseManager.spaceShooterPaused.value == true){
                                      playPauseManager.play();
                                    }
                                    else{
                                      playPauseManager.pause();
                                    }
                                  }, 
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    foregroundColor: transparent, backgroundColor: transparent, // Remove default button color
                                    padding: EdgeInsets.zero, // Remove default button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Add rounded corners
                                    ),
                                  ), // Navigate to SpaceShooterGame on tap
                                  child: Obx(() => Image.asset(
                                    playPauseManager.spaceShooterPaused.value?CommonAssetImages.playbtn:CommonAssetImages.pausebtn,
                                    width: 50.0,  // Adjust image width as needed
                                    height: 50.0, // Adjust image height as needed
                                  )),
                                )
                              ),
                            ],
                          ),
                        );
                      },
                    },
                  )
                )
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: transparent, 
              backgroundColor: transparent, 
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), 
              ),
            ), 
            child: Image.asset(
              CommonAssetImages.playbtn,
              width: 100.0,  
              height: 100.0, 
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
              foregroundColor: transparent, 
              backgroundColor: transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Image.asset(
              CommonAssetImages.exitbtn,
              width: 100.0,  
              height: 100.0,
            ),
          ),
          const SizedBox(height: 50),
          // High Score
          Obx(()=> Text(
              '${'highScore'.tr} ${scoreStateManager.savedSpaceShooterhighscore()}',
              style: textSmallWhite(),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Space Shooter Game Main Logic Here 
class SpaceShooterGame extends FlameGame with PanDetector ,HasCollisionDetection{
  late Player player;

  @override
  Future<void> onLoad() async {
    //Add Parallax background
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData(SpaceShooterAssetsImages.parallexBg0),
        ParallaxImageData(SpaceShooterAssetsImages.parallexBg1),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);
    overlays.add('ScoreOverlay');

    //Add Player
    player = Player();
    add(player);

    //Add Enemies Spawner
    add(
      SpawnComponent(
        factory: (index) {
          if(playPauseManager.spaceShooterPaused.value)
          {
            return PositionComponent();
          }
          else{
            return Enemy();
          }
        },
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, - Enemy.enemySize),
        autoStart: playPauseManager.spaceShooterPaused.value==false?true:false
      ),
    );
    //Add Rapid Fire Power Up Spawner
    add(
      SpawnComponent(
        factory: (index) {
          if(playPauseManager.spaceShooterPaused.value)
          {
            return PositionComponent();
          }
          else{
            return RapidFirePowerUp();
          }
        },
        period: 5,
        area: Rectangle.fromLTWH(0, 0, size.x, - Enemy.enemySize),
        autoStart: playPauseManager.spaceShooterPaused.value==false?true:false
      ),
    );
    //Add Shield Power Up Spawner
    add(
      SpawnComponent(
        factory: (index) {
          if(playPauseManager.spaceShooterPaused.value)
          {
            return PositionComponent();
          }
          else{
            return ShieldPowerUp();
          }
        },
        period: 6,
        area: Rectangle.fromLTWH(0, 0, size.x, - Enemy.enemySize),
        autoStart: playPauseManager.spaceShooterPaused.value==false?true:false
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playPauseManager.spaceShooterPaused.value==false) {
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }
}

// Player Sprite Animation Component
// Player starts the center position at the start of a game 
// Player has a Pan movement and start and stop shooting bullets features 
// Player has a hitbox so that when the enemy hits the player the Score is Reset
class Player extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks{
  Player()
  : super(
    size: Vector2(100, 150),
    anchor: Anchor.center,
  );

  late final SpawnComponent _bulletSpawner;

  // Rapid fire properties
  bool rapidFireMode = false;
  double rapidFireDuration = 0.0;
  final double normalFireRate = 0.3;  // Normal fire rate (time between shots)
  final double rapidFireRate = 0.1;   // Rapid fire rate (time between shots)

  // Shield properties
  bool hasShield = false;
  late Timer shieldTimer;
  SpriteComponent? shieldVisual;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      SpaceShooterAssetsImages.player,
      SpriteAnimationData.sequenced(
        amount: 4, // 4 frames
        stepTime: .2, // This sets the time interval between displaying each frame of the animation to 0.2 seconds.
        textureSize: Vector2(32, 48),
      ),
    );
    // Add Rectangular Collider/hitBox for the player 
    // Player collide with the enemy , reset the score
    add(
      RectangleHitbox(
        collisionType: CollisionType.active,
      ),
    );

    position = game.size / 2;

    _bulletSpawner = SpawnComponent(
      period: normalFireRate,
      selfPositioning: true,
      factory: (index) {
        return Bullet(
          position: position +
          Vector2(
            0,
            -height / 2,
          ),
        );
      },
      autoStart: false,
    );
    game.add(_bulletSpawner);

    // Initialize shield timer
    shieldTimer = Timer(0, onTick: disableShield, repeat: false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playPauseManager.spaceShooterPaused.value==false) {
    }
    // Check if rapid fire is active and update the timer
    if (rapidFireMode) {
      rapidFireDuration -= dt;

      // If the rapid fire time is over, switch back to normal mode
      if (rapidFireDuration <= 0) {
        deactivateRapidFire();
      }
    }

    // Update shield timer
    shieldTimer.update(dt);
  }

  void move(Vector2 delta) {
    if (playPauseManager.spaceShooterPaused.value==false) {
      position.add(delta);
    }
  }

  void startShooting() {
    if (playPauseManager.spaceShooterPaused.value==false) {
      _bulletSpawner.timer.start();
    }
  }

  void stopShooting() {
    if (playPauseManager.spaceShooterPaused.value==false) {
      _bulletSpawner.timer.stop();
    }
  }

  // Activate rapid fire mode for a specific duration
  void activateRapidFire(double duration) {
    rapidFireMode = true;
    rapidFireDuration = duration;
    _bulletSpawner.timer.stop();
    _bulletSpawner.period = rapidFireRate; // Set to rapid fire rate
    _bulletSpawner.timer.start();
  }

  // Deactivate rapid fire and switch back to normal fire rate
  void deactivateRapidFire() {
    rapidFireMode = false;
    _bulletSpawner.timer.stop();
    _bulletSpawner.period = normalFireRate;  // Reset to normal fire rate
    _bulletSpawner.timer.start();
  }

  // Method to activate the shield
  void activateShield(double duration) async{
    if (!hasShield) {
      hasShield = true;

      // Add the visual representation of the shield
      shieldVisual = SpriteComponent(
        sprite: await game.loadSprite(SpaceShooterAssetsImages.shieldPowerUp),  // Load your shield image asset
        size: size * 1.5,  // Make the shield larger than the player
        position: Vector2.zero(),
        anchor: Anchor.center,
      );

      add(shieldVisual!);  // Add shield visual to the player

      // Start the shield timer
      shieldTimer.stop();
      shieldTimer = Timer(duration, onTick: disableShield, repeat: false);
      shieldTimer.start();
    }
  }

  // Method to disable the shield
  void disableShield() {
    if (hasShield) {
      hasShield = false;

      // Remove the shield visual
      shieldVisual?.removeFromParent();
      shieldVisual = null;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (hasShield && other is Enemy) {
      // Prevent damage to the player if the shield is active
      other.removeFromParent();  // Destroy the enemy on collision when shield is active
    }
  }
}

// Bullet Sprite Animation Component
// Bullet are Spawaned when the player onPanStart is triggered at the position of the player which has velocity of moving upward
// Bullect Has RectangleHitbox on hit with the enemy show explosion and on hit the player the Score Resets  
class Bullet extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame> {
  Bullet({
    super.position,
  }) : super(
    size: Vector2(25, 50),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await game.loadSpriteAnimation(
      SpaceShooterAssetsImages.bullet,
      SpriteAnimationData.sequenced(
        amount: 4, // 4 frame
        stepTime: .2, // This sets the time interval between displaying each frame of the animation to 0.2 seconds.
        textureSize: Vector2(33, 33), 
      ),
    );
    // Add Rectangular Collider/hitBox for the bullet
    // Bullet collides with the Enemy and show the explosion 
    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playPauseManager.spaceShooterPaused.value==false) {
      position.y += dt * -500;
      if (position.y < -height) {
        removeFromParent();
      }
    }
  }
}

// Enemy Sprite Animation Component
// Enemy are Spawned at the top screen with in the device width at random position of the width preiodically every 1 sec
class Enemy extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame> ,CollisionCallbacks{
  Enemy({
    super.position,
  }) : super(
    size: Vector2.all(enemySize),
    anchor: Anchor.center,
  );

  static const enemySize = 50.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      SpaceShooterAssetsImages.enemy,
      SpriteAnimationData.sequenced(
        amount: 4, // 4 Frame
        stepTime: .2, // This sets the time interval between displaying each frame of the animation to 0.2 seconds.
        textureSize: Vector2.all(32),
      ),
    );

    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (playPauseManager.spaceShooterPaused.value==false) {
      position.y += dt * 250;
      if (position.y > game.size.y) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
      // Update score using EventManager
      scoreStateManager.updateSpaceShooterScore(scoreStateManager.spaceShooterScore.value+1);
    }
    else if (other is Player) {
      // Update score using EventManager
      game.add(Explosion(position: position));
      removeFromParent(); //remove the enemy from the parent
      scoreStateManager.updateSpaceShooterScore(0); // Reset The Score
    }
  }
}

// Explosion Sprite Animation Component
// Shows Explosion when the bullet collides with the Enemy then the Explosion is Instantiated at the collided position
class Explosion extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame> {
  Explosion({
    super.position,
  }) : super(
    size: Vector2.all(150),
    anchor: Anchor.center,
    removeOnFinish: true,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await game.loadSpriteAnimation(
      SpaceShooterAssetsImages.explosion,
      SpriteAnimationData.sequenced(
        amount: 4, // 4 frame
        stepTime: .2, // This sets the time interval between displaying each frame of the animation to 0.2 seconds.
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}

// Power Ups

// RapidFirePowerUp Sprite Animation Component
// RapidFirePowerUp are Spawned at the top screen with in the device width at random position of the width at random time 
class RapidFirePowerUp extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame> ,CollisionCallbacks{
  RapidFirePowerUp({
    super.position,
  }) : super(
    size: Vector2.all(powerUpSize),
    anchor: Anchor.center,
  );

  static const powerUpSize = 50.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      SpaceShooterAssetsImages.rapidFirePowerUp,
      SpriteAnimationData.sequenced(
        amount: 1, // 4 Frame
        stepTime: 1, // This sets the time interval between displaying each frame of the animation to 0.2 seconds.
        textureSize: Vector2.all(300),
      ),
    );

    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (playPauseManager.spaceShooterPaused.value==false) {
      position.y += dt * 250;
      if (position.y > game.size.y) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      // removeFromParent();
      // other.removeFromParent();
      // game.add(Explosion(position: position));
      // // Update score using EventManager
      // scoreStateManager.updateSpaceShooterScore(scoreStateManager.spaceShooterScore.value+1);
    }
    else if (other is Player) {
      other.activateRapidFire(5.0); // 5 seconds of rapid fire
      removeFromParent();  // Remove the power-up after collection
    }
  }
}

// ShieldPowerUp Sprite Animation Component
// ShieldPowerUp are Spawned at the top screen with in the device width at random position of the width at random time 
class ShieldPowerUp extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame> ,CollisionCallbacks{
  ShieldPowerUp({
    super.position,
  }) : super(
    size: Vector2.all(powerUpSize),
    anchor: Anchor.center,
  );

  static const powerUpSize = 50.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      SpaceShooterAssetsImages.shieldPowerUp,
      SpriteAnimationData.sequenced(
        amount: 1, // 4 Frame
        stepTime: 1, // This sets the time interval between displaying each frame of the animation to 0.2 seconds.
        textureSize: Vector2.all(300),
      ),
    );

    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (playPauseManager.spaceShooterPaused.value==false) {
      position.y += dt * 250;
      if (position.y > game.size.y) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      other.activateShield(5.0); // 5 seconds of Shield
      removeFromParent();  // Remove the power-up after collection
    }
  }
}