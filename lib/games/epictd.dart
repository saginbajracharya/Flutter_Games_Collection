import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:get/get.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_games_collection/common/styles.dart';
import 'package:flutter_games_collection/common/constant.dart';
import 'package:flutter_games_collection/managers/play_pause_manager.dart';
import 'package:flutter_games_collection/managers/score_state_manager.dart';
import 'package:flutter_games_collection/widgets/base_scaffold_layout.dart';

final ScoreStateManager scoreStateManager = Get.put(ScoreStateManager());
final PlayPauseManager playPauseManager = Get.put(PlayPauseManager());

// Menu Page
// Title And Play Button
class EpicTdMenuPage extends StatefulWidget {
  const EpicTdMenuPage({super.key});

  @override
  State<EpicTdMenuPage> createState() => _EpicTdMenuPageState();
}

class _EpicTdMenuPageState extends State<EpicTdMenuPage> {

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
            'Epic TD',
            style: headingTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100),
          // Play Button
          ElevatedButton(
            onPressed: ()async{
              Get.to(
                () => Scaffold(
                  body : GameWidget(
                    game: EpicTd(),
                    overlayBuilderMap: {
                      'ScoreOverlay': (context, game) {
                        return Padding(
                          padding: const EdgeInsets.only(top:10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
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
                              Align(
                                alignment: Alignment.topCenter,
                                child: Obx(() => Padding(
                                  padding: const EdgeInsets.only(top:12.0),
                                  child: Text(
                                      'Score : ${scoreStateManager.spaceShooterScore}',
                                      style: normalTextStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                ),
                                ),
                              ),
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
                                    foregroundColor: transparent, backgroundColor: transparent,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ), 
                                  // Navigate to SpaceShooterGame on tap
                                  child: Obx(() => Image.asset(
                                    playPauseManager.spaceShooterPaused.value?CommonAssetImages.playbtn:CommonAssetImages.pausebtn,
                                    width: 50.0,
                                    height: 50.0,
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
          // Obx(()=> Text(
          //     'High Score : ${scoreStateManager.savedSpaceShooterhighscore()}',
          //     style: headingTextStyle,
          //     textAlign: TextAlign.center,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class EpicTd extends FlameGame with TapCallbacks,HasCollisionDetection {
  double zoom = 1.0; // Initial zoom level
  double minZoom = 0.5; // Minimum zoom level
  double maxZoom = 2.0; // Maximum zoom level
  double zoomSpeed = 0.05; // Zoom speed

  TapDownInfo? onTapDownInfo;
  bool _isWaveActive = false;
  String _selectedTowerType = 'default';
  final towerSelection = TowerSelection([
    TowerData('archer', 'epictd/tower_1.png', 100,80),
    TowerData('cannon', 'epictd/tower_2.png', 150,60),
  ]);
  late GoalComponent goal;
  double playerHealth = 100;
  double reducePlayerHealth = 1;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load assets
    await images.loadAll([
      EpicTdAssetImages.tower1,
      EpicTdAssetImages.tower2,
      EpicTdAssetImages.enemy,
    ]);
    goal = GoalComponent()..position = Vector2(size.x/2, size.y/1.1);
    add(goal);
    add(HudOverlay());
  }

  void startWave() {
    if (!_isWaveActive) {
      _isWaveActive = true;
      addWave();
    }
  }

  void addWave() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isWaveActive) {
        final enemy = EnemyComponent(goal)..position = Vector2(0, 100);
        add(enemy);
        addWave();
      }
    });
  }

  void selectTower(String towerType) {
    _selectedTowerType = towerType;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Handle zoom in and out
    final tapPosition = event.localPosition;
    if (tapPosition.x < 50 && tapPosition.y < 50) {
      // Zoom in when tapping in the top left corner
      zoom = (zoom + zoomSpeed).clamp(minZoom, maxZoom);
    } else if (tapPosition.x > size.x - 50 && tapPosition.y < 50) {
      // Zoom out when tapping in the top right corner
      zoom = (zoom - zoomSpeed).clamp(minZoom, maxZoom);
    } else {
      // Place tower if not zooming
      // Check if a tower already exists at this position...
      final towerPosition = event.localPosition;
      // Check if a tower already exists at this position
      bool positionOccupied = children.any((child) {
        if (child is TowerComponent) {
          return child.position.distanceTo(towerPosition) < 64; // Adjust distance as needed
        }
        return false;
      });
      if (!positionOccupied) {
        final tower = TowerComponent(type: _selectedTowerType)..position = towerPosition;
        add(tower);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Apply zoom to the canvas
    canvas.save();
    canvas.scale(zoom);

    // Render your game elements...
    super.render(canvas);

    // Restore the canvas to its original state
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle wave start button press
    if (onTapDownInfo != null && onTapDownInfo!.eventPosition.widget.y > size.y - 70) {
      startWave();
    }
    // Reset onTapDownInfo after handling the press
    onTapDownInfo = null;
  }

  void reduceHealth(double amount) {
    if(playerHealth==0.0){
      Get.back();
    }
    else{
      playerHealth -= amount;
    }
  }
}

class TowerComponent extends SpriteComponent with HasGameRef<EpicTd>,CollisionCallbacks {
  final String type;
  late double range; // Define the range of the tower
  late final CircleComponent rangeIndicator;
  double shootCooldown = 1.0; // Time between shots
  double timeSinceLastShot = 0.0;

  TowerComponent({this.type = 'default'}) : super(size: Vector2(64, 64));

  @override
  Future<void> onLoad() async {
    range = getRange(type);
    // Load sprite based on towerData.type
    sprite = await gameRef.loadSprite(getSpritePath(type));
    // anchor = Anchor.center;

    // Add range indicator
    rangeIndicator = CircleComponent(
      radius: range,
      paint: Paint()..color = blue.withOpacity(0.2),
      anchor: Anchor.center,
    );
    rangeIndicator.position = size/2.1;

    add(rangeIndicator);
    add(RectangleHitbox(collisionType: CollisionType.passive)); // Make the tower passively block movement
  }

  String getSpritePath(String type) {
    switch (type) {
      case 'archer':
        return EpicTdAssetImages.tower1;
      case 'cannon':
        return EpicTdAssetImages.tower2;
      // Add cases for other tower types
      default:
        return EpicTdAssetImages.tower1; // Default case
    }
  }

  double getRange(String type) {
    final tower = game.towerSelection.towers.firstWhere(
      (tower) => tower.type == type,
      orElse: () => TowerData('archer', 'epictd/tower_1.png', 100,80),
    );
    return tower.range.toDouble();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update shooting cooldown
    timeSinceLastShot += dt;

    // Implement tower shooting logic here
    final enemies = gameRef.children.whereType<EnemyComponent>();
    if (enemies.isNotEmpty && timeSinceLastShot >= shootCooldown) {
      final enemy = enemies.reduce((a, b) => (a.position.distanceTo(position) < b.position.distanceTo(position)) ? a : b);
      if (enemy.position.distanceTo(position) <= range) {
        shoot(enemy);
        timeSinceLastShot = 0.0;
      }
    }
  }

  void shoot(EnemyComponent enemy) {
    final bullet = BulletComponent(enemy.position, position: position, range: getRange(type));
    gameRef.add(bullet);
  }
}

class BulletComponent extends SpriteAnimationComponent with HasGameRef<EpicTd>, CollisionCallbacks {
  final Vector2 targetPosition;
  final double speed = 300;
  final double range;
  final Vector2 startPosition;

  BulletComponent(this.targetPosition, {Vector2? position, this.range = 100})
  : startPosition = position ?? Vector2.zero(),
  super(size: Vector2(25, 50), position: position ?? Vector2.zero(), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      EpicTdAssetImages.bullet,
      SpriteAnimationData.sequenced(
        amount: 1, // Number of frames in the animation
        stepTime: 0.5, // Time interval between frames
        textureSize: Vector2(20, 20), // Size of each frame
      ),
    );

    add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Find the closest enemy
    final enemies = gameRef.children.whereType<EnemyComponent>();
    if (enemies.isNotEmpty) {
      final closestEnemy = enemies.reduce((a, b) => (a.position.distanceTo(position) < b.position.distanceTo(position)) ? a : b);
      // Update the direction to point towards the closest enemy
      final direction = (closestEnemy.position - position).normalized();
      // Update the angle to point towards the direction of movement
      angle = atan2(direction.y, direction.x);
      // Move the bullet towards the enemy
      position += direction * speed * dt;
      // Check if bullet collides with the enemy
      if (closestEnemy.position.distanceTo(position) < 5) {
        closestEnemy.takeDamage(1);
        removeFromParent();
      }
    } else {
      // If no enemies, remove the bullet
      removeFromParent();
    }
    // Check if bullet is out of range
    if (position.distanceTo(startPosition) > range) {
      removeFromParent();
    }
  }
}

class EnemyComponent extends SpriteComponent with HasGameRef<EpicTd> ,CollisionCallbacks{
  final GoalComponent goal;
  double health = 100;

  EnemyComponent(this.goal) : super(size: Vector2(32, 32));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(EpicTdAssetImages.enemy);
    anchor = Anchor.center;
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = (goal.position - position).normalized();
    position += direction * 50 * dt; // Move enemy to the goal

    if (position.distanceTo(goal.position) < 32) {
      gameRef.reduceHealth(gameRef.reducePlayerHealth);
      removeFromParent();
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is TowerComponent) {
      // Adjust the position or stop the enemy
      position -= (goal.position - position).normalized() * 50 * x;
    }
  }
}

class GoalComponent extends PositionComponent with HasGameRef<EpicTd> {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(40, 40);
    // Add background image
    final backgroundSprite = SpriteComponent(
      sprite: await gameRef.loadSprite(EpicTdAssetImages.towerBtn),
      size: size, // Make it the same size as the button
    );
    add(backgroundSprite);
  }
}

class TowerSelection extends Component with HasGameRef<EpicTd> {
  final List<TowerData> towers;

  TowerSelection(this.towers);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add tower selection buttons
    for (var i = 0; i < towers.length; i++) {
      final towerData = towers[i];
      final button = TowerButton(towerData, i, gameRef.selectTower);
      add(button);
    }
  }
}

class TowerButton extends PositionComponent with TapCallbacks, HasGameRef<EpicTd> {
  final TowerData towerData;
  final int index;
  final void Function(String) onSelect;

  TowerButton(this.towerData, this.index, this.onSelect)
  : super(
    size: Vector2(64, 64),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add background image
    final backgroundSprite = SpriteComponent(
      sprite: await gameRef.loadSprite(EpicTdAssetImages.towerBtn),
      size: size, // Make it the same size as the button
    );
    add(backgroundSprite);

    // Add tower image at the top of the button
    final spriteComponent = SpriteComponent(
      sprite: await gameRef.loadSprite(towerData.iconPath),
      size: Vector2(50, 50),
      position: Vector2(6, 5), // Adjust position to center the image at the top
    );
    add(spriteComponent);

    // Define TextPaint with smaller font size
    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 10, // Set the desired font size
        color: Colors.white, // Set text color as needed
      ),
    );

    // Add tower name at the bottom of the button
    final textComponent = TextComponent(
      text: towerData.type,
      position: Vector2(15, 60), // Adjust position to place the text at the bottom
      anchor: Anchor.bottomLeft,
      textRenderer: textPaint, // Use the defined TextPaint
    );
    add(textComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onSelect(towerData.type);
  }
}

class TowerData {
  final String type;
  final String iconPath;
  final int cost;
  final int range;

  TowerData(this.type, this.iconPath, this.cost,this.range);
}

class HudOverlay extends Component with HasGameReference<EpicTd> {
  late AdvancedButtonComponent _startWaveButton;
  late AdvancedButtonComponent _backButton;
  late List<TowerButton> _towerSelectionButtons;
  late TextComponent healthText;
  late dynamic towerSelection;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    towerSelection = game.towerSelection;
    healthText = TextComponent(
      text: 'Health: ${game.playerHealth}', // Replace with actual health variable
      anchor: Anchor.topLeft,
    );
    // Start Wave Button
    final buttonImage = await Flame.images.load('common/ui/Play_button_Circle.png');
    final defaultSkin = SpriteComponent(
      sprite: Sprite(buttonImage),
      size: Vector2(50, 50),
    );

    _startWaveButton = AdvancedButtonComponent(
      position: Vector2(game.size.x / 2 - 25, 10), 
      defaultSkin: defaultSkin,
      onPressed: () {
        game.startWave();
      },
    );

    // Back Button
    final backButtonImage = await Flame.images.load('common/ui/Back_button_Circle.png');
    final defaultBackBtnSkin = SpriteComponent(
      sprite: Sprite(backButtonImage),
      size: Vector2(50, 50),
    );
    _backButton = AdvancedButtonComponent(
      position: Vector2(game.size.x / 2 + 25, 10),
      defaultSkin: defaultBackBtnSkin,
      onPressed: () {
        Get.back();
      },
    );
    
    // Tower Selection Buttons
    _towerSelectionButtons = [];
    for (var i = 0; i < towerSelection.towers.length; i++) {
      final tower = towerSelection.towers[i];
      final button = TowerButton(
        tower,
        i,
        (selectedTowerType) {
          game.selectTower(selectedTowerType);
          // towerSelection.selectTower(tower);
        },
      );
      button.position = calculateButtonPosition(i);
      _towerSelectionButtons.add(button);
    }

    // Adjust healthText position as needed
    healthText.position = Vector2(10.0, 10.0);
    _startWaveButton.position = Vector2(
      game.size.x - _startWaveButton.width - 10.0, // Use width instead of preferredSize
      10.0,
    );

    _backButton.position = Vector2(
      game.size.x - _backButton.width - 60.0, // Use width instead of preferredSize
      10.0,
    );

    add(healthText);
    add(_startWaveButton);
    add(_backButton);
    for (final button in _towerSelectionButtons) {
      add(button);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update healthText based on actual health (replace with your logic)
    healthText.text = 'Health: ${game.playerHealth}'; // Assuming playerHealth exists in EpicTd
  }

  Vector2 calculateButtonPosition(int index) {
    const buttonWidth = 60.0; // Assuming all buttons have same width
    const buttonSpacing = 0.0; // Adjust spacing between buttons

    // Calculate x position starting from the left edge
    final xPosition = (index * (buttonWidth + buttonSpacing));

    // Calculate y position to be at the bottom with padding
    final yPosition = game.size.y - buttonWidth - 0.0;

    return Vector2(xPosition, yPosition);
  }
}



