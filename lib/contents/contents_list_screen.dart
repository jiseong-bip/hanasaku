import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/detail_screen.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/navigator.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shorts'),
      ),
      body: Query(
        options: QueryOptions(
          document:
              viewContansQuery, // this is the query string you just created
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Text('Loading');
          }

          List? contents = result.data?['viewContents'];

          if (contents == null) {
            return const Center(
              child: Text('다시 시도해주세요'),
            );
          }

          return SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final content = contents[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size14,
                      horizontal: Sizes.size16,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size10, vertical: Sizes.size10),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                              bottomLeft: Radius.circular(10)),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF5BFD0), Color(0xFFF6E7EC)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 0,
                              blurRadius: 3.0,
                              offset: const Offset(
                                  0, 5), // changes position of shadow
                            ),
                          ]),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: screenWidth / 8,
                                  width: screenWidth / 8,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(width: 0.2),
                                      color: Colors.grey),
                                ),
                                Gaps.h10,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsetsDirectional.symmetric(
                                              horizontal: Sizes.size3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(width: 2)),
                                      child: const Text(
                                        'FANDOM FM',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: Sizes.size10),
                                      ),
                                    ),
                                    Text(
                                      '${content['title']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: Sizes.size16),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 0,
                                      blurRadius: 3.0,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ]),
                              child: IconButton(
                                onPressed: () {
                                  navigatorKey.currentState!
                                      .push(MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                                postId: content['id'],
                                                isContent: true,
                                                videoKey: content['key'],
                                              )));
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Color(0xFFF4BECF),
                                ),
                              ),
                            )
                          ]),
                    ),
                  );
                }),
          );
        },
      ),
    );
  }
}
