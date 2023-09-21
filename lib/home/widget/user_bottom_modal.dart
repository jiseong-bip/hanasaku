// ignore_for_file: avoid_print

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/chat/chat_room_screen.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/setup/cached_image.dart';

void showMyBottomSheet(BuildContext context, int userId, String? avatarKey) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: const BoxConstraints(maxHeight: 370, minHeight: 100),
    context: context,
    clipBehavior: Clip.hardEdge,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    builder: (context) {
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
            fetchPolicy: FetchPolicy.networkOnly),
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
          final List<Map<int, dynamic>> medal = [];
          int? lengthOfKey1;
          int? lengthOfKey2;
          int? lengthOfKey3;
          for (var medal in user['medals'] ?? []) {
            if (groupedMedals[medal["level"]] == null) {
              groupedMedals[medal["level"]] = [];
            }
            groupedMedals[medal["level"]]?.add(medal["name"]);
          }

          groupedMedals.forEach((key, value) {
            medal.add({key: value});
          });

          var itemsWithKey1 = medal.where((item) => item.containsKey(1));
          var itemsWithKey2 = medal.where((item) => item.containsKey(2));
          var itemsWithKey3 = medal.where((item) => item.containsKey(3));

          if (itemsWithKey1.isNotEmpty) {
            lengthOfKey1 = itemsWithKey1.first[1].length;
          }

          if (itemsWithKey2.isNotEmpty) {
            lengthOfKey2 = itemsWithKey2.first[2].length;
          }

          if (itemsWithKey3.isNotEmpty) {
            lengthOfKey3 = itemsWithKey3.first[3].length;
          }

          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = MediaQuery.of(context).size.width;
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 3, color: Color(0xFFF6F4F4)))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size16,
                          vertical: Sizes.size12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            avatarKey != null
                                ? CircleAvatar(
                                    radius: 40,
                                    child: CachedImage(url: avatarKey))
                                : CircleAvatar(
                                    radius: 40,
                                    child: SvgPicture.asset(
                                      'assets/user.svg',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                            Gaps.h14,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['userName'],
                                  style: const TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: MyFontFamily.lineSeedSans),
                                ),
                                Gaps.v12,
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFECC12A)),
                                    ),
                                    Gaps.h5,
                                    Text('${lengthOfKey3 ?? 0}'),
                                    Gaps.h5,
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFC8C8C8)),
                                    ),
                                    Gaps.h5,
                                    Text('${lengthOfKey2 ?? 0}'),
                                    Gaps.h5,
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF946125)),
                                    ),
                                    Gaps.h5,
                                    Text('${lengthOfKey1 ?? 0}'),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.x,
                            size: Sizes.size14,
                          )),
                    )
                  ],
                ),
                groupedMedals.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: Sizes.size52),
                        child: Center(child: Text('獲得した称号がありません')),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size10, vertical: Sizes.size5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+ View all',
                              style: TextStyle(
                                  fontSize: Sizes.size12,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w400),
                            ),
                            Gaps.v10,
                            SizedBox(
                              width: screenWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 150,
                                    width: 101,
                                    child: ListView.builder(
                                      primary: false,
                                      itemCount:
                                          math.min(groupedMedals[1]!.length, 3),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FittedBox(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: Sizes.size5,
                                                        vertical: Sizes.size3),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Color(0xFF946125),
                                                      ),
                                                    ),
                                                    Gaps.h5,
                                                    Text(
                                                      groupedMedals[1]![index],
                                                      style: const TextStyle(
                                                          fontSize:
                                                              Sizes.size12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (index !=
                                                math.min(
                                                        groupedMedals[1]!
                                                            .length,
                                                        3) -
                                                    1)
                                              Gaps.v14, // Add gap only if it's not the last item
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 150,
                                    width: 101,
                                    child: groupedMedals[2] != null
                                        ? ListView.builder(
                                            primary: false,
                                            itemCount: math.min(
                                                groupedMedals[2]!.length, 3),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  FittedBox(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                              Sizes.size5,
                                                          vertical:
                                                              Sizes.size3),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Color(
                                                                  0xFFC8C8C8),
                                                            ),
                                                          ),
                                                          Gaps.h5,
                                                          Text(
                                                            groupedMedals[2]![
                                                                index],
                                                            style: const TextStyle(
                                                                fontSize: Sizes
                                                                    .size12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (index !=
                                                      math.min(
                                                              groupedMedals[2]!
                                                                  .length,
                                                              3) -
                                                          1)
                                                    Gaps.v14, // Add gap only if it's not the last item
                                                ],
                                              );
                                            },
                                          )
                                        : Container(),
                                  ),
                                  SizedBox(
                                    height: 150,
                                    width: 101,
                                    child: groupedMedals[3] != null
                                        ? ListView.builder(
                                            primary: false,
                                            itemCount: math.min(
                                                groupedMedals[3]!.length, 3),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  FittedBox(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                              Sizes.size5,
                                                          vertical:
                                                              Sizes.size3),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Color(
                                                                  0xFFECC12A),
                                                            ),
                                                          ),
                                                          Gaps.h5,
                                                          Text(
                                                            groupedMedals[3]![
                                                                index],
                                                            style: const TextStyle(
                                                                fontSize: Sizes
                                                                    .size12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (index !=
                                                      math.min(
                                                              groupedMedals[3]!
                                                                  .length,
                                                              3) -
                                                          1)
                                                    Gaps.v14, // Add gap only if it's not the last item
                                                ],
                                              );
                                            },
                                          )
                                        : Container(),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
            )),
          );
        },
      );
    },
  );
}
