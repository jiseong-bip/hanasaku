import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/auth/sign_up_screen.dart';
import 'package:hanasaku/main.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  String? _selectedReason;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _clearImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.jpg';

    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _deleteImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.jpg';
    final imageFile = File(imagePath);

    if (await imageFile.exists()) {
      await imageFile.delete();
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final auth = Provider.of<AuthenticationRepository>(context, listen: false);
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation DeleteAccount {
          deleteAccount {
            ok
          }
        }
      '''),
      update: (cache, result) => result,
    );
    // 로딩 대화상자 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Loading..."),
            ],
          ),
        );
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

        if (resultData != null && resultData['deleteAccount'] != null) {
          final bool isLikeSuccessful = resultData['deleteAccount']['ok'];
          if (isLikeSuccessful) {
            await userInfoProvider.clearUserInfo();
            await auth.deleteAccount(context);
            FirebaseMessaging.instance.deleteToken();
            _deleteImage();
            MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                (route) => false);

            // Call the callback to notify PostWidget of the change in isLiked
            print('succes to delete user');
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
      MyApp.navigatorKey.currentState!.pop();
      print("Error occurred: $e");
      // You can also display an error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('勘定脱退'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('本当に脱退しますか?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text(
                "アカウントを削除すると、会員様のすべての情報とすべての投稿、コメント、写真が削除されます。\ngoogle、twitter、appleでログインした場合は、該当サイトから私たちのアプリのアクセス権限を削除することができます。",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedReason,
              hint: const Text('退会する理由を選択してください。'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedReason = newValue;
                });
              },
              items: <String>['利用が不便で障害が多くて', '使用頻度が低いため', 'コンテンツ不満足', 'その他の事項']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const Spacer(),
            Center(
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(16.0),
                color: Theme.of(context).primaryColor,
                onPressed: _selectedReason != null
                    ? () async {
                        // TODO: 탈퇴 로직 추가
                        await _clearImage();
                        await deleteAccount(context);
                      }
                    : null,
                child: const Text('脱退する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
