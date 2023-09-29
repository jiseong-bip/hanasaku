// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/contents/video_widget/custom_video_player_1.dart';
import 'package:hanasaku/home/comment_listview.dart';

import 'package:hanasaku/home/provider/postinfo_provider.dart';
import 'package:hanasaku/home/widget/detail_bottom_textfield.dart';
import 'package:hanasaku/home/widget/detail_dotMethod.dart';
import 'package:hanasaku/home/widget/user_bottom_modal.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/aws_s3.dart';
import 'package:hanasaku/setup/cached_image.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final int postId;
  final String? videoKey;
  final bool isContent;
  final Function(bool isLiked)? onLikeChanged;
  final Function(int liksCount)? onLikeCountChanged;
  final Function(int updateCountComment)? onCommentsCountChanged;
  const DetailScreen({
    super.key,
    required this.postId,
    this.videoKey,
    required this.isContent,
    this.onLikeChanged,
    this.onLikeCountChanged,
    this.onCommentsCountChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isLiked = false;
  int postLikeCounts = 0;
  int commentsCount = 0;
  int currentPage = 0;
  String? nickName;
  bool? isContent;
  List<Object?> avatarImagekey = [];
  SignedRequestParams? signedParams;

  Map<String, dynamic>? post;

  final PageController _pageController = PageController();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    isContent = widget.isContent;
    Future.delayed(Duration.zero, () async {
      await _fetchPost(FetchPolicy.networkOnly);
    });
    initName();
    if (widget.videoKey != null) {
      signedParams = awsS3Client.buildSignedGetParams(key: widget.videoKey!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
  }

  Future<void> _fetchPost(FetchPolicy fetchPolicy) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final postInfo = Provider.of<PostInfo>(context, listen: false);
    final QueryOptions postOptions = QueryOptions(
      document: postQuery,
      variables: <String, dynamic>{
        'postId': widget.postId,
      },
      fetchPolicy: fetchPolicy,
    );

    final QueryOptions contentOptions = QueryOptions(
      document: contentQuery,
      variables: <String, dynamic>{
        'contentId': widget.postId,
      },
      fetchPolicy: fetchPolicy,
    );

    final QueryResult result =
        await client.query(isContent! ? contentOptions : postOptions);

    if (!result.hasException) {
      setState(() {
        final resultPost =
            isContent! ? result.data!['viewContent'] : result.data!['viewPost'];
        final comments = isContent!
            ? result.data!['viewContent']['comments']
            : result.data!['viewPost']['comments'];
        post = resultPost;
        postInfo.setComments(comments);
        isLiked = post!['isLiked'];
        postLikeCounts = post!['likeCount'];
        commentsCount = post!['comments'].length;
      });
      print(post?['user']['id']);
      postInfo.setCommentUserAvatar();
    } else {
      print(result.exception);
    }
  }

  Future<void> _toggleLikePost(BuildContext context, int postId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions postOptions = MutationOptions(
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
      update: (cache, result) => result,
    );

    final MutationOptions commentOptions = MutationOptions(
      document: gql('''
        mutation LikeContent(\$likeContentContentId2: Int!) {
          likeContent(contentId: \$likeContentContentId2) {
            ok
          }
        }
      '''),
      variables: <String, dynamic>{
        'likeContentContentId2': postId,
      },
      update: (cache, result) => result,
    );

    try {
      final QueryResult result =
          await client.mutate(isContent! ? commentOptions : postOptions);

      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null) {
          final bool isLikeSuccessful = isContent!
              ? resultData['likeContent']['ok']
              : resultData['likePost']['ok'];

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

  //다른 파일로 옮기기
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

  @override
  Widget build(BuildContext context) {
    final postInfo = Provider.of<PostInfo>(context, listen: true);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double videoHeight = screenHeight / 4;
    final imagekey = post?['images'];
    final title = post?['title'];
    final content = post?['content'];
    final userName = post?['user']['userName'];
    final createDate = post?['createDate'];
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        postInfo.setRecommentMode(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(actions: [
          IconButton(
              onPressed: () {
                print(widget.postId);
                isContent ?? false
                    ? contentDotMethod(context, nickName, widget.postId)
                    : postDotMethod(
                        context,
                        post,
                        nickName,
                        imagekey,
                        widget.postId,
                        title,
                        content,
                      );
              },
              icon: const FaIcon(FontAwesomeIcons.ellipsis))
        ]),
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchPost(FetchPolicy.networkOnly);
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                detailPost(screenWidth, videoHeight, userName, createDate,
                    title, content, imagekey, context),
                CommentsQuery(
                  postId: widget.postId,
                  onCommentsCountChanged: (commentCount) {
                    setState(() {
                      commentsCount = commentCount;
                      if (widget.onCommentsCountChanged != null) {
                        widget.onCommentsCountChanged!(commentCount);
                      }
                    });
                  },
                  isContents: widget.isContent,
                ),
              ],
            ),
          ),
        ),
        bottomSheet: BottomTextBar(
          isContent: widget.isContent,
          postId: widget.postId,
          onCommentChanged: (isSendPost) async {
            if (isSendPost) {
              _fetchPost(FetchPolicy.networkOnly);
            }
          },
          recommentMode: postInfo.getRecommentMode(),
          comment: postInfo.getComment(),
        ),
      ),
    );
  }

  Column detailPost(double screenWidth, double videoHeight, userName,
      createDate, title, content, imagekey, BuildContext context) {
    return Column(
      children: [
        if (isContent!)
          SizedBox(
            width: screenWidth,
            height: videoHeight,
            child: CustomVideoPlayer(
              videoKey: widget.videoKey!,
            ),
          ),
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
                  width: 1.5, color: Colors.grey.shade400), // 아래쪽 border
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.size5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showMyBottomSheet(
                        context,
                        post?['user']['id'],
                        nickName!,
                      );
                    },
                    child: Row(
                      children: [
                        post?['user']['avatar'] != null
                            ? FutureBuilder(
                                future:
                                    getImage(context, post?['user']['avatar']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasError) {
                                      // 에러 처리
                                      return CircleAvatar(
                                        radius: 12,
                                        child: SvgPicture.asset(
                                          'assets/user.svg',
                                          width: 80,
                                          height: 80,
                                        ),
                                      );
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
                                          width: 80,
                                          height: 80,
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
                            fontSize: Sizes.size14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gaps.h10,
                        Text(
                          createDate != null ? getTime(createDate) : '',
                          style: const TextStyle(
                            fontSize: Sizes.size10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gaps.v10,
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
                          ),
                        ),
                        Gaps.v10,
                        if (content != null)
                          Column(
                            children: [
                              Text(
                                (content?.length ?? 0) > 50
                                    ? content!
                                    : content ?? '',
                                style: const TextStyle(
                                  fontSize: Sizes.size14,
                                ),
                              ),
                              Gaps.v10,
                            ],
                          ),
                        if (imagekey != null &&
                            imagekey.length > 0 &&
                            !isContent!)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 150,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: imagekey.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return Scaffold(
                                                backgroundColor: Colors.black,
                                                appBar: AppBar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0.0,
                                                  leading: IconButton(
                                                    icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  actions: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.share,
                                                          color: Colors.white),
                                                      onPressed: () async {
                                                        try {
                                                          var image = await DefaultCacheManager()
                                                              .getSingleFile((imagekey[
                                                                          index]
                                                                      as Map<
                                                                          String,
                                                                          dynamic>)[
                                                                  'url']);
                                                          var xImage =
                                                              XFile(image.path);
                                                          await Share
                                                              .shareXFiles(
                                                                  [xImage],
                                                                  text: '');
                                                        } catch (e) {
                                                          print(
                                                              "공유 중 오류 발생: $e");
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                body: SafeArea(
                                                  child: Center(
                                                    child: InteractiveViewer(
                                                      boundaryMargin:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      minScale: 0.1,
                                                      maxScale: 2.0,
                                                      child: CachedImage(
                                                          url: (imagekey[index]
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'url']),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Center(
                                        child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: CachedImage(
                                              url: (imagekey[index] as Map<
                                                  String, dynamic>)['url']),
                                        ),
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
                                padding:
                                    const EdgeInsets.only(top: Sizes.size5),
                                child: DotsIndicator(
                                  dotsCount: imagekey.length,
                                  position: currentPage,
                                  decorator: DotsDecorator(
                                    size: const Size(5, 5),
                                    activeSize: const Size(7, 7),
                                    activeColor: Theme.of(context).primaryColor,
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
                                FaIcon(
                                  isLiked
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  color: Theme.of(context).primaryColor,
                                  size: Sizes.size16,
                                ),
                                Gaps.h5,
                                Text(
                                  '$postLikeCounts',
                                  style: const TextStyle(
                                    fontSize: Sizes.size12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gaps.h16,
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.comment,
                                size: Sizes.size16,
                                color: Colors.grey.shade600,
                              ),
                              Gaps.h5,
                              Text(
                                '$commentsCount',
                                style: const TextStyle(
                                  fontSize: Sizes.size12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
