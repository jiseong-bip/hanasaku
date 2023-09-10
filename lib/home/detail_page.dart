// ignore_for_file: avoid_print

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/comment_listview.dart';
import 'package:hanasaku/home/edit_post_screen.dart';
import 'package:hanasaku/nav/main_nav.dart';

import 'package:hanasaku/query&mutation/query.dart';
import 'package:hanasaku/setup/cached_image.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailPage extends StatefulWidget {
  final int postId;

  final Function(bool isLiked)? onLikeChanged;
  final Function(int liksCount)? onLikeCountChanged;
  final Function(int updateCountComment)? onCommentsCountChanged;

  const DetailPage({
    super.key,
    this.onLikeChanged,
    this.onLikeCountChanged,
    this.onCommentsCountChanged,
    required this.postId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isLiked = false;
  int postLikeCounts = 0;
  int commentsCount = 0;
  int currentPage = 0;
  String? nickName;

  Map<String, dynamic>? post;

  final PageController _pageController = PageController();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await _fetchPost(FetchPolicy.networkOnly);
    });

    initName();
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
  }

  Future<void> _fetchPost(FetchPolicy fetchPolicy) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: postQuery,
      variables: <String, dynamic>{
        'postId': widget.postId,
      },
      fetchPolicy: fetchPolicy,
    );

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        final resultPost = result.data!['viewPost'];

        post = resultPost;
        print(post);
        isLiked = post!['isLiked'];
        postLikeCounts = post!['likes'].length;
        commentsCount = post!['comments'].length;
      });
    } else {
      print(result.exception);
    }
  }

  Future<void> _toggleLikePost(BuildContext context, int postId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation LikePost(\$postId: Int!) {
          likePost(postId: \$postId) {
            ok
          }
        }
      '''),
      variables: <String, dynamic>{
        'postId': postId,
      },
    );

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
          if (isLikeSuccessful) {
            setState(() {
              isLiked = !isLiked;
              if (isLiked) {
                postLikeCounts += 1;
              } else {
                postLikeCounts -= 1;
              }
            });
            // Call the callback to notify PostWidget of the change in isLiked
            if (widget.onLikeChanged != null) {
              widget.onLikeChanged!(isLiked);
            }
            if (widget.onLikeCountChanged != null) {
              widget.onLikeCountChanged!(postLikeCounts);
            }
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
      return "$dayDifference d ago";
    } else if (hoursDifference != 0) {
      return "$hoursDifference h ago";
    } else {
      return "$minDifference m ago";
    }
  }

  Future<void> _deletePost(int postId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation DeletePost(\$postId: Int!) {
          deletePost(postId: \$postId) {
            ok
          }
        }
      '''),
      variables: <String, dynamic>{
        'postId': postId,
      },
      update: (cache, result) => result,
    );

    try {
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null && resultData['deletePost'] != null) {
          final bool isLikeSuccessful = resultData['deletePost']['ok'];
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

  Future<void> _reportPost(int postId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation ReportPost(\$postId: Int!) {
          reportPost(postId: \$postId) {
            ok
          }
        }
      '''),
      variables: <String, dynamic>{
        'postId': postId,
      },
      update: (cache, result) => result,
    );

    try {
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null && resultData['reportPost'] != null) {
          final bool isLikeSuccessful = resultData['reportPost']['ok'];
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

  void _showEditPostScreen(List<XFile> xImages) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) => EditPostScreen(
        postId: widget.postId,
        title: post?['title'],
        contents: post?['content'],
        xImages: xImages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagekey = post?['images'];
    final title = post?['title'];
    final content = post?['content'];
    final userName = post?['user']['userName'];
    final createDate = post?['createDate'];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                dotMethod(context, post, nickName);
              },
              icon: const FaIcon(FontAwesomeIcons.ellipsis))
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.size10,
                vertical: Sizes.size10,
              ),
              decoration: BoxDecoration(
                  border: Border(
                // 위쪽 border
                bottom: BorderSide(
                    width: 3.0, color: Colors.grey.shade400), // 아래쪽 border
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.size5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: Sizes.size20, // 아이콘 크기 + 여분의 여백
                          height: Sizes.size20, // 아이콘 크기 + 여분의 여백
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // 원 모양으로 만들기
                            color: Colors.blue, // 배경 색상 설정
                          ),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.user,
                              size: Sizes.size16,
                              color: Colors.white, // 아이콘 색상 설정
                            ),
                          ),
                        ),
                        Gaps.h10,
                        Text(
                          '$userName',
                          style: const TextStyle(
                            fontSize: Sizes.size14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gaps.h10,
                        Transform.translate(
                          offset: const Offset(0, 3),
                          child: Text(
                            createDate != null ? getTime(createDate) : '',
                            style: const TextStyle(
                              fontSize: Sizes.size10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gaps.v14,
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$title',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: MyFontFamily.lineSeedJP),
                          ),
                          Gaps.v10,
                          Text(
                            (content?.length ?? 0) > 50
                                ? content!.substring(0, 50) + '...'
                                : content ?? '',
                            style: const TextStyle(
                                fontSize: Sizes.size14,
                                fontFamily: MyFontFamily.lineSeedJP),
                          ),
                          Gaps.v10,
                          if (imagekey != null && imagekey.length > 0)
                            Column(
                              children: [
                                SizedBox(
                                  height: 150,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: imagekey.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Stack(
                                                  fit: StackFit
                                                      .expand, // 스택을 전체 화면으로 확장
                                                  children: [
                                                    CachedImage(
                                                        url: (imagekey[index]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            'url']),
                                                    Positioned(
                                                      right: 10,
                                                      bottom: 10,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.share),
                                                        onPressed: () async {
                                                          try {
                                                            var image = await DefaultCacheManager()
                                                                .getSingleFile((imagekey[
                                                                        index]
                                                                    as Map<
                                                                        String,
                                                                        dynamic>)['url']);
                                                            var xImage = XFile(
                                                                image.path);
                                                            await Share
                                                                .shareXFiles([
                                                              xImage
                                                            ], text: 'Great picture');
                                                          } catch (e) {
                                                            print(
                                                                "Error while sharing: $e");
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Center(
                                          child: CachedImage(
                                              url: (imagekey[index] as Map<
                                                  String, dynamic>)['url']),
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
                                    dotsCount: imagekey.length,
                                    position: currentPage,
                                    decorator: DotsDecorator(
                                      size: const Size(5, 5),
                                      activeSize: const Size(7, 7),
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    onTap: (page) {
                                      _pageController.animateToPage(
                                        page.toInt(),
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          Gaps.v10,
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _toggleLikePost(context, widget.postId);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up_alt,
                                    color: isLiked
                                        ? Theme.of(context).primaryColor
                                        : Colors.black,
                                    size: Sizes.size16,
                                  ),
                                  Gaps.h5,
                                  Text('$postLikeCounts'),
                                ],
                              ),
                            ),
                            Gaps.h16,
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.comment,
                                  size: Sizes.size16,
                                ),
                                Gaps.h5,
                                Text('$commentsCount'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gaps.v10,
                  ],
                ),
              ),
            ),
          ),
          Gaps.v10,
          Expanded(
            child: CommentsQuery(
              scrollController: scrollController,
              postId: widget.postId,
              onCommentsCountChanged: (commentCount) {
                setState(() {
                  commentsCount = commentCount;
                  if (widget.onCommentsCountChanged != null) {
                    widget.onCommentsCountChanged!(commentCount);
                  }
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Future<dynamic> dotMethod(
      BuildContext context, Map<String, dynamic>? post, String? userName) {
    final imagekey = post?['images'];
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: post?['user']['userName'] == userName ? 200 : 150,
            child: post?['user']['userName'] == userName
                ? Column(
                    children: [
                      GestureDetector(
                        //편집하기 editPost
                        onTap: () async {
                          List<XFile> xImages = [];
                          for (var key in imagekey) {
                            print(key);
                            var image = await DefaultCacheManager()
                                .getSingleFile((key['url']));
                            xImages.add(XFile(image.path));
                          }

                          _showEditPostScreen(xImages);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: Sizes.size32,
                              right: Sizes.size32,
                              bottom: Sizes.size16,
                              top: Sizes.size20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size24),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFB0B0),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Stack(
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: Sizes.size16,
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.penToSquare,
                                      color: Colors.white,
                                    )),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Sizes.size12),
                                  child: Center(
                                    child: Text('修正する',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Sizes.size24,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                MyFontFamily.lineSeedJP)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Column(
                                      children: <Widget>[
                                        Text(
                                          '本当に削除しますか',
                                          style: TextStyle(
                                              fontFamily:
                                                  MyFontFamily.lineSeedJP),
                                        ),
                                      ],
                                    ),
                                    // content: Text('Of course not!'),
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                          //deletPost
                                          onTap: () {
                                            _deletePost(widget.postId);
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MainNav()),
                                                (route) => false);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Theme.of(context)
                                                    .primaryColor),
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
                                                    fontFamily:
                                                        MyFontFamily.lineSeedJP,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey.shade300),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Sizes.size10,
                                                vertical: Sizes.size5,
                                              ),
                                              child: Text(
                                                'いいえ。',
                                                style: TextStyle(
                                                    fontSize: Sizes.size16,
                                                    fontFamily:
                                                        MyFontFamily.lineSeedJP,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: Sizes.size32,
                            right: Sizes.size32,
                            bottom: Sizes.size16,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size24),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFB0B0),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Stack(
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: Sizes.size16,
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.trash,
                                      color: Colors.white,
                                    )),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Sizes.size12),
                                  child: Center(
                                    child: Text('削除する',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Sizes.size24,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                MyFontFamily.lineSeedJP)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        left: Sizes.size32,
                        right: Sizes.size32,
                        bottom: Sizes.size72 + Sizes.size2,
                        top: Sizes.size16),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Column(
                                    children: <Widget>[
                                      Text(
                                        '本当に申告しますか',
                                        style: TextStyle(
                                            fontFamily:
                                                MyFontFamily.lineSeedJP),
                                      ),
                                    ],
                                  ),
                                  // content: Text('Of course not!'),
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        //reportPost
                                        onTap: () {
                                          _reportPost(widget.postId);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Theme.of(context)
                                                  .primaryColor),
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
                                                  fontFamily:
                                                      MyFontFamily.lineSeedJP,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.grey.shade300),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: Sizes.size10,
                                              vertical: Sizes.size5,
                                            ),
                                            child: Text(
                                              'いいえ。',
                                              style: TextStyle(
                                                  fontSize: Sizes.size16,
                                                  fontFamily:
                                                      MyFontFamily.lineSeedJP,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                      },
                      child: Container(
                        //신고하기 버튼
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size24),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Stack(
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Sizes.size16,
                                ),
                                child: FaIcon(FontAwesomeIcons.solidFlag)),
                            Center(
                              child: Text('届け出る',
                                  style: TextStyle(
                                      fontSize: Sizes.size24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: MyFontFamily.lineSeedJP)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        });
  }
}
