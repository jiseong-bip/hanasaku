import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

Future<void> getMyCategory(BuildContext context) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;
  final userInfoProvider =
      Provider.of<UserInfoProvider>(context, listen: false);
  final QueryOptions options = QueryOptions(
    document: getCategoryQuery,
    fetchPolicy: FetchPolicy.networkOnly,
  );

  try {
    final QueryResult result = await client.query(options);

    final idolData = (result.data!['viewCategories'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
    userInfoProvider.setCategory(idolData);
    print(userInfoProvider.getCategoryName());
  } catch (e) {
    print('setCategory Error: $e');
  }
}
