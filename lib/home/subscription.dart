import 'package:graphql_flutter/graphql_flutter.dart';

final likeSubscription = gql(
  r'''
    subscription Subscription {
      postLikeAlarm {
        post {
      title
    }
    user {
      userName
    }
      }
    }
  ''',
);

final commentSubscription = gql(
  r'''
    subscription Subscription {
        postCommentAlarm {
    post {
      title
    }
    user {
      userName
    }
  }
    }
  ''',
);
