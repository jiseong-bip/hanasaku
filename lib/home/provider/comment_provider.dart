import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/query&mutation/query.dart'; // GraphQL 쿼리가 있는 곳을 가정합니다.

class CommentsModel extends ChangeNotifier {
  final Map<int, List> _postsByPostId = {}; // 게시물 ID를 키로 사용하는 맵

  List getCommentsByPostId(int postId) => _postsByPostId[postId] ?? [];

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
        notifyListeners(); // UI에 변경 사항을 알립니다.
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }
}
