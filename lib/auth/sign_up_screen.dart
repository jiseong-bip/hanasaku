import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/auth/auth_button.dart';
import 'package:hanasaku/auth/password_screen.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  void _onEmailTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gaps.v80,
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: Sizes.size24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      "to",
                      style: TextStyle(
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "HANASAKU",
                      style: TextStyle(
                          fontSize: Sizes.size32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      "僕らのアイドル物語",
                      style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade300),
                    ),
                  ],
                ),
              ),
              Gaps.v40,
              const AuthButton(
                icon: FaIcon(FontAwesomeIcons.apple),
                text: 'Continue with Apple',
                loginType: 'apple',
              ),
              Gaps.v16,
              const AuthButton(
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                text: 'Continue with Google',
                loginType: 'google',
              ),
              Gaps.v16,
              const AuthButton(
                icon: FaIcon(
                  FontAwesomeIcons.line,
                  color: Colors.green,
                ),
                text: 'Continue with Line',
                loginType: 'line',
              ),
              Gaps.v16,
              const AuthButton(
                icon: FaIcon(FontAwesomeIcons.twitter, color: Colors.blue),
                text: 'Continue with twitter',
                loginType: 'twitter',
              ),
            ],
          ),
        ),
      ),
      bottomSheet: BottomAppBar(
        color: Colors.grey.shade50,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Sizes.size32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                child: Column(
                  children: [
                    const Text('Already have an account?'),
                    Gaps.h5,
                    GestureDetector(
                      onTap: () => _onEmailTap(context),
                      child: Text(
                        'Start with Email',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
