import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/detail_screen.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/aws_s3.dart';
import 'package:hanasaku/setup/navigator.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  Future<File>? _cachedFile;
  Future<void> fetchAvatarImages(List contents) async {
    for (var content in contents) {
      if (content['user']['avatar'] != null) {
        avatarImagekey.add(
            {'__typename': 'userAvator', 'avatar': content['user']['avatar']});
        await getListImage(
            avatarImagekey); // Assuming this method fetches the image
        _cachedFile =
            DefaultCacheManager().getSingleFile(content['user']['avatar']);
      }
    } // Rebuild the widget after fetching all images
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Object?> avatarImagekey = [];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Shorts')),
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
          if (contents != null) {
            fetchAvatarImages(contents);
          }

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

                  return GestureDetector(
                    onTap: () {
                      navigatorKey.currentState!.push(MaterialPageRoute(
                          builder: (context) => DetailScreen(
                                postId: content['id'],
                                isContent: true,
                                videoKey: content['key'],
                                avatorKey: content['user']['avatar'],
                              )));
                    },
                    child: Padding(
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
                                  FutureBuilder(
                                      future: _cachedFile,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasError) {
                                            // 에러 처리
                                            return Container(
                                              height: screenWidth / 8,
                                              width: screenWidth / 8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border:
                                                      Border.all(width: 0.2),
                                                  color: Colors.grey),
                                            );
                                          }

                                          if (snapshot.hasData) {
                                            final file = snapshot.data as File;

                                            // 파일을 이미지로 변환하여 CircleAvatar의 backgroundImage로 설정
                                            return Container(
                                              height: screenWidth / 8,
                                              width: screenWidth / 8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border:
                                                      Border.all(width: 0.2),
                                                  color: Colors.grey,
                                                  image: DecorationImage(
                                                    image:
                                                        Image.file(file).image,
                                                  )),
                                            );
                                          } else {
                                            return Container(
                                              height: screenWidth / 8,
                                              width: screenWidth / 8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border:
                                                      Border.all(width: 0.2),
                                                  color: Colors.grey),
                                            ); // 데이터 없음 처리
                                          }
                                        } else {
                                          return Container(
                                            height: screenWidth / 8,
                                            width: screenWidth / 8,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(width: 0.2),
                                                color: Colors.grey),
                                          ); // 로딩 중 처리
                                        }
                                      }),
                                  Gaps.h10,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsetsDirectional
                                            .symmetric(horizontal: Sizes.size3),
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
                                            fontSize: Sizes.size14),
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
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Color(0xFFF4BECF),
                                    size: Sizes.size24,
                                  ),
                                ),
                              )
                            ]),
                      ),
                    ),
                  );
                }),
          );
        },
      ),
    );
  }
}
