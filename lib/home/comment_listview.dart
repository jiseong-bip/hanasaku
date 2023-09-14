// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/detail_bottom_textfield.dart';
import 'package:hanasaku/home/graphql/function_mutaion.dart';
import 'package:hanasaku/home/recomment_widget.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class CommentsQuery extends StatefulWidget {
  final int postId;
  final ScrollController scrollController;
  final Function(int commentCount) onCommentsCountChanged;
  const CommentsQuery({
    super.key,
    required this.postId,
    required this.scrollController,
    required this.onCommentsCountChanged,
  });

  @override
  State<CommentsQuery> createState() => _CommentsQueryState();
}

class _CommentsQueryState extends State<CommentsQuery> {
  String? nickName;
  final List _posts = [];
  final List _commentsLikesCount = [];
  final List<bool> _isRecommentShowed = [];

  String comment = '';
  int commentId = 0;
  bool recommentMode = false;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initName();
    Future.delayed(Duration.zero, () {
      _fetchMoreComments(FetchPolicy.noCache);
    });
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts.clear();
    });
    print(1);
    await _fetchMoreComments(FetchPolicy.noCache);
    print(2);
  }

  Future<void> _fetchMoreComments(FetchPolicy fetchPolicy) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: commentPostQuery,
      variables: {
        'viewPostPostId2': widget.postId,
      },
      fetchPolicy: fetchPolicy,
    );

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        final comments = result.data!['viewPost']['comments'];

        _posts.addAll(comments);
        widget.onCommentsCountChanged(_posts.length);
        for (var post in _posts) {
          _commentsLikesCount.add(post['likes'].length);
          if (post['recomments'].length > 3) {
            _isRecommentShowed.add(false);
          } else {
            _isRecommentShowed.add(true);
          }
        }
      });
    } else {
      print(result.exception);
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: GestureDetector(
        onTap: () {
          recommentMode = !recommentMode;
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => Gaps.v16,
                  controller: widget.scrollController,
                  itemCount: _posts.length,
                  itemBuilder: (context, index1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text(
                                  _posts[index1]['user']['userName'], //error
                                  style: TextStyle(
                                    fontSize: Sizes.size10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Gaps.v10,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Sizes.size10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _posts[index1]['user']['userName'],
                                            style: const TextStyle(
                                              fontSize: Sizes.size14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Gaps.h5,
                                          Text(
                                            getTime(
                                                _posts[index1]['createDate']),
                                            style: TextStyle(
                                              fontSize: Sizes.size10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          Gaps.h10,
                                          GestureDetector(
                                            onTap: () {
                                              dotMethod(context, _posts[index1],
                                                  nickName);
                                            },
                                            child: const FaIcon(
                                              FontAwesomeIcons.ellipsis,
                                              size: Sizes.size12,
                                            ),
                                          )
                                        ],
                                      ),
                                      Gaps.v3,
                                      Text(
                                        _posts[index1]['comment'],
                                        style: const TextStyle(
                                            fontSize: Sizes.size16),
                                      ),
                                      Gaps.v7,
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                recommentMode = !recommentMode;
                                                commentId =
                                                    _posts[index1]['id'];

                                                comment =
                                                    _posts[index1]['comment'];
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Transform.flip(
                                                  flipY: true,
                                                  child: Transform.rotate(
                                                    angle: 55,
                                                    child: FaIcon(
                                                      FontAwesomeIcons
                                                          .arrowTurnDown,
                                                      size: Sizes.size10,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ),
                                                Gaps.h5,
                                                Text(
                                                  'reply',
                                                  style: TextStyle(
                                                    fontSize: Sizes.size12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                Gaps.h5,
                                              ],
                                            ),
                                          ),
                                          Gaps.h10,
                                          GestureDetector(
                                            onTap: () {
                                              _isRecommentShowed[index1] =
                                                  !_isRecommentShowed[index1];
                                              setState(() {});
                                            },
                                            child: Row(
                                              children: [
                                                FaIcon(
                                                  _isRecommentShowed[index1]
                                                      ? FontAwesomeIcons.angleUp
                                                      : FontAwesomeIcons
                                                          .angleDown,
                                                  size: Sizes.size10,
                                                  color: Colors.grey.shade500,
                                                ),
                                                Gaps.h5,
                                                Text(
                                                  _isRecommentShowed[index1]
                                                      ? '대댓글 닫기'
                                                      : '대댓글 보기',
                                                  style: TextStyle(
                                                    fontSize: Sizes.size12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                Gaps.h5,
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      toggleLikeComment(
                                          context, _posts[index1]['id']);
                                      if (_posts[index1]['isLiked']) {
                                        // If previously liked (true), then decrement the count
                                        _commentsLikesCount[index1] -= 1;
                                      } else {
                                        // If previously not liked (false), then increment the count
                                        _commentsLikesCount[index1] += 1;
                                      }
                                      _posts[index1]['isLiked'] =
                                          !_posts[index1]['isLiked'];
                                      setState(() {});
                                    },
                                    child: Column(
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.heart,
                                          size: Sizes.size20,
                                          color: _posts[index1]['isLiked']
                                              ? Colors.red
                                              : Colors.grey.shade500,
                                        ),
                                        Gaps.v2,
                                        Text(
                                          '${_commentsLikesCount[index1]}', // 좋아요 수 표시
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          if (_isRecommentShowed[index1])
                            RecommentWidget(posts: _posts[index1]['recomments'])
                        ],
                      ),
                    );
                  }),
            ),
            BottomTextBar(
              commentId: commentId,
              recommentMode: recommentMode,
              commentController: _commentController,
              postId: widget.postId,
              onCommentChanged: (isSendPost) async {
                if (isSendPost) {
                  _posts.clear();
                  _fetchMoreComments(FetchPolicy.noCache);
                }
              },
              comment: comment,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> dotMethod(
      BuildContext context, Map<String, dynamic> post, String? userName) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {},
            child: SizedBox(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: Sizes.size32,
                    right: Sizes.size32,
                    bottom: Sizes.size72 + Sizes.size2,
                    top: Sizes.size16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.size24),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                  child: Stack(
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.size16,
                          ),
                          child: FaIcon(post['user']['userName'] == userName
                              ? FontAwesomeIcons.penToSquare
                              : FontAwesomeIcons.solidFlag)),
                      Center(
                        child: Text(
                            post['user']['userName'] == userName
                                ? '修正する'
                                : '届け出る',
                            style: const TextStyle(
                                fontSize: Sizes.size24,
                                fontWeight: FontWeight.bold)),
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
