import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/error_dialog.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

Future<void> getMyCategory(BuildContext context) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;
  final userInfoProvider =
      Provider.of<UserInfoProvider>(context, listen: false);
  final QueryOptions options = QueryOptions(
    document: getCategoryQuery,
    fetchPolicy: FetchPolicy.noCache,
  );

  try {
    final QueryResult result = await client.query(options);

    final idolData = (result.data!['viewCategories'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
    userInfoProvider.setCategory(idolData);
  } catch (e) {
    showErrorDialog("しばらくしてからもう一度お試しください。");
  }
}
