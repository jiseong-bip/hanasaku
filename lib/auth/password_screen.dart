// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/auth/form_button.dart';
import 'package:hanasaku/auth/login_form_screen.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/main.dart';
import 'package:hanasaku/setup/check_user.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({
    super.key,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  //textField controll을 위한 컨트롤러
  //widget을 controll하기 위해 controller를 따로 만들어줘야함
  //controller 생성 -> Controller 위젝에 넘겨주기 -> 리스너 생성 -> 변화감지
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _hasSubmittedOnce = false;

  String _password = "";
  String _email = "";

  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {
        _password = _passwordController.text;
      });
    });
    _emailController.addListener(() {
      setState(() {
        _email = _emailController.text;
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
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    bool isGetError = false;
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
              Text("로딩 중..."),
            ],
          ),
        );
      },
    );

    if (!_hasSubmittedOnce) {
      try {
        await authRepo.signUpWithEmailAndPassword(context, _email, _password);
        await authRepo.sendVerificationEmail();
        _hasSubmittedOnce = true;
        isGetError = false;
        setState(() {});
      } catch (error) {
        print(error);
        isGetError = true;
        return;
        // 로딩 대화상자 닫기
        // 에러 메시지 처리
        //Navigator.of(context).pop(); // 로딩 대화상자 닫기
      }
    }
    if (!isGetError) {
      if (await authRepo.isEmailVerified()) {
        final uid = await authRepo.getUserUid();

        await GetUserInfo()
            .checkingUser(context, client, userInfoProvider, uid!);
      } else {
        Navigator.of(context).pop(); // 로딩 대화상자 닫기
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: const FittedBox(
                child: Center(child: Text('続行する前に、電子メールを確認してください。'))),
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
      }
    }
  }

  String? _isEmailValid() {
    if (_email.isEmpty) return null;
    final regExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!regExp.hasMatch(_email)) {
      return "Email no valid";
    }

    return null;
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.v40,
                const Text(
                  "what is your Email?",
                  style: TextStyle(
                    fontSize: Sizes.size24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.v16,
                TextField(
                  controller: _emailController,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  onEditingComplete: _onSubmit,
                  decoration: InputDecoration(
                    hintText: "Email",
                    errorText: _isEmailValid(),
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
                Gaps.v16,
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
                  disabled: !_isPasswordValid() || _isEmailValid() != null,
                  onTap: _onSubmit,
                ),
                Gaps.v16,
                Center(
                    child: Column(
                  children: [
                    Text(
                      'すでにIDがありますか',
                      style: TextStyle(
                          fontSize: Sizes.size12, color: Colors.grey.shade400),
                    ),
                    GestureDetector(
                      onTap: () {
                        MyApp.navigatorKey.currentState!.pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const LoginFormScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).primaryColor))),
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
