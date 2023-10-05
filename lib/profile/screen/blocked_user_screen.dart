import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/aws_s3.dart';
import 'package:hanasaku/setup/error_dialog.dart';

class BlockUserScreen extends StatefulWidget {
  const BlockUserScreen({super.key});

  @override
  State<BlockUserScreen> createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends State<BlockUserScreen> {
  final List _blockedUserList = [];

  Future<void> _fetchMyPosts() async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
        document: viewBlockedUserQuery,
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll);

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        if (result.data!['viewBlockUsers'] != null) {
          _blockedUserList.clear();
          _blockedUserList.addAll(result.data!['viewBlockUsers']);
        }
      });
    } else {
      showErrorDialog("しばらくしてからもう一度お試しください。");
    }
  }

  Future<void> unBlockUser(
      BuildContext context, int userId, String userName) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
      mutation UnblockUser(\$unblockUserUserId2: Int!) {
        unblockUser(userId: \$unblockUserUserId2) {
          ok
        }
      }
      '''),
      variables: <String, dynamic>{
        'unblockUserUserId2': userId,
      },
      update: (cache, result) => result,
    );

    try {
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        // Handle errors
        showErrorDialog("しばらくしてからもう一度お試しください。");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null && resultData['unblockUser'] != null) {
          final bool isLikeSuccessful = resultData['unblockUser']['ok'];
          if (isLikeSuccessful) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Column(
                        children: <Widget>[
                          Text(
                            userName,
                            style: const TextStyle(),
                          ),
                          const Text(
                            'ブロックが解除されました',
                            style: TextStyle(),
                          ),
                        ],
                      ),
                      // content: Text('Of course not!'),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            //reportPost
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Sizes.size10,
                                  vertical: Sizes.size5,
                                ),
                                child: Text(
                                  'はい。',
                                  style: TextStyle(
                                      fontSize: Sizes.size16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
          } else {
            // Handle the case where the like operation was not successful
            print("Like operation was not successful.");
            // You can also display a message to the user if needed
          }
        } else {
          // Handle the case where data is null
          print("Data is null.");
          // You can also display a message to the user if needed
        }
      }
    } catch (e) {
      // Handle exceptions
      showErrorDialog("予期せぬエラーが発生しました。");
      // You can also display an error message to the user if needed
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _fetchMyPosts();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: ListView.builder(
            itemCount: _blockedUserList.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 60,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            _blockedUserList[index]['avatar'] != null
                                ? FutureBuilder(
                                    future: getImage(context,
                                        _blockedUserList[index]['avatar']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          // 에러 처리
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }

                                        if (snapshot.hasData) {
                                          final file = snapshot.data as File;

                                          // 파일을 이미지로 변환하여 CircleAvatar의 backgroundImage로 설정
                                          return CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                Image.file(file).image,
                                          );
                                        } else {
                                          return CircleAvatar(
                                            radius: 20,
                                            child: SvgPicture.asset(
                                              'assets/user.svg',
                                              width: 40,
                                              height: 40,
                                            ),
                                          ); // 데이터 없음 처리
                                        }
                                      } else {
                                        return const CircularProgressIndicator(); // 로딩 중 처리
                                      }
                                    })
                                : CircleAvatar(
                                    radius: 20,
                                    child: SvgPicture.asset(
                                      'assets/user.svg',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                            Gaps.h10,
                            Text(
                              '${_blockedUserList[index]['userName']}',
                              style: const TextStyle(
                                fontSize: Sizes.size20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                vertical: Sizes.size5,
                                horizontal: Sizes.size16),
                            color: Theme.of(context).primaryColor,
                            child: const Text('解除'),
                            onPressed: () async {
                              await unBlockUser(
                                  context,
                                  _blockedUserList[index]['id'],
                                  _blockedUserList[index]['userName']);
                              await _fetchMyPosts();
                            }),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
