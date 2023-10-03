// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hanasaku/setup/local_notification.dart';

class ListResultModel extends ChangeNotifier {
  List<Map<String, dynamic>?> listResult = [];

  void addResult(Map<String, dynamic> data) {
    listResult.add(data);
    notifyListeners();
  }

  void clear() {
    listResult.clear();
    notifyListeners();
  }

  void updateList(dynamic likeData, dynamic commentData) {
    String likeResultsJson = jsonEncode(likeData);
    String commentResultsJson = jsonEncode(commentData);

    if (likeData != null &&
        !listResult.any((item) => jsonEncode(item) == likeResultsJson)) {
      addResult(likeData);
    }
    if (commentData != null &&
        !listResult.any((item) => jsonEncode(item) == commentResultsJson)) {
      addResult(commentData);
    }
  }
}
