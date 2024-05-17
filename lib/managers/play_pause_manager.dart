import 'package:get/get.dart';

class PlayPauseManager extends GetxController {
  RxBool spaceShooterPaused = false.obs;

  void play() {
    spaceShooterPaused.value = false;
    update();
  }

  void pause() {
    spaceShooterPaused.value = true;
    update();
  }
}