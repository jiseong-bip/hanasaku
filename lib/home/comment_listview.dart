// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/provider/postinfo_provider.dart';

import 'package:hanasaku/home/graphql/function_mutaion.dart';
import 'package:hanasaku/home/recomment_widget.dart';
import 'package:hanasaku/home/widget/detail_dotMethod.dart';

import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class CommentsQuery extends StatefulWidget {
  final int postId;
  final bool isContents;

  final Function(int commentCount) onCommentsCountChanged;

  const CommentsQuery({
    super.key,
    required this.postId,
    required this.onCommentsCountChanged,
    required this.isContents,
  });

  @override
  State<CommentsQuery> createState() => _CommentsQueryState();
}

class _CommentsQueryState extends State<CommentsQuery> {
  String? nickName;
  bool? isContent;
  List<bool> isRecommentShowed = [];
  List commentsLikesCount = [];
  List isLikedList = [];

  String comment = '';
  int commentId = 0;
  bool recommentMode = false;

  @override
  void initState() {
    super.initState();

    print(isContent);
    initName();
    isContent = widget.isContents;
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
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
    final postInfo = Provider.of<PostInfo>(context, listen: false);

    isRecommentShowed = postInfo.getRecommentShoewd();
    isLikedList = postInfo.getIsLikedList();
    commentsLikesCount = postInfo.getCommentLikesCount();

    print("recommentshowed: $isRecommentShowed");
    print("isLiked: $isLikedList");
    return postInfo.getComments() != null
        ? GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              postInfo.setRecommentMode(false);
              setState(() {});
            },
            child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: postInfo.getComments()?.length ?? 0,
                itemBuilder: (context, index1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size10, vertical: Sizes.size10),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 16,
                            ),
                            Gaps.v10,
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Sizes.size10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          postInfo.getComments()![index1]
                                              ['user']['userName'],
                                          style: const TextStyle(
                                            fontSize: Sizes.size14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Gaps.h5,
                                        Text(
                                          getTime(
                                              postInfo.getComments()![index1]
                                                  ['createDate']),
                                          style: TextStyle(
                                            fontSize: Sizes.size10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        Gaps.h10,
                                        GestureDetector(
                                          onTap: () {
                                            commentDotMethod(
                                              context,
                                              postInfo.getComments()![index1],
                                              nickName,
                                            );
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
                                      postInfo.getComments()![index1]
                                          ['comment'],
                                      style: const TextStyle(
                                          fontSize: Sizes.size16),
                                    ),
                                    Gaps.v7,
                                    if (!isContent!)
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                postInfo.setRecommentMode(true);
                                                commentId = postInfo
                                                        .getComments()![index1]
                                                    ['id'];
                                                postInfo
                                                    .setCommentid(commentId);
                                                comment = postInfo
                                                        .getComments()![index1]
                                                    ['comment'];
                                                postInfo
                                                    .setCurrentComment(comment);
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
                                              isRecommentShowed[index1] =
                                                  !isRecommentShowed[index1];
                                              setState(() {});
                                            },
                                            child: Row(
                                              children: [
                                                FaIcon(
                                                  isRecommentShowed[index1]
                                                      ? FontAwesomeIcons.angleUp
                                                      : FontAwesomeIcons
                                                          .angleDown,
                                                  size: Sizes.size10,
                                                  color: Colors.grey.shade500,
                                                ),
                                                Gaps.h5,
                                                Text(
                                                  isRecommentShowed[index1]
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
                            if (!isContent!)
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      toggleLikeComment(
                                          context,
                                          postInfo.getComments()![index1]
                                              ['id']);
                                      if (isLikedList[index1]) {
                                        // If previously liked (true), then decrement the count
                                        commentsLikesCount[index1] -= 1;
                                      } else {
                                        // If previously not liked (false), then increment the count
                                        commentsLikesCount[index1] += 1;
                                      }
                                      isLikedList[index1] =
                                          !isLikedList[index1];
                                      setState(() {});
                                    },
                                    child: Column(
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.heart,
                                          size: Sizes.size20,
                                          color: isLikedList[index1]
                                              ? Colors.red
                                              : Colors.grey.shade500,
                                        ),
                                        Gaps.v2,
                                        Text(
                                          '${commentsLikesCount[index1]}', // 좋아요 수 표시
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
                        if (!isContent!)
                          if (isRecommentShowed[index1])
                            RecommentWidget(
                                posts: postInfo.getComments()?[index1]
                                    ['recomments'])
                      ],
                    ),
                  );
                }),
          )
        : Container();
  }
}
