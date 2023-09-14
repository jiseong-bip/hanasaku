import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/query&mutation/query.dart';
// GraphQL 쿼리가 있는 곳을 가정합니다.

class CommentsModel extends ChangeNotifier {
  final Map<int, List> _postsByPostId = {}; // 게시물 ID를 키로 사용하는 맵
  final Map<int, List<bool>> _commentsIsLikesByPostId = {};
  final Map<int, List<bool>> _isRecommentShowedByPostId = {};
  final Map<int, List> _commentLIkesCount = {};

  void setLikesCount(int postId, int index, int count) {
    _commentLIkesCount[postId]![index] = count;
    notifyListeners();
  }

  List getLikesCount(int postId) {
    return _commentLIkesCount[postId]!;
  }

  List getCommentsByPostId(int postId) => _postsByPostId[postId] ?? [];
  List<bool> getCommentsLikesCountByPostId(int postId) =>
      _commentsIsLikesByPostId[postId] ?? [];
  List<bool> getIsRecommentShowedByPostId(int postId) =>
      _isRecommentShowedByPostId[postId] ?? [];

  void setCommentLikeStatusByPostId(int postId, int commentIndex, bool status) {
    if (!_commentsIsLikesByPostId.containsKey(postId)) {
      _commentsIsLikesByPostId[postId] = [];
    }
    _commentsIsLikesByPostId[postId]![commentIndex] = status;
    notifyListeners();
  }

  void setRecommentShowStatusByPostId(
      int postId, int commentIndex, bool status) {
    if (!_isRecommentShowedByPostId.containsKey(postId)) {
      _isRecommentShowedByPostId[postId] = [];
    }
    _isRecommentShowedByPostId[postId]![commentIndex] = status;
    notifyListeners();
  }

  Future<void> fetchMoreComments(
      GraphQLClient client, int postId, FetchPolicy fetchPolicy) async {
    final QueryOptions options = QueryOptions(
      document: commentPostQuery,
      variables: {
        'viewPostPostId2': postId,
      },
      fetchPolicy: fetchPolicy,
    );

    try {
      final QueryResult result = await client.query(options);
      if (!result.hasException) {
        _postsByPostId[postId] = result.data!['viewPost']['comments'];
        _commentsIsLikesByPostId[postId] = result.data!['viewPost']['comments']
            .map((comment) => comment['isLiked'] as bool)
            .toList();
        _isRecommentShowedByPostId[postId] = result.data!['viewPost']
                ['comments']
            .map((comment) => (comment['recomments'].length <= 3))
            .toList();
        //setLikesCount(postId, ,_commentsIsLikesByPostId[postId]!.length);
        notifyListeners(); // UI에 변경 사항을 알립니다.
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }
}
