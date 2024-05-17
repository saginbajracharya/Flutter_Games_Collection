import 'dart:developer';

import 'package:flutter_games_collection/common/read_write_storage.dart';
import 'package:get/get.dart';

class ScoreStateManager extends GetxController {
  final RxInt _spaceShooterScore = RxInt(0);
  final RxInt _savedhighscore = RxInt(0);

  RxInt get spaceShooterScore => _spaceShooterScore;
  RxInt get savedhighscore => _savedhighscore;


  void updateScore(int newScore) {
    _spaceShooterScore.value = newScore;
    if(_savedhighscore.value<newScore){
      saveHighScore(newScore);
    }
    update();
  }

  saveHighScore(score){
    _savedhighscore.value = score;
    write(StorageKeys.highScoreSpaceShooterKey, score);
    log('new high score $score');
  }

  readHighScore() async {
    dynamic tempScore = await read(StorageKeys.highScoreSpaceShooterKey);
    _savedhighscore.value = tempScore??0; 
    update();
  }
}
