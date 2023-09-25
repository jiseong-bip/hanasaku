// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/provider/postinfo_provider.dart';
import 'package:hanasaku/home/graphql/function_mutaion.dart';
import 'package:hanasaku/home/recomment_widget.dart';
import 'package:hanasaku/home/widget/detail_dotMethod.dart';
import 'package:hanasaku/home/widget/user_bottom_modal.dart';
import 'package:hanasaku/setup/aws_s3.dart';
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
      return "${dayDifference}d ago";
    } else if (hoursDifference != 0) {
      return "${hoursDifference}h ago";
    } else {
      return "${minDifference}m ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final postInfo = Provider.of<PostInfo>(context, listen: false);

    isRecommentShowed = postInfo.getRecommentShoewd();
    isLikedList = postInfo.getIsLikedList();
    commentsLikesCount = postInfo.getCommentLikesCount();

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
                        GestureDetector(
                          onTap: () {
                            showMyBottomSheet(
                                context,
                                postInfo.getComments()![index1]['user']['id'],
                                postInfo.getComments()![index1]['user']
                                    ['userName'],
                                postInfo.getComments()![index1]['user']
                                    ['avatar']);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              postInfo.getComments()![index1]['user']
                                          ['avatar'] !=
                                      null
                                  ? FutureBuilder(
                                      future: getImage(
                                          context,
                                          postInfo.getComments()![index1]
                                              ['user']['avatar']),
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
                                              backgroundImage:
                                                  Image.file(file).image,
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
                                        width: 32,
                                        height: 32,
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
                                                  postInfo
                                                      .setRecommentMode(true);
                                                  commentId =
                                                      postInfo.getComments()![
                                                          index1]['id'];
                                                  postInfo
                                                      .setCommentid(commentId);
                                                  comment =
                                                      postInfo.getComments()![
                                                          index1]['comment'];
                                                  postInfo.setCurrentComment(
                                                      comment);
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
                                                        color: Colors
                                                            .grey.shade500,
                                                      ),
                                                    ),
                                                  ),
                                                  Gaps.h5,
                                                  Text(
                                                    'reply',
                                                    style: TextStyle(
                                                      fontSize: Sizes.size12,
                                                      color:
                                                          Colors.grey.shade500,
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
                                                        ? FontAwesomeIcons
                                                            .angleUp
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
                                                      color:
                                                          Colors.grey.shade500,
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
                                            isLikedList[index1]
                                                ? FontAwesomeIcons.solidHeart
                                                : FontAwesomeIcons.heart,
                                            size: Sizes.size16,
                                            color: isLikedList[index1]
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade500,
                                          ),
                                          Gaps.v2,
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
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
