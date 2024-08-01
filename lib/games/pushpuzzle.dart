import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_games_collection/common/constant.dart';
import 'package:flutter_games_collection/common/styles.dart';
import 'package:flutter_games_collection/widgets/base_scaffold_layout.dart';
import 'package:get/get.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';

enum Direction { up, down, left, right, none }
const double oneBlockSize = 64.0;
const int playerCameraWallWidth = 20;
dynamic screenSize = 0.0;

class PushPuzzleMenuPage extends StatefulWidget {
  const PushPuzzleMenuPage({super.key});

  @override
  State<PushPuzzleMenuPage> createState() => _PushPuzzleMenuPageState();
}

class _PushPuzzleMenuPageState extends State<PushPuzzleMenuPage> {

  @override
  Widget build(BuildContext context) {
    // Call the function and pass the context
    printScreenSize(context);
    return BaseScaffoldLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title
          Text(
            'game4Title'.tr,
            style: textExtraLargeWhite(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100),
          // Play Button
          ElevatedButton(
            onPressed: ()async{
              Get.to(
                () => Scaffold(
                  body : GameWidget(
                    game: PushPuzzleGame(),
                    overlayBuilderMap: {
                      'HudOverlay': (BuildContext context , PushPuzzleGame game){
                        return HudOverlayWidget(game: game);
                      }
                    },
                    initialActiveOverlays: const ['HudOverlay'],
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

void printScreenSize(BuildContext context) {
  screenSize = MediaQuery.of(context).size;
}

class PushPuzzleGame extends FlameGame with KeyboardEvents, HasGameRef {
  late Function stateCallbackHandler;

  PushGame pushGame = PushGame();
  Player? _player;
  final List<Crate> _crateList = [];
  final List<SpriteComponent> _bgComponentList = [];
  final List<SpriteComponent> _floorSpriteList = [];
  late Map<String, Sprite> _spriteMap;
  late Sprite _floorSprite;

  double scaleFactor = 1.0;

  @override
  Color backgroundColor() => blue;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final blockSprite = await Sprite.load('pushpuzzle/block.png');
    final goalSprite = await Sprite.load('pushpuzzle/goal.png');
    _floorSprite = await Sprite.load('pushpuzzle/floor.png');
    _spriteMap = {
      '#': blockSprite,
      '.': goalSprite,
    };
    await draw();
  }

  void setCallback(Function fn) => stateCallbackHandler = fn;

  Future<void> draw() async {
    // final levelWidth = pushGame.state.width.toDouble();
    // final levelHeight = pushGame.state.height.toDouble();
    await Flame.device.fullScreen();

    // final screenSize = screenSize;

    // // Calculate the scale factor to fit the level on the screen
    // scaleFactor = screenSize.width / (levelWidth * oneBlockSize);

    // if (scaleFactor * levelHeight * oneBlockSize > screenSize.height) {
    //   scaleFactor = screenSize.height / (levelHeight * oneBlockSize);
    // }
    
    for (var y = 0; y < pushGame.state.splitStageStateList.length; y++) {
      final row = pushGame.state.splitStageStateList[y];
      final firstWallIndex = row.indexOf('#');
      final lastWallIndex = row.lastIndexOf('#');

      for (var x = 0; x < row.length; x++) {
        final char = row[x];
        if (x > firstWallIndex && x < lastWallIndex) renderFloor(x.toDouble(), y.toDouble());
        if (_spriteMap.containsKey(char)) renderBackGround(_spriteMap[char], x.toDouble(), y.toDouble());
        if (char == 'p') initPlayer(x.toDouble(), y.toDouble());
        if (char == 'o') initCrate(x.toDouble(), y.toDouble());
      }
    }

    add(_player!);
    add(camera);
    for(var crate in _crateList) {
      add(crate);
    }

    if (pushGame.state.width > playerCameraWallWidth) {
      camera.follow(_player!);
    } else {
      // Assuming you have the dimensions and block size
      final targetPosition = Vector2(
        pushGame.state.width * oneBlockSize / 2,
        pushGame.state.height * oneBlockSize / 2,
      );

      // Create a PositionComponent at the target position
      final targetComponent = PositionComponent(position: targetPosition);
      camera.follow(targetComponent);

      // camera.followVector2(Vector2(pushGame.state.width * oneBlockSize / 2, pushGame.state.height * oneBlockSize / 2));
      // camera.followComponent(component);
    }
  }

  void renderBackGround(sprite, double x, double y) {
    final component = SpriteComponent(
      size: Vector2.all(oneBlockSize),
      sprite: sprite,
      position: Vector2(x * oneBlockSize, y * oneBlockSize),
    );
    _bgComponentList.add(component);
    add(component);
  }

  void renderFloor(double x, double y) {
    final component = SpriteComponent(
      size: Vector2.all(oneBlockSize),
      sprite: _floorSprite,
      position: Vector2(x * oneBlockSize, y * oneBlockSize),
    );
    _floorSpriteList.add(component);
    add(component);
  }

  void initPlayer(double x, double y) {
    _player = Player();
    _player!.position = Vector2(x * oneBlockSize, y * oneBlockSize);
  }

  void initCrate(double x, double y) {
    final crate = Crate();
    crate.setPosition(Vector2(x, y));
    crate.position = Vector2(x * oneBlockSize, y * oneBlockSize);
    _crateList.add(crate);
  }

  void allReset() {
    remove(_player!);
    for (var crate in _crateList) {
      remove(crate);
    }
    for (var bg in _bgComponentList) {
      remove(bg);
    }
    for (var floorSprite in _floorSpriteList) {
      remove(floorSprite);
    }
    _crateList.clear();
    _bgComponentList.clear();
    _floorSpriteList.clear();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;
    Direction keyDirection = Direction.none;

    if (!isKeyDown || _player!._moveCount != 0 || pushGame.state.isClear) {
      return super.onKeyEvent(event, keysPressed);
    }

    keyDirection = getKeyDirection(event);
    bool isMove = pushGame.changeState(keyDirection.name);
    if (isMove) {
      playerMove(isKeyDown, keyDirection);
      if (pushGame.state.isCrateMove) {
        createMove();
      }
      if (pushGame.state.isClear) {
        // stateCallbackHandler(pushGame.state.isClear);
        Timer(const Duration(seconds: 3), drawNextStage);
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  Direction getKeyDirection(KeyEvent event) {
    Direction keyDirection = Direction.none;
    if (event.logicalKey == LogicalKeyboardKey.keyA || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      keyDirection = Direction.left;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD || event.logicalKey == LogicalKeyboardKey.arrowRight) {
      keyDirection = Direction.right;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.arrowUp) {
      keyDirection = Direction.up;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS || event.logicalKey == LogicalKeyboardKey.arrowDown) {
      keyDirection = Direction.down;
    }
    return keyDirection;
  }

  void playerMove(bool isKeyDown, Direction keyDirection) {
    if (isKeyDown && keyDirection != Direction.none) {
      _player!.direction = keyDirection;
      _player!.moveCount = oneBlockSize.toInt();
    } else if (_player!.direction == keyDirection) {
      _player!.direction = Direction.none;
    }
  }

  void createMove() {
    final targetCrate = _crateList.firstWhere((crate) => crate.coordinate == pushGame.state.crateMoveBeforeVec);
    targetCrate.move(pushGame.state.crateMoveAfterVec);
    targetCrate.goalCheck(pushGame.state.goalVecList);
  }

  void drawNextStage() {
    pushGame.nextStage();
    // stateCallbackHandler(pushGame.state.isClear);
    allReset();
    draw();
  }

  void onDirectionButtonPressed(Direction direction) {
    if (_player == null || _player!._moveCount != 0 || pushGame.state.isClear) {
      return;
    }

    bool isMove = pushGame.changeState(direction.name);
    if (isMove) {
      playerMove(true, direction);
      if (pushGame.state.isCrateMove) {
        createMove();
      }
      if (pushGame.state.isClear) {
        // stateCallbackHandler(pushGame.state.isClear);
        Timer(const Duration(seconds: 3), drawNextStage);
      }
    }
  }
}

class Player extends SpriteAnimationComponent with HasGameRef {
  final double _animationSpeed = 0.15;
  final double _moveCoordinate = 8;
  int _moveCount = 0;

  late final SpriteAnimation _runDownAnimation;
  late final SpriteAnimation _runLeftAnimation;
  late final SpriteAnimation _runUpAnimation;
  late final SpriteAnimation _runRightAnimation;
  late final SpriteAnimation _standingAnimation;

  Direction direction = Direction.none;

  Player()
  : super(
    size: Vector2.all(oneBlockSize),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _loadAnimations().then((_) => {animation = _standingAnimation});
  }

  set moveCount(int i) {
    _moveCount = i;
  }

  // int get moveCount => _moveCount;

  @override
  void update(double dt) {
    super.update(dt);
    movePlayer(dt);
  }

  void movePlayer(double delta) {
    if (_moveCount == 0) return;

    switch (direction) {
      case Direction.up:
        animation = _runUpAnimation;
        moveFunc(Vector2(0, -_moveCoordinate));
        break;
      case Direction.down:
        animation = _runDownAnimation;
        moveFunc(Vector2(0, _moveCoordinate));
        break;
      case Direction.left:
        animation = _runLeftAnimation;
        moveFunc(Vector2(-_moveCoordinate, 0));
        break;
      case Direction.right:
        animation = _runRightAnimation;
        moveFunc(Vector2(_moveCoordinate, 0));
        break;
      case Direction.none:
        animation = _standingAnimation;
        break;
    }
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('pushpuzzle/sp_player.png'),
      srcSize: Vector2(84.0, 110.0),
    );
    _runDownAnimation = spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 4);
    _runLeftAnimation = spriteSheet.createAnimation(row: 2, stepTime: _animationSpeed, to: 4);
    _runUpAnimation = spriteSheet.createAnimation(row: 1, stepTime: _animationSpeed, to: 4);
    _runRightAnimation = spriteSheet.createAnimation(row: 3, stepTime: _animationSpeed, to: 4);
    _standingAnimation = spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 1);
  }

  void moveFunc(Vector2 vac) {
    _moveCount -= _moveCoordinate.toInt();
    position.add(vac);
  }
} 

class Crate extends SpriteAnimationComponent with HasGameRef {
  // int _moveCount = 0;
  late Vector2 coordinate;
  bool isGoal = false;

  late final SpriteAnimation _noAnimation;
  late final SpriteAnimation _goalAnimation;
  late final OpacityEffect goalEffect;

  Crate()
      : super(
    size: Vector2.all(oneBlockSize),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _loadAnimations().then((_) => {animation = _noAnimation});
    goalEffect = customOpacityEffect;
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('pushpuzzle/crate.png'),
      srcSize: Vector2.all(oneBlockSize),
    );

    _noAnimation = spriteSheet.createAnimation(row: 0, stepTime: 1, to: 1);
    _goalAnimation = spriteSheet.createAnimation(row: 0, stepTime: 0.4, to: 2);
  }

  void setPosition(Vector2 vec) {
    coordinate = vec;
  }

  move(Vector2 vec) {
    moveFunc((vec - coordinate) * oneBlockSize);
    setPosition(vec);
  }

  void moveFunc(Vector2 vac) {
    position.add(vac);
  } 

  void goalCheck(List<Vector2> vacList) {
    isGoal = vacList.any((vec) => coordinate == vec);

    // if (isGoal && !goalEffect.isMounted) {
    //   add(goalEffect);
    // } else if(!isGoal && goalEffect.isMounted) {
    //   goalEffect.apply(0);
    //   goalEffect.removeFromParent();
    // }
    if (isGoal) {
      animation = _goalAnimation;
    } else {
      animation = _noAnimation;
    }
  }
}

OpacityEffect customOpacityEffect = OpacityEffect.fadeOut(
  EffectController(
    duration: 0.6,
    reverseDuration: 0.6,
    infinite: true,
  ),
);

ColorEffect customColorEffect = ColorEffect(
  Colors.blue,
  // const Offset(
  //   0.2,
  //   0.8,
  // ),
  EffectController(
    duration: 0.8,
    reverseDuration: 0.8,
    infinite: true,
  ),
);

Vector2 getMoveDirection(String input) {
  double dx, dy;
  dx = dy = 0;

  switch (input) {
    case 'left':
      dx = -1;
      break;
    case 'right':
      dx = 1;
      break;
    case 'up':
      dy = -1;
      break;
    case 'down':
      dy = 1;
      break;
  }
  return Vector2(dx, dy);
}

enum Object {
  space(' '),
  wall('#'),
  goal('.'),
  crate('o'),
  crateOnGoal('O'),
  man('p'),
  manOnGoal('P'),
  unknown('');

  const Object(this.displayName);

  final String displayName;

  static Object fromValue(String value) => Object.values.firstWhere((o) => o.displayName == value);
}

const List<String> stageMasterDataList = [
  '''
  ########
  # .. p #
  # oo   #
  #      #
  ########
  ''',
  '''
  #####    
  #   #####
  #    op.#
  #########
  ''',
  '''
  ########
  #   #  #
  # p    #
  ## ###.#
   # o   #
   #   ###
   #####  
  ''',
  '''
  #####   
  #.  ##  
  #    ## 
  ##    ##
  ##  o #
    ##  p#
    #####
  ''',
  '''
  #####
  # p.#
  # o # 
  #.o #
  #####
  ''',
  '''
  #####   
  #.. ##  
  #    ## 
  ##    ##
  ## oo #
    ##  p#
    #####
  ''',
  '''
  ############
  #     ## p #
  #   o .. o #
  ############
  ''',
  '''
  ####  
  ##  ## 
  #po  ##
  # o  .#
  ###   #
    ## .#
    ####
  ''',
  '''
  #####  
  #   ## 
  #  o ##
  # .op.#
  #######
  ''',
  '''
  #####  
  #   ## 
  #  o ##
  ##.op.#
  ######
  ''',
  '''
  #######################################
  #   p                       o.        #
  #      #### #  ##  #    #    #        #
  #      #    #  # # #   # #   #        #
  #      ###  #  #  ##  #####  #        #
  #      #    #  #   # #     # #####    #
  #######################################
  '''
];

class StageState {
  late int width;
  late int height;
  late List<String> dataList;
  late List<Object> objectList = initStageState;

  bool _isCrateMove = false;
  late Vector2 crateMoveBeforeVec;
  late Vector2 crateMoveAfterVec;
  late List<Vector2> goalVecList;

  StageState({int stage = 1}) {
    changeStage(stage);
  }

  void changeStage(int stage) {
    dataList = LineSplitter.split(stageMasterDataList[stage - 1]).toList();
    width = dataList.first.length;
    height = dataList.length;
    objectList = initStageState;
    goalVecList = _goalVecList;
  }

  List<Object> get initStageState {
    final List<Object> stageStateList = List<Object>.filled(width * height, Object.unknown);
    int x, y;
    x = y = 0;
    for (var stageData in dataList) {
      for (var rune in stageData.runes) {
        final Object t = Object.fromValue(String.fromCharCode(rune));
        if (t != Object.unknown) {
          stageStateList[y * width + x] = t;
          ++x;
        }
      }
      x = 0;
      ++y;
    }
    return stageStateList;
  }

  int get playerIndex => objectList.indexWhere((obj) => obj == Object.man || obj == Object.manOnGoal);

  bool get isCrateMove => _isCrateMove;

  bool isCrate(int targetPosition) => objectList[targetPosition] == Object.crate || objectList[targetPosition] == Object.crateOnGoal;

  bool isWorldOut(tx, ty) => tx < 0 || ty < 0 || tx >= width || ty >= height;

  bool isSpaceOrGoal(int targetPosition) => objectList[targetPosition] == Object.space || objectList[targetPosition] == Object.goal;

  bool get isClear => objectList.indexWhere((obj) => obj == Object.crate) == -1;

  Vector2 get playerVecPos => Vector2((playerIndex % width).toDouble(), (playerIndex ~/ width).toDouble());

  Vector2 getVecPos(int index) => Vector2((index % width).toDouble(), (index ~/ width).toDouble());

  List<int> get crateIndexList {
    List<int> indices = [];
    for (int i = 0; i < objectList.length; i++) {
      if (objectList[i] == Object.crate) {
        indices.add(i);
      }
    }
    return indices;
  }

  List<Vector2> get crateVecList {
    List<Vector2> indices = [];
    for (var crateIndex in crateIndexList) {
      indices.add(getVecPos(crateIndex));
    }
    return indices;
  }

  List<int> get crateOnGoalIndexList {
    List<int> indices = [];
    for (int i = 0; i < objectList.length; i++) {
      if (objectList[i] == Object.crateOnGoal) {
        indices.add(i);
      }
    }
    return indices;
  }

  List<Vector2> get crateOnGoalVecList {
    List<Vector2> indices = [];
    for (var crateOnGoalIndex in crateOnGoalIndexList) {
      indices.add(getVecPos(crateOnGoalIndex));
    }
    return indices;
  }

  List<int> get _goalIndexList {
    List<int> indices = [];
    for (int i = 0; i < objectList.length; i++) {
      if (objectList[i] == Object.goal) {
        indices.add(i);
      }
    }
    return indices;
  }

  List<Vector2> get _goalVecList {
    List<Vector2> indices = [];
    for (var goalIndex in _goalIndexList) {
      indices.add(getVecPos(goalIndex));
    }
    return indices;
  }

  List<String> get splitStageStateList {
    final List<String> stageStateList = List<String>.filled(height, '');

    for (int y = 0; y < height; ++y) {
      String line = '';
      for (int x = 0; x < width; ++x) {
        line = '$line${objectList[y * width + x].displayName}';
      }
      stageStateList[y] = line;
      line = '';
    }
    return stageStateList;
  }

  void changePlayerObject(int targetPosition, int playerPosition) {
    replacePlayerIn(targetPosition);
    replacePlayerLeave(playerPosition);
  }

  void replacePlayerIn(int targetPosition) {
    objectList[targetPosition] = (objectList[targetPosition] == Object.goal)
    ? Object.manOnGoal
    : Object.man;
  }

  void replacePlayerLeave(int playerPosition) {
    objectList[playerPosition] = (objectList[playerPosition] == Object.manOnGoal)
    ? Object.goal
    : Object.space;
  }

  void replaceCrateIn(int targetPosition) {
    objectList[targetPosition] = (objectList[targetPosition] == Object.goal)
    ? Object.crateOnGoal
    : Object.crate;
  }

  void replaceCrateLeave(int targetPosition) {
    objectList[targetPosition] = (objectList[targetPosition] == Object.crateOnGoal)
    ? Object.manOnGoal
    : Object.man;
  }

  bool changeState(String input) {
    _isCrateMove = false;
    int dx = getMoveDirection(input).x.toInt();
    int dy = getMoveDirection(input).y.toInt();
    int x = playerVecPos.x.toInt(); // modulus operator
    int y = playerVecPos.y.toInt(); // integer division operator

    // post move coordinate
    int tx = x + dx;
    int ty = y + dy;

    // Maximum and minimum coordinate checks
    if (isWorldOut(tx, ty)) return false;

    int p = y * width + x; // PlayerPosition
    int tp = ty * width + tx; // TargetPosition

    // Space or goal. People move.
    if (isSpaceOrGoal(tp)) {
      changePlayerObject(tp, p);
    } else if (isCrate(tp)) {
      // So two squares away is in range.
      int tx2 = tx + dx;
      int ty2 = ty + dy;

      // Impossible to push.
      if (isWorldOut(tx2, ty2)) return false;

      int tp2 = (ty + dy) * width + (tx + dx); // two squares away

      // sequential replacement
      if (isSpaceOrGoal(tp2)) {
        _isCrateMove = true;
        crateMoveBeforeVec = getVecPos(tp);
        crateMoveAfterVec = getVecPos(tp2);

        replaceCrateIn(tp2);
        replaceCrateLeave(tp);
        replacePlayerLeave(p);
      } else {
        return false;
      }
    } else {
      return false;
    }
    return true;
  }
}

class PushGame {
  late int _stage;
  late int step;
  late StageState state;

  PushGame({int stage = 1, this.step = 0}) {
    _stage = stage;
    state = StageState(stage: stage);
  }

  int get stage => _stage;
  bool get isFinalStage => state.dataList.length == stage;

  void draw() {
    for (var splitStageState in state.splitStageStateList) {
      if (kDebugMode) {
        print(splitStageState);
      }
    }
  }

  void update(String input) {
    changeState(input);
    draw();
    if (state.isClear) {
      if (kDebugMode) {
        print("Congratulation's! you won.");
      }
    }
  }

  bool changeState(String input) {
    step++;
    return state.changeState(input);
  }

  void nextStage() {
    _stage++;
    step = 0;
    state.changeStage(_stage);
  }
}

class HudOverlayWidget extends StatefulWidget {
  final PushPuzzleGame game;

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
        // Platform.isIOS||Platform.isAndroid
        // ?
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => widget.game.onDirectionButtonPressed(Direction.up),
                child: const Text('W'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => widget.game.onDirectionButtonPressed(Direction.left),
                    child: const Text('A'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => widget.game.onDirectionButtonPressed(Direction.down),
                    child: const Text('S'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => widget.game.onDirectionButtonPressed(Direction.right),
                    child: const Text('D'),
                  ),
                ],
              ),
            ],
          ),
        )
        // :const SizedBox(),
      ],

    );
  }
}