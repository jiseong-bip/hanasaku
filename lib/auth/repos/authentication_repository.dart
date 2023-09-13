// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/setup/check_user.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:twitter_login/twitter_login.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool get isLoggedIn => user != null;
  User? get user => _firebaseAuth.currentUser;

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
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
    print(user);
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
      print(result.userProfile?.userId);

      final lineAccessToken = result.userProfile?.userId;

      final firebaseToken = await getFirebaseToken(lineAccessToken!);
      print(firebaseToken);
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
}
