import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

class UserInfoProvider with ChangeNotifier {
  String? _token;
  String? _name;
  List<Map<String, dynamic>>? _category;
  static const String _tokenBoxName = 'tokenBox';
  static const String _tokenKey = 'token';
  static const String _nickNameKey = 'nickName';
  static const String _categoryKey = 'category';

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

  Future<void> setCategory(List<Map<String, dynamic>> category) async {
    final box = await Hive.openBox<List<Map<String, dynamic>>>(_tokenBoxName);
    await box.put(_categoryKey, category);
    _category = category;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>?> getCategoryName() async {
    if (_category == null) {
      final box = await Hive.openBox<List<Map<String, dynamic>>>(_tokenBoxName);
      _category = box.get(_categoryKey);
    }
    return _category;
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

class CategoryIdChange extends ChangeNotifier {
  int? _categoryId;
  final List<int> _selectedCategoryIds = [];

  void setSelectedCategoryIds(int categoryId) {
    _selectedCategoryIds.add(categoryId);
    notifyListeners();
  }

  void removeSelectedCategoryIds(int categoryId) {
    _selectedCategoryIds.remove(categoryId);
    //notifyListeners();
  }

  List<int> getSelectedCategoryIds() {
    return _selectedCategoryIds;
  }

  void setCategoryId(int categoryId) {
    _categoryId = categoryId;
    notifyListeners();
  }

  int getCategoryId() {
    if (_categoryId != null) {
      return _categoryId!;
    }
    return 0;
  }
}
