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
              medals {
                level
                name
              }
              categories {
                name
              }
            }
          }
      """;

      return Query(
        options: QueryOptions(
            document: gql(readRepositories),
            variables: {"userId": userId},
            fetchPolicy: FetchPolicy.cacheAndNetwork),
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
          Map<String, dynamic> user = result.data?['viewUser'];
          Map<int, List<String>> groupedMedals = {};

          for (var medal in user['medals']) {
            if (groupedMedals[medal["level"]] == null) {
              groupedMedals[medal["level"]] = [];
            }
            groupedMedals[medal["level"]]!.add(medal["name"]);
          }

          double screenHeight = MediaQuery.of(context).size.height;
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
                            //ListView.builder(itemCount: user['categories'],itemBuilder: )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.size10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('View all medals'),
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Sizes.size5),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF946125)),
                                    ),
                                    Gaps.h5,
                                    Text(groupedMedals[1]![0]),
                                  ],
                                ),
                              ),
                              Gaps.v10,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Sizes.size5),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF946125)),
                                    ),
                                    Gaps.h5,
                                    Text(groupedMedals[1]![1]),
                                  ],
                                ),
                              ),
                              Gaps.v10,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Sizes.size5),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF946125)),
                                    ),
                                    Gaps.h5,
                                    Text(groupedMedals[1]![2]),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const Column(),
                          const Column()
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            bottomSheet: BottomAppBar(
                child: Padding(
              padding: const EdgeInsets.only(
                bottom: Sizes.size40,
                top: Sizes.size16,
                left: Sizes.size24,
                right: Sizes.size24,
              ),
              child: GestureDetector(
                onTap: () {
                  user['isChat'] == null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoom(
                              userName: user['userName'],
                              userId: user['id'],
                            ),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatRoom(
                                    userName: user['userName'],
                                    roomId: user['isChat'],
                                    userId: user['id'],
                                  )));
                },
                child: Expanded(
                  child: Container(
                    width: screenHeight,
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size16,
                    ),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: const Text(
                      'メッセージ送信',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Sizes.size16,
                      ),
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
