// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/setup/check_user.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:twitter_login/twitter_login.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool get isLoggedIn => user != null;
  User? get user => _firebaseAuth.currentUser;

  Future<void> signUpWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      String? errorCode;
      switch (error.code) {
        case "email-already-in-use":
          errorCode = "使用中のEメールアドレス";
          break;
        case "invalid-email":
          errorCode = "Eメールが無効です";
          break;
        case "weak-password":
          errorCode = "強力なパスワードを作成してください";
          break;
        case "正しくないアプローチです":
          errorCode = error.code;
          break;
        default:
          errorCode = null;
      }

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: FittedBox(
            child: Center(
              child: Text('$errorCode'),
            ),
          ),
          actions: <Widget>[
            Center(
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(16.0),
                color: Theme.of(context).primaryColor,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    final authRepo = context.read<AuthenticationRepository>();
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = await authRepo.getUserUid();
      print(uid);

      await GetUserInfo().checkingUser(client, userInfoProvider, uid!);
    } on FirebaseAuthException catch (error) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: FittedBox(
            child: Center(
              child: Text(error.code),
            ),
          ),
          actions: <Widget>[
            Center(
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(16.0),
                color: Theme.of(context).primaryColor,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );

      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  Future<String?> getUserUid() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  Future<void> signInWithGoogle(
      BuildContext context, UserInfoProvider userInfoProvider) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      // 사용자가 '취소'를 클릭한 경우
      if (googleSignInAccount == null) {
        print("Google sign-in was cancelled");
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      final uid = await getUserUid();
      print(uid);

      await GetUserInfo().checkingUser(client, userInfoProvider, uid!);
    } catch (e) {
      print("Error during Google sign-in: $e");
      rethrow;
    }
  }

  Future<void> signInWithTwitter(
      BuildContext context, UserInfoProvider userInfoProvider) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final twitterLogin = TwitterLogin(
      // Consumer API keys
      apiKey: 'Ulxy9rMz0GxHYz5So9P6YIy2U',
      // Consumer API Secret keys
      apiSecretKey: 'wdt2ZNpB5W9lVqD9OQRkynanqrUBFGTPCtkRmFJoaOZyBxa747',
      // Registered Callback URLs in TwitterApp
      // Android is a deeplink
      // iOS is a URLScheme
      redirectURI: 'hanasaku://',
    );
    final authResult = await twitterLogin.login();
    switch (authResult.status) {
      case TwitterLoginStatus.loggedIn:
        final AuthCredential twitterAuthCredential =
            TwitterAuthProvider.credential(
                accessToken: authResult.authToken!,
                secret: authResult.authTokenSecret!);

        final userCredential =
            await _firebaseAuth.signInWithCredential(twitterAuthCredential);
        print(userCredential);

        final uid = await getUserUid();
        print(uid);

        await GetUserInfo().checkingUser(client, userInfoProvider, uid!);

        // success
        break;
      case TwitterLoginStatus.cancelledByUser:
        // cancel
        break;
      case TwitterLoginStatus.error:
        // error
        break;
      default:
        return;
    }
  }

  Future<String?> getFirebaseToken(String lineAccessToken) async {
    final response = await http.post(
      Uri.parse(
          'https://us-central1-hanasaku-abc.cloudfunctions.net/createFirebaseToken/https://us-central1-hanasaku-abc.cloudfunctions.net/createFirebaseToken'),
      body: {'access_token': lineAccessToken},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['firebase_token'];
    } else {
      print('Failed to get Firebase token: ${response.body}');
      return null;
    }
  }

  Future<void> loginWithLine(
      BuildContext context, UserInfoProvider userInfoProvider) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    try {
      final result =
          await LineSDK.instance.login(scopes: ["profile", "openid"]);

      final lineAccessToken = result.userProfile?.userId;

      final firebaseToken = await getFirebaseToken(lineAccessToken!);

      if (firebaseToken != null) {
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        // 로그인 성공, 원하는 화면으로 이동
        final uid = await getUserUid();
        print(uid);

        await GetUserInfo().checkingUser(client, userInfoProvider, uid!);
      } else {
        // Firebase 커스텀 토큰 가져오기 실패
        print('fail');
        return;
      }
    } catch (e) {
      print('Failed to login with LINE: $e');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      // 현재 로그인한 사용자 가져오기
      User? currentUser = _firebaseAuth.currentUser;

      print('currentUser: ${currentUser?.providerData}');

      if (currentUser != null) {
        // 사용자의 로그인 방법 확인
        AuthCredential? credential;
        if (currentUser.providerData.isEmpty) {
          // final result =
          //     await LineSDK.instance.login(scopes: ["profile", "openid"]);

          // final lineAccessToken = result.userProfile?.userId;

          // final firebaseToken = await getFirebaseToken(lineAccessToken!);
          // credential = await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
          await currentUser.delete();
          return;
        }
        final providerId = currentUser.providerData[0].providerId;

        switch (providerId) {
          case 'google.com':
            // Google 계정으로 로그인한 경우
            final GoogleSignIn googleSignIn = GoogleSignIn();
            final googleUser = await googleSignIn
                .signInSilently(); // 현재 로그인한 Google 계정 정보 가져오기
            if (googleUser != null) {
              final googleAuth = await googleUser.authentication;
              credential = GoogleAuthProvider.credential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken,
              );
            }
            break;

          case 'twitter.com':
            // TODO: Twitter 계정으로 로그인한 경우 재인증 로직 추가
            final twitterLogin = TwitterLogin(
              // Consumer API keys
              apiKey: 'Ulxy9rMz0GxHYz5So9P6YIy2U',
              // Consumer API Secret keys
              apiSecretKey:
                  'wdt2ZNpB5W9lVqD9OQRkynanqrUBFGTPCtkRmFJoaOZyBxa747',
              // Registered Callback URLs in TwitterApp
              // Android is a deeplink
              // iOS is a URLScheme
              redirectURI: 'hanasaku://',
            );
            final authResult = await twitterLogin.login();
            switch (authResult.status) {
              case TwitterLoginStatus.loggedIn:
                final AuthCredential twitterAuthCredential =
                    TwitterAuthProvider.credential(
                        accessToken: authResult.authToken!,
                        secret: authResult.authTokenSecret!);
                credential = twitterAuthCredential;
                // success
                break;
              case TwitterLoginStatus.cancelledByUser:
                // cancel
                return;
              case TwitterLoginStatus.error:
                // error
                return;
              default:
                return;
            }
            break;

          case 'password':
            // TODO: 이메일/비밀번호로 로그인한 경우 재인증 로직 추가
            TextEditingController emailController = TextEditingController();
            TextEditingController passwordController = TextEditingController();
            String email = '';
            String password = '';
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: FittedBox(
                  child: Center(
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(hintText: 'Email'),
                        ),
                        TextField(
                          controller: passwordController,
                          decoration:
                              const InputDecoration(hintText: 'password'),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  Center(
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context).primaryColor,
                      child: const Text('OK'),
                      onPressed: () {
                        email = emailController.text;
                        password = passwordController.text;
                      },
                    ),
                  ),
                ],
              ),
            );
            credential =
                EmailAuthProvider.credential(email: email, password: password);
            break;

          // 기타 다른 로그인 방법에 대한 재인증 로직 추가
        }

        if (credential != null) {
          await currentUser.reauthenticateWithCredential(credential);
          await currentUser.delete();
        } else {
          print("재인증에 필요한 credential이 없습니다.");
          await currentUser.delete();
        }
      }
    } catch (e) {
      print("계정 삭제 중 오류 발생: $e");

      rethrow;
    }
  }
}
