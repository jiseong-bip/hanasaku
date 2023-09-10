// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/auth/form_button.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/nav/main_nav.dart';
import 'package:hanasaku/query&mutation/mutatuin.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class SetProfile extends StatefulWidget {
  const SetProfile({Key? key}) : super(key: key);

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  String name = '';
  String selectedAge = "15"; // 기본 나이 선택
  String selectedGender = ""; // 기본 성별 선택
  bool isMaleSelected = false;
  bool isFemaleSelected = false;
  String errorText = '';
  bool isTokenCome = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _fetchUid();
  }

  _fetchUid() async {
    final authRepo = AuthenticationRepository();
    final uid = await authRepo.getUserUid();
    setState(() {
      _uid = uid;
    });
  }

  bool isFormValid() {
    return name.isNotEmpty &&
        selectedAge.isNotEmpty &&
        selectedGender.isNotEmpty;
  }

  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  // GraphQL을 사용하여 서버에 요청 보내는 함수
  Future<void> sendProfileInfoToServer(BuildContext context) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    print(_uid.runtimeType);
    final MutationOptions options = MutationOptions(
      document: signUp,
      variables: <String, dynamic>{
        'userName': name,
        'age': int.parse(selectedAge),
        'sex': selectedGender,
        "fbId": _uid
      },
    );

    try {
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
      } else {
        final dynamic resultData = result.data;

        if (resultData != null) {
          final token = resultData['signUp']['token'];

          if (token != null) {
            // Store the token
            await Provider.of<UserInfoProvider>(context, listen: false)
                .setToken(token);
            await Provider.of<UserInfoProvider>(context, listen: false)
                .setNickName(name);
            setState(() {
              isTokenCome = true;
            });
            // Print the token to the console
            print("Successfully received token: $token");
            // After receiving the token, navigate to MyHomePage
          } else {
            // Handle the case where the token is null
            print("Token is null.");
            setState(() {
              errorText = resultData['signUp']['error'];
            });
            print(errorText);
          }
        } else {
          // Handle the case where data is null
          print("Data is null.");
        }
      }
    } catch (e) {
      // Handle exceptions
      print("Error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('프로필 설정'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 24),
              const Text(
                '이름',
                style: TextStyle(fontSize: 16),
              ),
              Gaps.v10,
              TextField(
                onChanged: (value) async {
                  setState(() {
                    name = value;

                    errorText = '';
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  errorText: errorText.isNotEmpty ? errorText : null,
                ),
                cursorColor: Theme.of(context).primaryColor,
              ),
              Gaps.v24,
              const Text(
                '나이',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: selectedAge,
                onChanged: (value) {
                  setState(() {
                    selectedAge = value!;
                  });
                },
                items: <String>[
                  '15',
                  '16',
                  '17',
                  '18',
                  '19',
                  '20',
                  '21',
                  '22',
                  '23',
                  '24',
                  '25',
                  '26',
                  '27',
                  '28',
                  '29',
                  '30',
                  '31',
                  '33',
                  '34'
                ] // 나이 옵션 목록
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                '성별',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMaleSelected = true;
                        selectedGender = "1";
                        isFemaleSelected = false;
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/images/User Male.png', // 남성 이미지 경로
                          width: 50,
                          height: 50,
                          color: isMaleSelected
                              ? const Color(0xFFAE9DD7)
                              : Colors.black,
                        ),
                        const Text('남성'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFemaleSelected = true;
                        selectedGender = "0";
                        isMaleSelected = false;
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/images/Vector.png', // 여성 이미지 경로
                          width: 50,
                          height: 50,
                          color: isFemaleSelected
                              ? const Color(0xFFAE9DD7)
                              : Colors.black,
                        ),
                        const Text('여성'),
                      ],
                    ),
                  ),
                ],
              ),
              Gaps.v32,
              FormButton(
                disabled: !isFormValid(),
                onTap: () async {
                  if (isFormValid()) {
                    await sendProfileInfoToServer(context);
                    if (isTokenCome) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNav(),
                        ),
                      );
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
