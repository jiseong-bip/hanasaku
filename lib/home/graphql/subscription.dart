import 'package:graphql_flutter/graphql_flutter.dart';

final likeSubscription = gql(
  r'''
    subscription Subscription {
      postLikeAlarm {
        post {
          id
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
          id
          title
        }
        user {
          userName
        }
      }
    }
  ''',
);
