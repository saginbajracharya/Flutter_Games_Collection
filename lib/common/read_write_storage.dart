import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class StorageKeys {
  static const String highScoreSpaceShooterKey = 'spaceshooterhighscore';
  static const String highScoreEmberQuestKey   = 'emberquesthighscore';
}

read(String storageName){
  dynamic result = box.read(storageName)??"";
  return result;
}

write(String storageName,dynamic value){
  box.write(storageName,value??"");
}

remove(String storageName){
  box.remove(storageName);
}