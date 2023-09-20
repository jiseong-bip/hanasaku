// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:hanasaku/setup/aws_s3.dart';

class PostInfo with ChangeNotifier {
  int? _commentId;
  bool _recommentMode = false;
  String? _currentComment;
  List _comments = [];
  final List _commentsLikesCount = [];
  final List<bool> _isRecommentShowed = [];
  final List<bool> _isLikedList = [];
  List<Object?> avatarImagekey = [];

  void setRecommentShowed(int index) {
    _isRecommentShowed[index] = !_isRecommentShowed[index];
  }

  List<bool> getRecommentShoewd() {
    return _isRecommentShowed;
  }

  List<bool> getIsLikedList() {
    return _isLikedList;
  }

  List getCommentLikesCount() {
    return _commentsLikesCount;
  }

  void setCommentid(int commentId) {
    _commentId = commentId;
    notifyListeners();
  }

  Future<void> setCommentUserAvatar() async {
    for (var comment in _comments) {
      if (comment['user']['avatar'] != null) {
        avatarImagekey.add(
            {'__typename': 'userAvator', 'avatar': comment['user']['avatar']});
      }
    }
    await getImage(avatarImagekey);
    print('set avator done');
  }

  void clearAvatorKey() {
    avatarImagekey.clear();
  }

  void setRecommentMode(bool recommentMode) {
    _recommentMode = recommentMode;
    notifyListeners();
  }

  void setCurrentComment(String currentComment) {
    _currentComment = currentComment;
    notifyListeners();
  }

  void setComments(dynamic commentList) {
    _comments.clear();
    _isRecommentShowed.clear();
    _isLikedList.clear();
    _commentsLikesCount.clear();
    _comments = commentList;
    for (var comment in _comments) {
      if (comment['likes'] != null) {
        _commentsLikesCount.add(comment['likes'].length);
        _isLikedList.add(comment['isLiked']);
        if (comment['recomments'] != null) {
          if (comment['recomments'].length > 3) {
            _isRecommentShowed.add(false);
          } else {
            _isRecommentShowed.add(true);
          }
        }
      }
    }
    notifyListeners();
  }

  List? getComments() {
    return _comments;
  }

  int getCommentId() {
    if (_commentId != null) {
      return _commentId!;
    } else {
      return 0;
    }
  }

  bool getRecommentMode() {
    return _recommentMode;
  }

  String getComment() {
    if (_currentComment != null) {
      return _currentComment!;
    } else {
      return "";
    }
  }
}
