// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

Future<void> deletePost(BuildContext context, int postId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation DeletePost(\$postId: Int!) {
          deletePost(postId: \$postId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{
      'postId': postId,
    },
    update: (cache, result) => result,
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Handle errors
      print("Error occurred: ${result.exception.toString()}");
      // You can also display an error message to the user if needed
    } else {
      final dynamic resultData = result.data;

      if (resultData != null && resultData['deletePost'] != null) {
        final bool isLikeSuccessful = resultData['deletePost']['ok'];
        if (isLikeSuccessful) {
        } else {
          // Handle the case where the like operation was not successful
          print("Like operation was not successful.");
          // You can also display a message to the user if needed
        }
      } else {
        // Handle the case where data is null
        print("Data is null.");
        // You can also display a message to the user if needed
      }
    }
  } catch (e) {
    // Handle exceptions
    print("Error occurred: $e");
    // You can also display an error message to the user if needed
  }
}

Future<void> reportPost(BuildContext context, int postId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation ReportPost(\$postId: Int!) {
          reportPost(postId: \$postId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{
      'postId': postId,
    },
    update: (cache, result) => result,
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Handle errors
      print("Error occurred: ${result.exception.toString()}");
      // You can also display an error message to the user if needed
    } else {
      final dynamic resultData = result.data;

      if (resultData != null && resultData['reportPost'] != null) {
        final bool isLikeSuccessful = resultData['reportPost']['ok'];
        if (isLikeSuccessful) {
          // ignore: use_build_context_synchronously
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Column(
                      children: <Widget>[
                        Text(
                          '通報が寄せられました。\n申告した内容はこれ以上表示されません。',
                          style: TextStyle(),
                        ),
                      ],
                    ),
                    // content: Text('Of course not!'),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          //reportPost
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Sizes.size10,
                                vertical: Sizes.size5,
                              ),
                              child: Text(
                                'はい。',
                                style: TextStyle(
                                    fontSize: Sizes.size16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
        } else {
          // Handle the case where the like operation was not successful
          print("Like operation was not successful.");
          // You can also display a message to the user if needed
        }
      } else {
        // Handle the case where data is null
        print("Data is null.");
        // You can also display a message to the user if needed
      }
    }
  } catch (e) {
    // Handle exceptions
    print("Error occurred: $e");
    // You can also display an error message to the user if needed
  }
}

Future<void> toggleLikeComment(BuildContext context, int commentId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation Mutation(\$commentId: Int!) {
          likeComment(commentId: \$commentId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{
      "commentId": commentId,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Handle errors
      print("Error occurred: ${result.exception.toString()}");
      // You can also display an error message to the user if needed
    } else {
      final dynamic resultData = result.data;

      if (resultData != null && resultData['likeComment'] != null) {
      } else {
        // Handle the case where data is null
        print("Data is null.");
        // You can also display a message to the user if needed
      }
    }
  } catch (e) {
    // Handle exceptions
    print("Error occurred: $e");
    // You can also display an error message to the user if needed
  }
}

Future<void> reportComment(BuildContext context, int commentId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation Mutation(\$commentId: Int!) {
          reportComment(commentId: \$commentId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{
      "commentId": commentId,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Handle errors
      print("Error occurred: ${result.exception.toString()}");
      // You can also display an error message to the user if needed
    } else {
      final dynamic resultData = result.data;

      if (resultData != null && resultData['reportComment'] != null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Column(
                    children: <Widget>[
                      Text(
                        '通報が寄せられました。',
                      ),
                    ],
                  ),
                  // content: Text('Of course not!'),
                  content: FittedBox(
                    child: Column(
                      children: [
                        const Text('申告した内容はこれ以上表示されません。'),
                        Gaps.v24,
                        Gaps.v2,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              //reportPost
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context).primaryColor),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Sizes.size10,
                                    vertical: Sizes.size5,
                                  ),
                                  child: Text(
                                    'はい。',
                                    style: TextStyle(
                                        fontSize: Sizes.size16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
      } else {
        // Handle the case where data is null
        print("Data is null.");
        // You can also display a message to the user if needed
      }
    }
  } catch (e) {
    // Handle exceptions
    print("Error occurred: $e");
    // You can also display an error message to the user if needed
  }
}

Future<void> deleteComment(BuildContext context, int commentId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation DeleteComment(\$commentId: Int!) {
          deleteComment(commentId: \$commentId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{
      "commentId": commentId,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Handle errors
      print("Error occurred: ${result.exception.toString()}");
      // You can also display an error message to the user if needed
    } else {
      final dynamic resultData = result.data;

      if (resultData != null && resultData['deleteComment'] != null) {
        print('delete success');
      } else {
        // Handle the case where data is null
        print("Data is null.");
        // You can also display a message to the user if needed
      }
    }
  } catch (e) {
    // Handle exceptions
    print("Error occurred: $e");
    // You can also display an error message to the user if needed
  }
}

Future<void> setCategoryId(BuildContext context, int category) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation Mutation(\$categoryId: Int!) {
          selectCategory(categoryId: \$categoryId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{"categoryId": category},
    update: (cache, result) => result,
  );

  try {
    final QueryResult result = await client.mutate(options);
    if (result.data!['selectCategory']['ok']) {
      print('setCategory ok');
    }
  } catch (e) {
    print(e);
  }
}

Future<void> deleteCategoryId(BuildContext context, int category) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation DeleteCategory(\$categoryId: Int!) {
          deleteCategory(categoryId: \$categoryId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{"categoryId": category},
    update: (cache, result) => result,
  );

  try {
    final QueryResult result = await client.mutate(options);
    if (result.data!['deleteCategory']['ok']) {
      print('deleteCategory ok');
    }
  } catch (e) {
    print(e);
  }
}

Future<void> deleteReComment(BuildContext context, int reCommentId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation DeleteComment(\$commentId: Int!) {
          deleteComment(commentId: \$commentId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{
      "commentId": reCommentId,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Handle errors
      print("Error occurred: ${result.exception.toString()}");
      // You can also display an error message to the user if needed
    } else {
      final dynamic resultData = result.data;

      if (resultData != null && resultData['deleteComment'] != null) {
      } else {
        // Handle the case where data is null
        print("Data is null.");
        // You can also display a message to the user if needed
      }
    }
  } catch (e) {
    // Handle exceptions
    print("Error occurred: $e");
    // You can also display an error message to the user if needed
  }
}

Future<void> reportReComment(BuildContext context, int reCommentId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;

  final MutationOptions options = MutationOptions(
    document: gql('''
        mutation Mutation(\$commentId: Int!) {
          likeComment(commentId: \$commentId) {
            ok
          }
        }
      '''),
    variables: <String, dynamic>{
      "commentId": reCommentId,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Handle errors
      print("Error occurred: ${result.exception.toString()}");
      // You can also display an error message to the user if needed
    } else {
      final dynamic resultData = result.data;

      if (resultData != null && resultData['reportComment'] != null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Column(
                    children: <Widget>[
                      Text(
                        '通報が寄せられました。',
                        style: TextStyle(),
                      ),
                    ],
                  ),
                  // content: Text('Of course not!'),
                  content: Column(
                    children: [
                      const Text('申告した内容はこれ以上表示されません。'),
                      Gaps.v24,
                      Gaps.v2,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            //reportPost
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Sizes.size10,
                                  vertical: Sizes.size5,
                                ),
                                child: Text(
                                  'はい。',
                                  style: TextStyle(
                                      fontSize: Sizes.size16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
      } else {
        // Handle the case where data is null
        print("Data is null.");
        // You can also display a message to the user if needed
      }
    }
  } catch (e) {
    // Handle exceptions
    print("Error occurred: $e");
    // You can also display an error message to the user if needed
  }
}
