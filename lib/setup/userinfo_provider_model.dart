import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

class TokenManager with ChangeNotifier {
  String? _token;
  String? _name;
  static const String _tokenBoxName = 'tokenBox';
  static const String _tokenKey = 'token';
  static const String _nickNameKey = 'nickName';

  Future<void> setToken(String token) async {
    final box = await Hive.openBox<String>(_tokenBoxName);
    await box.put(_tokenKey, token);
    _token = token;

    notifyListeners(); // Notify listeners when the token changes
  }

  Future<String?> getToken() async {
    if (_token == null) {
      final box = await Hive.openBox<String>(_tokenBoxName);
      _token = box.get(_tokenKey);
    }

    return _token;
  }

  Future<void> setNickName(String nickName) async {
    final box = await Hive.openBox<String>(_tokenBoxName);
    await box.put(_nickNameKey, nickName);
    _name = nickName;
    notifyListeners(); // Notify listeners when the nickname changes
  }

  Future<String?> getNickName() async {
    if (_name == null) {
      final box = await Hive.openBox<String>(_tokenBoxName);
      _name = box.get(_nickNameKey);
    }
    return _name;
  }

  Future<void> clearToken() async {
    final box = await Hive.openBox<String>(_tokenBoxName);
    await box.delete(_tokenKey);
    _token = null;
    notifyListeners(); // Notify listeners when the token is cleared
  }

  Future<void> clearNickName() async {
    final box = await Hive.openBox<String>(_tokenBoxName);
    await box.delete(_nickNameKey);
    _name = null;
    notifyListeners(); // Notify listeners when the nickname is cleared
  }
}
