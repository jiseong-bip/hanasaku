import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoProvider with ChangeNotifier {
  String? _token;
  String? _name;
  int? _currentCategoryId;
  List<Map<String, dynamic>>? _category;
  static const String _tokenBoxName = 'tokenBox';
  static const String _tokenKey = 'token';
  static const String _nickNameKey = 'nickName';
  static const String _categoryKey = 'category';

  Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
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

  void setCategory(List<Map<String, dynamic>> category) {
    _category = category;
    notifyListeners();
  }

  void setCurrentCategory(int id) {
    _currentCategoryId = id;
    notifyListeners();
  }

  int getCurrentCategory() {
    if (_currentCategoryId != null) {
      return _currentCategoryId!;
    }
    return 0;
  }

  void setSelectedCategory(int targetId) {
    for (var item in _category!) {
      if (item["id"] == targetId) {
        item["isSelected"] = !(item["isSelected"] as bool);
        notifyListeners();
        break; // 해당 id를 찾았으므로 루프를 종료합니다.
      }
    }
  }

  List<Map<String, dynamic>> getSelectedCategory() {
    List<Map<String, dynamic>> selectedCategory = [];
    if (_category != null) {
      for (var item in _category!) {
        if (item['isSelected'] == true) {
          selectedCategory.add(item);
        }
      }
      return selectedCategory;
    } else {
      return selectedCategory;
    }
  }

  bool? getIsSelectedById(int targetId) {
    for (var item in _category!) {
      if (item["id"] == targetId) {
        return item["isSelected"] as bool?;
      }
    }
    return null; // 해당 id를 가진 항목이 없을 경우 null 반환
  }

  List<Map<String, dynamic>> getCategoryName() {
    if (_category != null) {
      return _category!;
    }
    return [];
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

  Future<void> clearCategory() async {
    final box = await Hive.openBox<List<Map<String, dynamic>>>(_tokenBoxName);
    await box.delete(_categoryKey);
    _category = null;
    notifyListeners(); // Notify listeners when the category is cleared
  }

  Future<void> clearUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final box = await Hive.openBox<String>(_tokenBoxName);
    await box.delete(_tokenKey);
    await box.delete(_nickNameKey);
    await box.delete(_categoryKey);
    _token = null;
    _name = null;
    _category = null;

    notifyListeners();
  }
}
