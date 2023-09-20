// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/auth/sign_up_screen.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/firebase_options.dart';
import 'package:hanasaku/home/provider/postinfo_provider.dart';

import 'package:hanasaku/nav/main_nav.dart';
import 'package:hanasaku/setup/navigator.dart';
import 'package:hanasaku/setup/provider_model.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

void main() async {
  final tokenManager = UserInfoProvider();

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
        ChangeNotifierProvider<UserInfoProvider>(
          create: (context) => UserInfoProvider(),
        ),
        ChangeNotifierProvider<PostInfo>(
          create: (context) => PostInfo(),
        )
      ],
      child: MyApp(
        tokenManager: tokenManager,
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserInfoProvider tokenManager;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    Key? key,
    required this.tokenManager,
    required this.navigatorKey,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final tokenManager = Provider.of<UserInfoProvider>(context, listen: false);

    final HttpLink httpLink =
        HttpLink('https://hanasaku.xyz/graphql', defaultHeaders: {
      'apollo-require-preflight': 'true',
    });

    final AuthLink authLink = AuthLink(
      getToken: () async {
        return await tokenManager.getToken();
      },
    );

    Link link = authLink.concat(httpLink);

    final WebSocketLink webSocketLink = WebSocketLink(
      'wss://hanasaku.xyz/graphql',
      subProtocol: GraphQLProtocol.graphqlTransportWs,
      config: SocketClientConfig(
        autoReconnect: true,
        initialPayload: () async {
          final token = await tokenManager.getToken();
          print(token);
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
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        navigatorKey: navigatorKey,
        title: 'social_community',
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xFFF4BECF),
            appBarTheme: const AppBarTheme(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              elevation: 1,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: Sizes.size20,
                fontWeight: FontWeight.w600,
              ),
            ),
            fontFamily: MyFontFamily.lineSeedJP),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final user = snapshot.data;
              return FutureBuilder<String?>(
                future: Provider.of<UserInfoProvider>(context, listen: false)
                    .getToken(),
                builder: (context, tokenSnapshot) {
                  if (tokenSnapshot.connectionState == ConnectionState.done) {
                    final token = tokenSnapshot.data;
                    if (user != null && (token != null && token.isNotEmpty)) {
                      return const MainNav();
                    } else {
                      return const SignUpScreen();
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
