import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/graphql/function_mutaion.dart';
import 'package:hanasaku/home/widget/detail_dotMethod.dart';
import 'package:hanasaku/setup/aws_s3.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class RecommentWidget extends StatefulWidget {
  const RecommentWidget({
    super.key,
    required List<dynamic> posts,
  }) : _posts = posts;

  final List<dynamic> _posts;

  @override
  State<RecommentWidget> createState() => _RecommentWidgetState();
}

class _RecommentWidgetState extends State<RecommentWidget> {
  String? nickName;

  @override
  void initState() {
    initName();
    super.initState();
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
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
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget._posts.length,
        itemBuilder: (context, index) {
          print('${widget._posts[index]['user']}');
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size16),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size10, vertical: Sizes.size10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget._posts[index]['user']['avatar'] != null
                        ? FutureBuilder(
                            future: getImage(context,
                                widget._posts[index]['user']['avatar']),
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
                              width: 32,
                              height: 32,
                            ),
                          ),
                    Gaps.h10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget._posts[index]['user']['userName'],
                              style: const TextStyle(
                                fontSize: Sizes.size14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              getTime(widget._posts[index]['createDate']),
                              style: TextStyle(
                                fontSize: Sizes.size10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Gaps.h10,
                            GestureDetector(
                              onTap: () {
                                reCommenDotMethod(
                                    context, widget._posts[index], nickName);
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.ellipsis,
                                size: Sizes.size12,
                              ),
                            )
                          ],
                        ),
                        Text(
                          '${widget._posts[index]['comment']}',
                          style: const TextStyle(
                            fontSize: Sizes.size16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
          return SizedBox(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: Sizes.size32,
                  right: Sizes.size32,
                  bottom: Sizes.size72 + Sizes.size2,
                  top: Sizes.size16),
              child: GestureDetector(
                onTap: () {
                  post['user']['userName'] == userName
                      ? showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Column(
                                  children: <Widget>[
                                    Text(
                                      '本当に削除しますか', //삭제하시겠습니까
                                      style: TextStyle(),
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
                                        deleteReComment(context, post['id']);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color:
                                                Theme.of(context).primaryColor),
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
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                      : showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Column(
                                  children: <Widget>[
                                    Text(
                                      '通報しますか', //신고하시겠습니까
                                      style: TextStyle(),
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
                                        reportReComment(context, post['id']);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color:
                                                Theme.of(context).primaryColor),
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
                              ? FontAwesomeIcons.solidTrashCan
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
