import 'package:flutter/material.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/auth/sign_up_screen.dart';

import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class LogOutScreen extends StatefulWidget {
  const LogOutScreen({super.key});

  @override
  State<LogOutScreen> createState() => _LogOutScreenState();
}

class _LogOutScreenState extends State<LogOutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그아웃")),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleLogOut,
          child: const Text("로그아웃"),
        ),
      ),
    );
  }

  Future<void> _handleLogOut() async {
    // Firebase 로그아웃
    final auth = Provider.of<AuthenticationRepository>(context, listen: false);
    await auth.signOut();

    // Hive에서 사용자 정보 삭제
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.clearUserInfo();

    // 로그인 화면 또는 홈 화면으로 이동 (또는 원하는 다른 화면으로)
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
        (route) => false);
  }
}
