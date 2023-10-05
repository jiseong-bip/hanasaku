// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';

class ListResultModel extends ChangeNotifier {
  List<Map<String, dynamic>?> pushNotiList = [];

  void addResult(Map<String, dynamic> data) {
    pushNotiList.add(data);
    notifyListeners();
  }

  void clear() {
    pushNotiList.clear();
    notifyListeners();
  }

  void updateList(dynamic pushNotiData) {
    String likeResultsJson = jsonEncode(pushNotiData);

    if (pushNotiData != null &&
        !pushNotiList.any((item) => jsonEncode(item) == likeResultsJson)) {
      addResult(pushNotiData);
      print(pushNotiData);
    }
  }
}
