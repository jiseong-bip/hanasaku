import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

      if (resultData != null && resultData['reportComment'] != null) {
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
