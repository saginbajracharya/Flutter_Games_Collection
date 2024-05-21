import 'dart:developer';
import 'package:flutter_games_collection/common/read_write_storage.dart';
import 'package:get/get.dart';

class ScoreStateManager extends GetxController {
  final RxInt _spaceShooterScore = RxInt(0);
  final RxInt _savedSpaceShooterhighscore = RxInt(0);
  final RxInt _emberQuestScore = RxInt(0);
  final RxInt _savedEmberQuesthighscore = RxInt(0);
  final RxInt _epictdCoin = RxInt(0);
  final RxInt _savedEpictdCoin = RxInt(0);

  RxInt get spaceShooterScore => _spaceShooterScore;
  RxInt get savedSpaceShooterhighscore => _savedSpaceShooterhighscore;

  RxInt get emberQuestScore => _emberQuestScore;
  RxInt get savedEmberQuesthighscore => _savedEmberQuesthighscore;

  RxInt get epictdCoin => _epictdCoin;
  RxInt get savedEpictdCoin => _savedEpictdCoin;

  // Space Shooter High Score
  void updateSpaceShooterScore(int newScore) {
    _spaceShooterScore.value = newScore;
    if(_savedSpaceShooterhighscore.value<newScore){
      saveSpaceShooterHighScore(newScore);
    }
    update();
  }

  saveSpaceShooterHighScore(score){
    _savedSpaceShooterhighscore.value = score;
    write(StorageKeys.highScoreSpaceShooterKey, score);
    log('new high score $score');
  }

  readSpaceShooterHighScore() async {
    dynamic tempScore = await read(StorageKeys.highScoreSpaceShooterKey)==''?0:await read(StorageKeys.highScoreSpaceShooterKey);
    _savedSpaceShooterhighscore.value = tempScore??0; 
    update();
  }

  // Ember Quest High Score
  void updateEmberQuestScore(int newScore) {
    _emberQuestScore.value = newScore;
    if(_savedEmberQuesthighscore.value<newScore){
      saveEmberQuestHighScore(newScore);
    }
    update();
  }

  saveEmberQuestHighScore(score){
    _savedEmberQuesthighscore.value = score;
    write(StorageKeys.highScoreEmberQuestKey, score);
    log('new high score $score');
  }

  readEmberQuestHighScore() async {
    dynamic tempScore = await read(StorageKeys.highScoreEmberQuestKey);
    _savedEmberQuesthighscore.value = tempScore??0; 
    update();
  }

  // Epic TD Coin
  void updateEpicTdCoin(int newTotal) {
    _epictdCoin.value = newTotal;
    if(_epictdCoin.value<newTotal){
      saveEpicTdCoin(newTotal);
    }
    update();
  }

  saveEpicTdCoin(newTotal){
    _savedEpictdCoin.value = newTotal;
    write(StorageKeys.epicTdCoinKey, newTotal);
    log('new coin $newTotal');
  }

  readEpicTdCoin() async {
    dynamic tempCoin = await read(StorageKeys.epicTdCoinKey);
    _savedEpictdCoin.value = tempCoin??0; 
    update();
  }
}
