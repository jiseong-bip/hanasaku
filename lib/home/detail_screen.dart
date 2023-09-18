import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/contents_tab/video_widget/custom_video_player.dart';
import 'package:hanasaku/home/comment_listview.dart';

import 'package:hanasaku/home/provider/postinfo_provider.dart';
import 'package:hanasaku/home/widget/detail_bottom_textfield.dart';
import 'package:hanasaku/home/widget/detail_dotMethod.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/cached_image.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final int postId;
  final String? videoKey;
  final bool isContent;

  final Function(bool isLiked)? onLikeChanged;
  final Function(int liksCount)? onLikeCountChanged;
  final Function(int updateCountComment)? onCommentsCountChanged;
  const DetailScreen(
      {super.key,
      required this.postId,
      this.videoKey,
      required this.isContent,
      this.onLikeChanged,
      this.onLikeCountChanged,
      this.onCommentsCountChanged});

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

  Map<String, dynamic>? post;

  final PageController _pageController = PageController();

  final ScrollController scrollController = ScrollController();

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isContent = widget.isContent;

    Future.delayed(Duration.zero, () async {
      await _fetchPost(FetchPolicy.networkOnly);
    });

    initName();
  }

  @override
  void dispose() {
    _pageController.dispose();
    scrollController.dispose();
    _commentController.dispose();
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
    } else {
      print(result.exception);
    }
  }

  Future<void> _toggleLikePost(BuildContext context, int postId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: isContent! ? gql('''
        mutation LikeContent(\$likeContentContentId2: Int!) {
          likeContent(contentId: \$likeContentContentId2) {
            ok
          }
        }
      ''') : gql('''
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
      return "$dayDifference d ago";
    } else if (hoursDifference != 0) {
      return "$hoursDifference h ago";
    } else {
      return "$minDifference m ago";
    }
  }

  @override
  Widget build(BuildContext context) {
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
      },
      child: Scaffold(
        appBar: AppBar(actions: [
          IconButton(
              onPressed: () {
                dotMethod(
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
          commentController: _commentController,
          postId: widget.postId,
          onCommentChanged: (isSendPost) async {
            if (isSendPost) {
              _fetchPost(FetchPolicy.networkOnly);
            }
          },
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
                  width: 3.0, color: Colors.grey.shade400), // 아래쪽 border
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.size5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
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
                              fontFamily: MyFontFamily.lineSeedJP),
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
                                    fontFamily: MyFontFamily.lineSeedJP),
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
                                                              dynamic>)['url']),
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
                                                                          dynamic>)[
                                                                  'url']);
                                                          var xImage =
                                                              XFile(image.path);
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
                                            url: (imagekey[index] as Map<String,
                                                dynamic>)['url']),
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
