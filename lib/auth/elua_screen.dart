import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/constants/term_of_serviceprivacy_policy.dart';
import 'package:hanasaku/nav/main_nav.dart';
import 'package:hanasaku/query&mutation/mutatuin.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';

class UserInfoAcceptanceWidget extends StatefulWidget {
  final GraphQLClient client;
  final UserInfoProvider userInfoProvider;
  final String uid;
  final String deviceToken;

  const UserInfoAcceptanceWidget({
    super.key,
    required this.client,
    required this.userInfoProvider,
    required this.uid,
    required this.deviceToken,
  });

  @override
  _UserInfoAcceptanceWidgetState createState() =>
      _UserInfoAcceptanceWidgetState();
}

class _UserInfoAcceptanceWidgetState extends State<UserInfoAcceptanceWidget> {
  bool tosAccepted = false;
  bool privacyPolicyAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Center(
                child: Text(
                  'Welcome to HANASAKU!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Sizes.size20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Gaps.v10,
              const Center(
                child: Text('HANASAKUを利用する前に、まず個人情報処理方針と利用約款に同意してください。'),
              ),
              Gaps.v10,
              Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  leading: const Icon(Icons.assignment, color: Colors.blue),
                  title: const Text('利用規約',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: false,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        termOfService, // Insert your Terms of Service text here
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('サービス規約に同意します。'),
                      value: tosAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          tosAccepted = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.blue),
                  title: const Text('個人情報取扱方針',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: false,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        privacyPolicy, // Insert your Privacy Policy text here
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('プライバシーポリシーに同意します。'),
                      value: privacyPolicyAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          privacyPolicyAccepted = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size16, vertical: Sizes.size10),
        child: CupertinoButton(
          color: Theme.of(context).primaryColor,
          onPressed: tosAccepted && privacyPolicyAccepted
              ? () async {
                  final MutationOptions options = MutationOptions(
                    document: signUp,
                    variables: <String, dynamic>{
                      "fbId": widget.uid,
                      "deviceToken": widget.deviceToken,
                    },
                  );
                  final QueryResult signUpResult =
                      await widget.client.mutate(options);

                  final dynamic signUpData = signUpResult.data;

                  final token = signUpData['signUp']['token'];
                  final name = signUpData['signUp']['userName'];
                  await widget.userInfoProvider.setToken(token);
                  await widget.userInfoProvider.setNickName(name);

                  if (token != null && name != null) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainNav()),
                        (route) => false);
                  }
                }
              : null,
          child: const Text("HANASAKUに加入する"),
        ),
      ),
    );
  }
}
