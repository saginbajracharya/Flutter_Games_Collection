import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_games_collection/common/constant.dart';
import 'package:flutter_games_collection/common/styles.dart';
import 'package:flutter_games_collection/widgets/base_scaffold_layout.dart';
import 'package:get/get.dart';

enum Direction { up, down, left, right, none }

class CharacterMovementMenuPage extends StatefulWidget {
  const CharacterMovementMenuPage({super.key});

  @override
  State<CharacterMovementMenuPage> createState() => _CharacterMovementMenuPageState();
}

class _CharacterMovementMenuPageState extends State<CharacterMovementMenuPage> {
  final gameInstance = Charactermovement();

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
            'game5Title'.tr,
            style: textExtraLargeWhite(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100),
          // Play Button
          ElevatedButton(
            onPressed: ()async{
              Get.to(
                () => Scaffold(
                  body : Stack(
                    children: [
                      GameWidget(
                        game: gameInstance,
                        overlayBuilderMap: {
                          'HudOverlay': (BuildContext context , Charactermovement game){
                              return HudOverlayWidget(game: game);
                          }
                        },
                        initialActiveOverlays: const ['HudOverlay'],
                      ),
                    ],
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
        ],
      ),
    );
  }
}

class Charactermovement extends FlameGame with KeyboardEvents {
  final Player _player = Player();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(_player);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;
    Direction? keyDirection;

    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      keyDirection = Direction.left;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      keyDirection = Direction.right;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      keyDirection = Direction.up;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      keyDirection = Direction.down;
    }

    if (isKeyDown && keyDirection != null) {
      _player.direction = keyDirection;
    } else if (_player.direction == keyDirection) {
      _player.direction = Direction.none;
    }
    if (kDebugMode) {
      print('Current Direction == >  $keyDirection');
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void onJoyPadDirectionChanged(Direction direction) {
    if (kDebugMode) {
      print('Current Direction == >  $direction');
    }
    _player.direction = direction;
  }
}

class Joypad extends StatefulWidget {
  final ValueChanged<Direction>? onDirectionChanged;

  const Joypad({super.key, this.onDirectionChanged});

  @override
  JoypadState createState() => JoypadState();
}

class JoypadState extends State<Joypad> {
  Direction direction = Direction.none;
  Offset delta = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
        ),
        child: GestureDetector(
          onPanDown: onDragDown,
          onPanUpdate: onDragUpdate,
          onPanEnd: onDragEnd,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x88ffffff),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Transform.translate(
                offset: delta,
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xccffffff),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateDelta(Offset newDelta) {
    final newDirection = getDirectionFromOffset(newDelta);

    if (newDirection != direction) {
      direction = newDirection;
      widget.onDirectionChanged!(direction);
    }

    setState(() {
      delta = newDelta;
    });
  }

  Direction getDirectionFromOffset(Offset offset) {
    if (offset.dx > 20) {
      return Direction.right;
    } else if (offset.dx < -20) {
      return Direction.left;
    } else if (offset.dy > 20) {
      return Direction.down;
    } else if (offset.dy < -20) {
      return Direction.up;
    }
    return Direction.none;
  }

  void onDragDown(DragDownDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragUpdate(DragUpdateDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragEnd(DragEndDetails d) {
    updateDelta(Offset.zero);
  }

  void calculateDelta(Offset offset) {
    final newDelta = offset - const Offset(60, 60);
    updateDelta(
      Offset.fromDirection(
        newDelta.direction,
        min(30, newDelta.distance),
      ),
    );
  }
}

class Player extends SpriteAnimationComponent with HasGameRef {
  final double _playerSpeed = 300.0;
  final double _animationSpeed = 0.15;

  late final SpriteAnimation _runDownAnimation;
  late final SpriteAnimation _runLeftAnimation;
  late final SpriteAnimation _runUpAnimation;
  late final SpriteAnimation _runRightAnimation;
  late final SpriteAnimation _standingAnimation;

  Direction direction = Direction.none;

  Player() : super(
    size: Vector2(42.0, 55.0),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _loadAnimations().then((_) => {animation = _standingAnimation});
  }

  @override
  void update(double dt) {
    super.update(dt);
    movePlayer(dt);
  }

  void movePlayer(double delta) {
    switch (direction) {
      case Direction.up:
        animation = _runUpAnimation;
        moveUp(delta);
        break;
      case Direction.down:
        animation = _runDownAnimation;
        moveDown(delta);
        break;
      case Direction.left:
        animation = _runLeftAnimation;
        moveLeft(delta);
        break;
      case Direction.right:
        animation = _runRightAnimation;
        moveRight(delta);
        break;
      case Direction.none:
        animation = _standingAnimation;
        break;
    }
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('charactermovement/sp_player.png'),
      srcSize: Vector2(84.0, 110.0),
    );

    _runDownAnimation = spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 4);

    _runLeftAnimation = spriteSheet.createAnimation(row: 2, stepTime: _animationSpeed, to: 4);

    _runUpAnimation = spriteSheet.createAnimation(row: 1, stepTime: _animationSpeed, to: 4);

    _runRightAnimation = spriteSheet.createAnimation(row: 3, stepTime: _animationSpeed, to: 4);

    _standingAnimation = spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 1);
  }

  void moveUp(double delta) {
    position.add(Vector2(0, delta * -_playerSpeed));
  }

  void moveDown(double delta) {
    position.add(Vector2(0, delta * _playerSpeed));
  }

  void moveLeft(double delta) {
    position.add(Vector2(delta * -_playerSpeed, 0));
  }

  void moveRight(double delta) {
    position.add(Vector2(delta * _playerSpeed, 0));
  }
}

class HudOverlayWidget extends StatefulWidget {
  final Charactermovement game;

  const HudOverlayWidget({super.key, required this.game});

  @override
  State<HudOverlayWidget> createState() => _HudOverlayWidgetState();
}

class _HudOverlayWidgetState extends State<HudOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Back button at the top-center, offset to the right
        Positioned(
          top: kBottomNavigationBarHeight,
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
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Joypad(onDirectionChanged: widget.game.onJoyPadDirectionChanged),
          ),
        )
      ],
    );
  }
}