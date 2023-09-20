// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/auth/login_form_screen.dart';
import 'package:hanasaku/auth/mail_screen.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/auth/sign_up_screen.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final FaIcon icon;
  final String loginType;

  const AuthButton({
    super.key,
    required this.text,
    required this.icon,
    required this.loginType,
  });

  Future<void> _onAuthButtonTap(BuildContext context) async {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    if (loginType == "google") {
      try {
        await AuthenticationRepository()
            .signInWithGoogle(context, userInfoProvider);
      } catch (e) {
        // Handle any login errors here.
        print(e);
        return;
      }
    } else if (loginType == "line") {
      try {
        await AuthenticationRepository()
            .loginWithLine(context, userInfoProvider);
      } catch (e) {
        // Handle any login errors here.
        print(e);
        return;
      }
    } else if (loginType == "twitter") {
      try {
        await AuthenticationRepository()
            .signInWithTwitter(context, userInfoProvider);
      } catch (e) {
        // Handle any login errors here.
        print(e);
        return;
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(const SnackBar(content: Text('Google 로그인에 실패했습니다.')));
      }
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => _page()));
    }
  }

  Widget _page() {
    switch (loginType) {
      case "email":
        return const LoginFormScreen();
      default:
        return const SignUpScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext innerContext) {
      return GestureDetector(
        onTap: () {
          _onAuthButtonTap(innerContext);
        },
        child: FractionallySizedBox(
          //부모의 크기에 비례해서 크기를 정해주는 위젯(상대적인 크기에 비례)
          widthFactor: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.size14,
              horizontal: Sizes.size14,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: Sizes.size1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: icon,
                ),
                Text(
                  //expand column이나 Row내의 공간을 다 쓰게 할 수 있음
                  text,
                  style: const TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
