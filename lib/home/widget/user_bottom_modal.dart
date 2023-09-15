import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/chat/chat_room_screen.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

void showMyBottomSheet(BuildContext context, int userId) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      // GraphQL 쿼리 정의
      String readRepositories = """
        query ViewUser(\$userId: Int!) {
            viewUser(userId: \$userId) {
              id
              userName
              isChat
            }
        }
      """;

      return Query(
        options: QueryOptions(
            document: gql(readRepositories),
            variables: {"userId": userId},
            fetchPolicy: FetchPolicy.noCache),
        builder: (
          QueryResult result, {
          Refetch? refetch,
          FetchMore? fetchMore,
        }) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const CircularProgressIndicator();
          }

          // 쿼리 응답으로부터 데이터 추출
          Map<String, dynamic> user = result.data?['viewUser'];

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 40,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.x,
                      size: Sizes.size14,
                    ))
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 3, color: Colors.grey.shade300))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.size16,
                      vertical: Sizes.size12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                        ),
                        Gaps.h14,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['userName'],
                              style: const TextStyle(
                                  fontSize: Sizes.size20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: MyFontFamily.lineSeedSans),
                            ),
                            Gaps.v10,
                            const Text(
                              '加入した部屋 :',
                              style: TextStyle(
                                  fontSize: Sizes.size10,
                                  fontFamily: MyFontFamily.lineSeedJP),
                            ),
                            Gaps.v5,
                            const Row(
                              children: [
                                Text('방탄소년단'),
                                Gaps.h5,
                                Text('nmix'),
                                Gaps.h5,
                                Text('twice'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const FittedBox(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.size16,
                      vertical: Sizes.size12,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '獲得した称号 : ',
                          style: TextStyle(
                              fontSize: Sizes.size12,
                              fontFamily: MyFontFamily.lineSeedJP),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
                child: Padding(
              padding: const EdgeInsets.only(
                bottom: Sizes.size40,
                top: Sizes.size16,
                left: Sizes.size24,
                right: Sizes.size24,
              ),
              child: GestureDetector(
                onTap: () {
                  print(user['isChat']);
                  user['isChat'] == null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoom(
                              userId: user['id'],
                            ),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatRoom(
                                    roomId: user['isChat'],
                                    userId: user['id'],
                                  )));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Sizes.size16 + Sizes.size2,
                  ),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Text(
                    'メッセージ送信',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Sizes.size20,
                    ),
                  ),
                ),
              ),
            )),
          );
        },
      );
    },
  );
}
