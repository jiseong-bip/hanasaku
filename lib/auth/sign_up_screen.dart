import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/auth/auth_button.dart';
import 'package:hanasaku/auth/mail_screen.dart';
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
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.size40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gaps.v80,
              Text(
                "Sign up for Hanasaku",
                style: TextStyle(
                  fontSize: Sizes.size24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gaps.v20,
              Text(
                "Create a profile, follow other accounts, make your own videos, and more.",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
              Gaps.v40,
              Gaps.v16,
              AuthButton(
                icon: FaIcon(FontAwesomeIcons.apple),
                text: 'Continue with Apple',
                loginType: 'apple',
              ),
              Gaps.v16,
              AuthButton(
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                text: 'Continue with Google',
                loginType: 'google',
              ),
              Gaps.v16,
              AuthButton(
                icon: FaIcon(
                  FontAwesomeIcons.line,
                  color: Colors.green,
                ),
                text: 'Continue with Line',
                loginType: 'line',
              ),
              Gaps.v16,
              AuthButton(
                icon: FaIcon(FontAwesomeIcons.twitter, color: Colors.blue),
                text: 'Continue with twitter',
                loginType: 'twitter',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
