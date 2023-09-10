// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/auth/form_button.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/setup/set_profile.dart';
import 'package:provider/provider.dart';

class PasswordScreen extends StatefulWidget {
  final String email;
  const PasswordScreen({super.key, required this.email});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  //textField controll을 위한 컨트롤러
  //widget을 controll하기 위해 controller를 따로 만들어줘야함
  //controller 생성 -> Controller 위젝에 넘겨주기 -> 리스너 생성 -> 변화감지
  final TextEditingController _passwordController = TextEditingController();
  bool _hasSubmittedOnce = false;

  String _password = "";

  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {
        _password = _passwordController.text;
      });
    });
  }

  //Widget이 제거 될 때 dispose를 이용해 메모리를 정리
  //항상 dispose 해주는것 잊지 않기!
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid() {
    return _password.isNotEmpty && _password.length > 8;
  }

  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  void _onSubmit() async {
    final authRepo = context.read<AuthenticationRepository>();

    if (!_hasSubmittedOnce) {
      try {
        // On first press, sign up the user and send verification email
        await authRepo.signUpWithEmailAndPassword(widget.email, _password);
        await authRepo.sendVerificationEmail();
        _hasSubmittedOnce = true;
        setState(() {});
      } catch (e) {
        // Handle the exception (e.g., show a Snackbar with an error message)
      }
    }
    print(await authRepo.isEmailVerified());
    // Check if the email is verified
    if (await authRepo.isEmailVerified()) {
      // If verified, navigate to SetProfile
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SetProfile(),
          ));
    } else {
      // If not verified, show the dialog to verify email
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verify Your Email'),
          content: const Text('Please verify your email before proceeding.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _onClearTap() {
    _passwordController.clear();
  }

  void _toggleObscureText() {
    _obscureText = !_obscureText;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Sign up",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.v40,
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: Sizes.size24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gaps.v16,
              TextField(
                controller: _passwordController,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                onEditingComplete: _onSubmit,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  //텍스트 필드에 이모티콘 추가
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _onClearTap,
                        child: FaIcon(
                          FontAwesomeIcons.solidCircleXmark,
                          color: Colors.grey.shade400,
                          size: Sizes.size20,
                        ),
                      ),
                      Gaps.h14,
                      GestureDetector(
                        onTap: _toggleObscureText,
                        child: FaIcon(
                          _obscureText
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          color: Colors.grey.shade400,
                          size: Sizes.size20,
                        ),
                      ),
                    ],
                  ),

                  hintText: "Make it Strong",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                cursorColor: Theme.of(context).primaryColor,
              ),
              Gaps.v10,
              const Text(
                'Your password must have :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.circleCheck,
                      size: Sizes.size20,
                      color: _isPasswordValid()
                          ? Colors.green
                          : Colors.grey.shade400),
                  Gaps.h5,
                  const Text('8 to 20 charactres')
                ],
              ),
              Gaps.v28,
              FormButton(
                disabled: !_isPasswordValid(),
                onTap: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
