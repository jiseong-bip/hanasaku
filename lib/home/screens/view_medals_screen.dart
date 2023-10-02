import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

class ViewMedalsScreen extends StatefulWidget {
  final int userId;
  const ViewMedalsScreen({super.key, required this.userId});

  @override
  State<ViewMedalsScreen> createState() => _ViewMedalsScreenState();
}

class _ViewMedalsScreenState extends State<ViewMedalsScreen> {
  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: FittedBox(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message),
              Gaps.v10,
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          )),
        );
      },
    );
  }

  String viewUser = """
        query ViewUser(\$userId: Int!) {
            viewUser(userId: \$userId) {
              id
              isMe
              isBlocked
              avatar
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Medals'),
      ),
      body: Query(
          options: QueryOptions(
              document: gql(viewUser),
              variables: {"userId": widget.userId},
              fetchPolicy: FetchPolicy.cacheAndNetwork),
          builder: (
            QueryResult result, {
            Refetch? refetch,
            FetchMore? fetchMore,
          }) {
            if (result.hasException) {
              return const Text("NetWorkを確認してください");
            }

            if (result.isLoading) {
              return const Expanded(child: CircularProgressIndicator());
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

            return groupedMedals.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: Sizes.size52),
                    child: Center(child: Text('獲得した称号がありません')),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size10, vertical: Sizes.size10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 150,
                                width: 101,
                                child: groupedMedals[3] != null
                                    ? ListView.builder(
                                        primary: false,
                                        itemCount: groupedMedals[3]!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: Sizes.size5,
                                                      vertical: Sizes.size3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              Color(0xFFECC12A),
                                                        ),
                                                      ),
                                                      Gaps.h5,
                                                      Text(
                                                        groupedMedals[3]![
                                                            index],
                                                        style: const TextStyle(
                                                            fontSize:
                                                                Sizes.size12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (index !=
                                                  groupedMedals[3]!.length - 1)
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
                                child: groupedMedals[2] != null
                                    ? ListView.builder(
                                        primary: false,
                                        itemCount: groupedMedals[2]!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: Sizes.size5,
                                                      vertical: Sizes.size3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              Color(0xFFC8C8C8),
                                                        ),
                                                      ),
                                                      Gaps.h5,
                                                      Text(
                                                        groupedMedals[2]![
                                                            index],
                                                        style: const TextStyle(
                                                            fontSize:
                                                                Sizes.size12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (index !=
                                                  groupedMedals[2]!.length - 1)
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
                                child: ListView.builder(
                                  primary: false,
                                  itemCount: groupedMedals[1]!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
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
                                                    color: Color(0xFF946125),
                                                  ),
                                                ),
                                                Gaps.h5,
                                                Text(
                                                  groupedMedals[1]![index],
                                                  style: const TextStyle(
                                                      fontSize: Sizes.size12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (index !=
                                            groupedMedals[1]!.length - 1)
                                          Gaps.v14, // Add gap only if it's not the last item
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          }),
    );
  }
}
