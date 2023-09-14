// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';

// class AuthStateModel extends ChangeNotifier {
//   final AuthenticationRepository _authRepo;
//   User? _user;

//   AuthStateModel(this._authRepo) {
//     _user = _authRepo.user;
//     _authRepo.authStateChanges.listen((user) {
//       _user = user;
//       notifyListeners();
//     });
//   }

//   User? get user => _user;
//   bool get isLoggedIn => _user != null;

//   Future<void> signUp(String email, String password) async {
//     await _authRepo.signUpWithEmailAndPassword(email, password);
//   }

//   Future<void> signIn(String email, String password) async {
//     await _authRepo.signInWithEmailAndPassword(email, password);
//   }

//   Future<void> signOut() async {
//     await _authRepo.signOut();
//   }
// }

class ListResultModel extends ChangeNotifier {
  List<Map<String, dynamic>?> listResult = [];

  void addResult(Map<String, dynamic> data) {
    listResult.add(data);
    print(listResult);
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
      print(listResult);
    }
    if (commentData != null &&
        !listResult.any((item) => jsonEncode(item) == commentResultsJson)) {
      addResult(commentData);
    }
  }
}
