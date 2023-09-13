import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/home/subscription.dart';
import 'package:hanasaku/setup/provider_model.dart';
import 'package:provider/provider.dart';

class TokenDisplayWidget extends StatefulWidget {
  const TokenDisplayWidget({super.key});

  @override
  State<TokenDisplayWidget> createState() => _TokenDisplayWidgetState();
}

class _TokenDisplayWidgetState extends State<TokenDisplayWidget> {
  String? _token;
  late Stream<dynamic> logLikeStream;
  late Stream<dynamic> logCommentStream;

  @override
  void initState() {
    super.initState();
    _fetchUid();
  }

  _fetchUid() async {
    final authRepo = AuthenticationRepository();
    final token = await authRepo.getUserUid();
    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Text('User Token: $_token'),
          Subscription(
              options: SubscriptionOptions(document: likeSubscription),
              builder: (result) {
                if (result.hasException) {
                  return Text(result.exception.toString());
                }

                if (result.isLoading) {
                  print(result);
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // ResultAccumulator is a provided helper widget for collating subscription results.
                // careful though! It is stateful and will discard your results if the state is disposed
                return ResultAccumulator.appendUniqueEntries(
                  latest: result.data,
                  builder: (context, {results}) => Text('$result'),
                );
              })
        ],
      ),
    );
  }
}
