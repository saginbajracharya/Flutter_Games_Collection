import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
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
                  body : GestureDetector(
                    onScaleStart: (details) {
                      // Handle scale start
                      EpicTd().handleScaleStart(details);
                    },
                    onScaleUpdate: (details) {
                      // Handle scale update
                      EpicTd().handleScaleUpdate(details);
                    },
                    child: GameWidget(
                      game: EpicTd(),
                      overlayBuilderMap: {
                        'HudOverlay': (BuildContext context, EpicTd game) {
                          return HudOverlayWidget(game: game);
                        },
                      },
                      initialActiveOverlays: const ['HudOverlay'],
                    ),
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
          // Total Coin
          Obx(()=> Text(
              'Coin : ${scoreStateManager.savedSpaceShooterhighscore()}',
              style: headingTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
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
  Vector2? lastScaleStart;
  Vector2 cameraPosition = Vector2.zero();
  double currentScale = 1.0;

  TapDownInfo? onTapDownInfo;
  bool _isWaveActive = false;
  String _selectedTowerType = 'default';
  final towerSelection = TowerSelection([
    TowerData('archer', 'epictd/tower_1.png', 100,80),
    TowerData('cannon', 'epictd/tower_2.png', 150,60),
    TowerData('1', 'epictd/tower_2.png', 150,90),
    TowerData('2', 'epictd/tower_2.png', 150,120),
    TowerData('3', 'epictd/tower_2.png', 150,110),
    TowerData('4', 'epictd/tower_2.png', 150,85),
    TowerData('5', 'epictd/tower_2.png', 150,40),
    TowerData('6', 'epictd/tower_1.png', 100,90),
    TowerData('7', 'epictd/tower_2.png', 150,30),
  ]);
  late GoalComponent goal;
  final ValueNotifier<int> playerHealthNotifier = ValueNotifier<int>(100);
  int defaultReducePlayerHealth = 1;
  int defaultTakeHealthDamage = 50;
  final ValueNotifier<int> totalCoin = ValueNotifier<int>(0);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Center the camera on the game world
    final fixedResolutionViewport = FixedResolutionViewport(
      resolution: Vector2(size.x, size.y),
    );
    camera.viewport = fixedResolutionViewport;

    // Load assets
    await images.loadAll([
      EpicTdAssetImages.tower1,
      EpicTdAssetImages.tower2,
      EpicTdAssetImages.enemy,
    ]);
    goal = GoalComponent()..position = Vector2(size.x/2, size.y/1.1);
    add(goal);
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
        final enemy = EnemyComponent(goal)..position = Vector2(size.x/2, 0);
        add(enemy);
        addWave();
      }
    });
  }

  void selectTower(String towerType) {
    _selectedTowerType = towerType;
  }

  void handleScaleStart(ScaleStartDetails details) {
    lastScaleStart = details.focalPoint.toVector2();
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      zoom = (zoom * details.scale).clamp(minZoom, maxZoom);
      currentScale = details.scale;
    }

    if (details.focalPointDelta != Offset.zero) {
      cameraPosition += details.focalPointDelta.toVector2();
      // camera.snapTo(cameraPosition);
    }
  }

  TowerData? getSelectedTowerData(String towerType) {
    return towerSelection.towers.firstWhereOrNull((tower) => tower.type == towerType);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final tapPosition = event.localPosition;
    if (tapPosition.x < 50 && tapPosition.y < 50) {
      zoom = (zoom + zoomSpeed).clamp(minZoom, maxZoom);
    } else if (tapPosition.x > size.x - 50 && tapPosition.y < 50) {
      zoom = (zoom - zoomSpeed).clamp(minZoom, maxZoom);
    } else {
      final towerPosition = event.localPosition;

      bool positionOccupied = children.any((child) {
        if (child is TowerComponent) {
          return child.position.distanceTo(towerPosition) < 64;
        }
        return false;
      });

      if (!positionOccupied) {
        final towerData = getSelectedTowerData(_selectedTowerType);
        if (towerData != null) {
          final tower = TowerComponent(
            towerData ,
            type: _selectedTowerType
          )..position = towerPosition;
          add(tower);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.scale(zoom);
    canvas.translate(-cameraPosition.x, -cameraPosition.y);
    super.render(canvas);
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

  void reduceHealth(int amount) {
    if (playerHealthNotifier.value == 0) {
      Get.back();
    } else {
      playerHealthNotifier.value -= amount;
    }
  }
}

class TowerComponent extends SpriteComponent with HasGameRef<EpicTd>,CollisionCallbacks,TapCallbacks{
  final String type;
  final TowerData tower;
  late double range; // Define the range of the tower
  late CircleComponent rangeIndicator;
  double shootCooldown = 1.0; // Time between shots
  double timeSinceLastShot = 0.0;

  TowerComponent(this.tower,{this.type = 'default'}) : super(size: Vector2(20,20));

  @override
  Future<void> onLoad() async {
    range = getRange(type);
    // Load sprite based on towerData.type
    sprite = await gameRef.loadSprite(tower.iconPath);
    // anchor = Anchor.center;

    // Add range indicator
    rangeIndicator = CircleComponent(
      radius: range,
      paint: Paint()..color = blue.withOpacity(0.2),
      anchor: Anchor.center,
    );
    rangeIndicator.position = size/2.14;

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

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    removeFromParent();
  }
}

class BulletComponent extends SpriteAnimationComponent with HasGameRef<EpicTd>, CollisionCallbacks {
  final Vector2 targetPosition;
  final double speed = 300;
  final double range;
  final Vector2 startPosition;

  BulletComponent(this.targetPosition, {Vector2? position, this.range = 100})
  : startPosition = position ?? Vector2.zero(),
  super(size: Vector2(10, 10), position: position ?? Vector2.zero(), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      EpicTdAssetImages.bullet,
      SpriteAnimationData.sequenced(
        amount: 1, // Number of frames in the animation
        stepTime: 0.5, // Time interval between frames
        textureSize: Vector2(40, 40), // Size of each frame
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
        closestEnemy.takeDamage(game.defaultTakeHealthDamage);
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
  double maxHealth = 100; // Maximum health of the enemy
  late dynamic healthBar; // Health bar component

  EnemyComponent(this.goal) : super(size: Vector2(32, 32));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(EpicTdAssetImages.enemy);
    anchor = Anchor.center;
    add(RectangleHitbox()..collisionType = CollisionType.active);

    // Initialize the health bar
    healthBar = HealthBarComponent(
      position: Vector2(0, -5), // Position it above the enemy
      size: Vector2(size.x, 5), // Full width of the enemy and 5 pixels tall
      fillColor: Colors.green,
      borderColor: Colors.black,
      borderWidth: 1.0,
      anchor: Anchor.topLeft,
    );
    add(healthBar);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = (goal.position - position).normalized();
    position += direction * 50 * dt; // Move enemy to the goal

    if (position.distanceTo(goal.position) < 32) {
      gameRef.reduceHealth(gameRef.defaultReducePlayerHealth);
      removeFromParent();
    }

    // Update the health bar width based on the current health
    healthBar.size = Vector2((health / maxHealth) * size.x, healthBar.size.y);
  }

  void takeDamage(int damage) {
    health -= damage;
    if (health <= 0) {
      removeFromParent();
      game.totalCoin.value += 1;
    }
  }

}

class HealthBarComponent extends ShapeComponent {
  HealthBarComponent({
    required Vector2 position,
    required Vector2 size,
    required Color fillColor,
    required Color borderColor,
    required Anchor anchor,
    double borderWidth = 1.0, 
  }) : super(
          position: position,
          size: size,
          paint: Paint()
            ..color = fillColor
            ..style = PaintingStyle.fill,
        ) {
    border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
  }

  late final Paint border;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, border);
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
        color: white, // Set text color as needed
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

class HudOverlayWidget extends StatefulWidget {
  final EpicTd game;

  const HudOverlayWidget({super.key, required this.game});

  @override
  State<HudOverlayWidget> createState() => _HudOverlayWidgetState();
}

class _HudOverlayWidgetState extends State<HudOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Health display at the top-left corner
          Positioned(
            top: 10,
            left: 10,
            child: ValueListenableBuilder<int>(
              valueListenable: widget.game.playerHealthNotifier,
              builder: (context, health, child) {
                return Text(
                  'Health: $health',
                  style: const TextStyle(
                    fontSize: 20,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
      
          // Health display at the top-left corner
          Positioned(
            top: 50,
            left: 10,
            child: ValueListenableBuilder<int>(
              valueListenable: widget.game.totalCoin,
              builder: (context, totalCoin, child) {
                return Text(
                  'Coin: $totalCoin',
                  style: const TextStyle(
                    fontSize: 10,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
      
          // Start Wave button at the top-center
          Positioned(
            top: 10,
            right: 70,
            child: GestureDetector(
              onTap: () => widget.game.startWave(),
              child: Image.asset(
                'assets/images/common/ui/Play_Button_Circle.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
      
          // Back button at the top-center, offset to the right
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Image.asset(
                'assets/images/common/ui/Back_Button_Circle.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
      
          // Zoom In button at the top-right
          Positioned(
            top: 70,
            right: 10,
            child: GestureDetector(
              onTap: () {
                widget.game.zoom = (widget.game.zoom + widget.game.zoomSpeed).clamp(widget.game.minZoom, widget.game.maxZoom);
              },
              child: Image.asset(
                'assets/images/common/ui/zoom_plus.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
      
          // Zoom Out button below the Zoom In button
          Positioned(
            top: 140,
            right: 10,
            child: GestureDetector(
              onTap: () {
                widget.game.zoom = (widget.game.zoom - widget.game.zoomSpeed).clamp(widget.game.minZoom, widget.game.maxZoom);
              },
              child: Image.asset(
                'assets/images/common/ui/zoom_minus.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
      
          // Tower Selection buttons at the bottom of the screen
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                // color: white,
                border: Border(
                  top: BorderSide(color: black, width: 2.0), // Adjust the width as needed
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Row(
                  children: List.generate(
                    widget.game.towerSelection.towers.length, 
                    (index) {
                      final tower = widget.game.towerSelection.towers[index];
                      return GestureDetector(
                        onTap: () {
                          widget.game.selectTower(tower.type);
                        },
                        child: Container(
                          color: grey200,
                          margin: const EdgeInsets.only(right:5.0),
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/${tower.iconPath}',
                                width: 50,
                                height: 50,
                              ),
                              Text(
                                tower.type,
                                style: smallTextStyleBlack,
                              ),
                              Text(
                                'r : ${tower.range}',
                                style: smallTextStyleBlack,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    growable: true
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}