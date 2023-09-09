import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/auth/sign_up_screen.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/firebase_options.dart';
import 'package:hanasaku/nav/main_nav.dart';
import 'package:hanasaku/setup/provider_model.dart';
import 'package:hanasaku/setup/set_profile.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

void main() async {
  final tokenManager = TokenManager();
  await initHiveForFlutter();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  LineSDK.instance.setup("2000690971").then((_) {
    print("LineSDK Prepared");
  });

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticationRepository>(
          create: (_) => AuthenticationRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => ListResultModel(),
        ),
        ChangeNotifierProvider<TokenManager>(
          create: (context) => TokenManager(),
        )
      ],
      child: MyApp(tokenManager: tokenManager),
    ),
  );
}

class MyApp extends StatelessWidget {
  final TokenManager tokenManager;

  const MyApp({Key? key, required this.tokenManager}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final tokenManager = Provider.of<TokenManager>(context, listen: false);
    final token = tokenManager.getToken();
    final HttpLink httpLink =
        HttpLink('http://localhost:4000/graphql', defaultHeaders: {
      'apollo-require-preflight': 'true',
    });

    final AuthLink authLink = AuthLink(
      getToken: () async {
        return await tokenManager.getToken();
      },
    );

    Link link = authLink.concat(httpLink);

    final WebSocketLink webSocketLink = WebSocketLink(
      'ws://localhost:4000/graphql',
      subProtocol: GraphQLProtocol.graphqlTransportWs,
      config: SocketClientConfig(
        autoReconnect: true,
        initialPayload: () {
          var headers = <String, String>{};
          headers.putIfAbsent(HttpHeaders.authorizationHeader, () => '$token');
          return headers;
        },
      ),
    );

    link = Link.split((request) => request.isSubscription, webSocketLink, link);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'social_community',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: const Color(0xFFF9C7C7),
          appBarTheme: const AppBarTheme(
            toolbarHeight: Sizes.size56,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            elevation: 1,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: Sizes.size16 + Sizes.size2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final user = snapshot.data;
              return FutureBuilder<String?>(
                future: Provider.of<TokenManager>(context, listen: false)
                    .getToken(),
                builder: (context, tokenSnapshot) {
                  if (tokenSnapshot.connectionState == ConnectionState.done) {
                    final token = tokenSnapshot.data;
                    if (user != null && (token != null && token.isNotEmpty)) {
                      return const MainNav();
                    } else if (user == null) {
                      return const SignUpScreen();
                    } else {
                      return const SetProfile();
                    }
                  }
                  return const CircularProgressIndicator();
                },
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
