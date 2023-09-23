// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/detail_screen.dart';
import 'package:hanasaku/home/widget/user_bottom_modal.dart';
import 'package:hanasaku/setup/aws_s3.dart';
import 'package:hanasaku/setup/cached_image.dart';

class Post extends StatefulWidget {
  final Map<String, dynamic> post;
  const Post({super.key, required this.post});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  bool isLiked = false;
  int counts = 0;
  int commentCount = 0;
  int currentPage = 0;
  bool imagesLoaded = false;
  List<Object?> postImagekey = [];
  List<Object?> avatarImagekey = [];
  List<Object?> imagekey = [];
  late Future<File> _cachedFile;

  final PageController _pageController = PageController();

  Future<void> _toggleLikePost(BuildContext context, int postId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(document: gql('''
        mutation LikePost(\$postId: Int!) {
          likePost(postId: \$postId) {
            ok
          }
        }
      '''), variables: <String, dynamic>{
      'postId': postId,
    });

    try {
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null && resultData['likePost'] != null) {
          final bool isLikeSuccessful = resultData['likePost']['ok'];
          setState(() {
            isLiked = !isLiked;
            if (isLiked) {
              counts += 1;
            } else {
              counts -= 1;
            }
          });
          if (isLikeSuccessful) {
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
      print("Error occurred: $e");
      // You can also display an error message to the user if needed
    }
  }

  void onTapPost() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DetailScreen(
        postId: widget.post['id'],
        onLikeChanged: (bool updatedIsLiked) {
          setState(() {
            isLiked = updatedIsLiked;
          });
        },
        onLikeCountChanged: (int updatedCountLiked) {
          setState(() {
            counts = updatedCountLiked;
          });
        },
        //comments: commentList,
        onCommentsCountChanged: (int updateCountComment) {
          setState(() {
            commentCount = updateCountComment;
          });
        },
        isContent: false, avatorKey: widget.post['user']['avatar'],
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    counts = widget.post['likeCount'];
    Future.delayed(Duration.zero, () async {
      postImagekey = widget.post['images'];

      imagekey.addAll(postImagekey);

      if (widget.post['user']['avatar'] != null) {
        avatarImagekey.add({
          '__typename': 'userAvator',
          'avatar': widget.post['user']['avatar']
        });
        imagekey.addAll(avatarImagekey);
      }

      isLiked = widget.post['isLiked'];
      await getImage(imagekey);
      _cachedFile =
          DefaultCacheManager().getSingleFile(widget.post['user']['avatar']);
      setState(() {
        imagesLoaded = true;
      });
    });

    commentCount = widget.post['comments'].length;
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(() {});
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.post['title'];
    final content = widget.post['content'];
    final userName = widget.post['user']['userName'];
    final createDate = widget.post['createDate'];

    String getTime(String createDate) {
      final now = DateTime.now();
      final int millisecondsSinceEpoch = int.parse(createDate);
      final DateTime commentDateTime =
          DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
      final difference = now.difference(commentDateTime);
      final hoursDifference = difference.inHours;
      final dayDifference = difference.inDays;
      final minDifference = difference.inMinutes;

      if (dayDifference != 0) {
        return "${dayDifference}d ago";
      } else if (hoursDifference != 0) {
        return "${hoursDifference}h ago";
      } else {
        return "${minDifference}m ago";
      }
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.size10,
          vertical: Sizes.size10,
        ),
        decoration: BoxDecoration(
            border: Border(
          // 위쪽 border
          bottom:
              BorderSide(width: 1.5, color: Colors.grey.shade400), // 아래쪽 border
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.size5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showMyBottomSheet(context, widget.post['user']['id'],
                      widget.post['user']['avatar']);
                },
                child: Row(
                  children: [
                    widget.post['user']['avatar'] != null
                        ? FutureBuilder(
                            future: _cachedFile,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  // 에러 처리
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.hasData) {
                                  final file = snapshot.data as File;

                                  // 파일을 이미지로 변환하여 CircleAvatar의 backgroundImage로 설정
                                  return CircleAvatar(
                                    radius: 12,
                                    backgroundImage: Image.file(file).image,
                                  );
                                } else {
                                  return CircleAvatar(
                                    radius: 12,
                                    child: SvgPicture.asset(
                                      'assets/user.svg',
                                    ),
                                  ); // 데이터 없음 처리
                                }
                              } else {
                                return const CircularProgressIndicator(); // 로딩 중 처리
                              }
                            })
                        : CircleAvatar(
                            radius: 12,
                            child: SvgPicture.asset(
                              'assets/user.svg',
                            ),
                          ),
                    Gaps.h10,
                    Text(
                      '$userName',
                      style: const TextStyle(
                        fontFamily: MyFontFamily.lineSeedJP,
                        fontSize: Sizes.size14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gaps.h10,
                    Text(
                      getTime(createDate),
                      style: const TextStyle(
                        fontFamily: MyFontFamily.lineSeedJP,
                        fontSize: Sizes.size10,
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.v5,
              InkWell(
                onTap: () {
                  onTapPost();
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$title',
                        style: const TextStyle(
                          fontSize: Sizes.size20,
                          fontFamily: MyFontFamily.lineSeedJP,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gaps.v8,
                      Text(
                        (content?.length ?? 0) > 50
                            ? content!.substring(0, 50) + '...'
                            : content ?? '',
                        style: const TextStyle(
                          fontFamily: MyFontFamily.lineSeedJP,
                          fontSize: Sizes.size14,
                        ),
                      ),
                      Gaps.v10,
                      if (postImagekey.isNotEmpty && imagesLoaded)
                        Column(
                          children: [
                            SizedBox(
                              height: 150,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: postImagekey.length,
                                itemBuilder: (context, index) {
                                  return Center(
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: CachedImage(
                                          url: (postImagekey[index]
                                              as Map<String, dynamic>)['url']),
                                    ),
                                  );
                                },
                                onPageChanged: (int page) {
                                  setState(() {
                                    currentPage = page;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DotsIndicator(
                                dotsCount: postImagekey.length,
                                position: currentPage,
                                decorator: DotsDecorator(
                                  size: const Size(5, 5),
                                  activeSize: const Size(7, 7),
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                                onTap: (page) {
                                  _pageController.animateToPage(
                                    page.toInt(),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _toggleLikePost(context, widget.post['id']);
                        },
                        child: Row(
                          children: [
                            FaIcon(
                              isLiked
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              color: Theme.of(context).primaryColor,
                              size: Sizes.size16,
                            ),
                            Gaps.h5,
                            Text(
                              '$counts',
                              style: const TextStyle(
                                fontSize: Sizes.size12,
                                fontFamily: MyFontFamily.lineSeedJP,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gaps.h16,
                      GestureDetector(
                        onTap: () {
                          onTapPost();
                        },
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.comment,
                              color: Colors.grey.shade600,
                              size: Sizes.size16,
                            ),
                            Gaps.h5,
                            Text(
                              '$commentCount',
                              style: const TextStyle(
                                fontSize: Sizes.size12,
                                fontFamily: MyFontFamily.lineSeedJP,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
