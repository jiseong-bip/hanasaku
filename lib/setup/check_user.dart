// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/nav/main_nav.dart';
import 'package:hanasaku/query&mutation/mutatuin.dart';
import 'package:hanasaku/query&mutation/query.dart';
import 'package:hanasaku/setup/navigator.dart';
import 'package:hanasaku/setup/set_profile.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';

class GetUserInfo {
  Future<void> checkingUser(GraphQLClient client,
      UserInfoProvider userInfoProvider, String uid) async {
    final MutationOptions options = MutationOptions(
      document: checkUser,
      variables: <String, dynamic>{"checkUserId": uid},
    );

    try {
      final QueryResult result = await client.mutate(options);
      print(3);
      if (result.hasException) {
        // Handle errors
        print(4);
        print("Error occurred: ${result.exception.toString()}");
      } else {
        final dynamic resultData = result.data;
        if (resultData != null) {
          final token = resultData['checkUser']['token'];
          print(token);
          if (token != null) {
            // Store the token
            await userInfoProvider.setToken(token);

            await getUserInfo(client, userInfoProvider);
            // Print the token to the console
            print("Successfully received token: $token");
            // After receiving the token, navigate to MyHomePage
            navigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(builder: (context) => const MainNav()),
            );
          } else {
            print("Token is null.");
            navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SetProfile()),
                (route) => false);
          }
        } else {
          // Handle the case where data is null
          print("Data is null.");
        }
      }
    } catch (e) {
      print(1);
      // Handle exceptions
      print("Error occurred: $e");
    }
  }

  Future<void> getUserInfo(
      GraphQLClient client, UserInfoProvider userInfoProvider) async {
    final QueryOptions options = QueryOptions(
      document: myInfoQuery,
      fetchPolicy: FetchPolicy.networkOnly,
    );
    try {
      final QueryResult result = await client.query(options);
      if (result.hasException) {
        print("Error occurred: ${result.exception.toString()}");
      } else {
        var userName = result.data!['me']['userName'];
        await userInfoProvider.setNickName(userName);
        List<Map<String, dynamic>> category = result.data!['me']['category'];
        await userInfoProvider.setCategory(category);
      }
    } catch (e) {
      print(e);
    }
  }
}
