import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/edit_post_screen.dart';
import 'package:hanasaku/home/graphql/function_mutaion.dart';
import 'package:hanasaku/nav/main_nav.dart';
import 'package:image_picker/image_picker.dart';

void _showEditPostScreen(BuildContext context, List<XFile>? xImages, int postId,
    String title, String? content) {
  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) => EditPostScreen(
      postId: postId,
      title: title,
      contents: content,
      xImages: xImages,
    ),
  );
}

Future<dynamic> dotMethod(
    BuildContext context,
    Map<String, dynamic>? post,
    String? userName,
    List? imageKey,
    int postId,
    String title,
    String? content) {
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
                        if (imageKey != null) {
                          for (var key in imageKey) {
                            var image = await DefaultCacheManager()
                                .getSingleFile((key['url']));
                            xImages.add(XFile(image.path));
                          }
                        }

                        _showEditPostScreen(
                            context, xImages, postId, title, content);
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
                              // Padding(
                              //     padding: EdgeInsets.symmetric(
                              //       vertical: Sizes.size16,
                              //     ),
                              //     child: FaIcon(
                              //       FontAwesomeIcons.penToSquare,
                              //       color: Colors.white,
                              //     )),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Sizes.size12),
                                child: Center(
                                  child: Text('修正する',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Sizes.size24,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: MyFontFamily.lineSeedJP)),
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
                                          deletePost(context, postId);
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
                              // Padding(
                              //     padding: EdgeInsets.symmetric(
                              //       vertical: Sizes.size16,
                              //     ),
                              //     child: FaIcon(
                              //       FontAwesomeIcons.trash,
                              //       color: Colors.white,
                              //     )),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Sizes.size12),
                                child: Center(
                                  child: Text('削除する',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Sizes.size24,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: MyFontFamily.lineSeedJP)),
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
                                          fontFamily: MyFontFamily.lineSeedJP),
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
                                        reportPost(context, postId);
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: Sizes.size24),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Stack(
                        children: [
                          // Padding(
                          //     padding: EdgeInsets.symmetric(
                          //       vertical: Sizes.size16,
                          //     ),
                          //     child: FaIcon(FontAwesomeIcons.solidFlag)),
                          Center(
                            child: Text('届け出る',
                                style: TextStyle(
                                    fontSize: Sizes.size24,
                                    fontWeight: FontWeight.w400,
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

Future<dynamic> commentDotMethod(
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
                                    style: TextStyle(
                                        fontFamily: MyFontFamily.lineSeedJP),
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
                                      deleteComment(context, post['id']);
                                      Navigator.pop(context);
                                      //postInfo의 comments UPDATE해야함
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
                            ))
                    : showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Column(
                                children: <Widget>[
                                  Text(
                                    '通報しますか', //신고하시겠습니까
                                    style: TextStyle(
                                        fontFamily: MyFontFamily.lineSeedJP),
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
                                      reportComment(context, post['id']);
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
                padding: const EdgeInsets.symmetric(horizontal: Sizes.size24),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
                child: Stack(
                  children: [
                    // Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //       vertical: Sizes.size16,
                    //     ),
                    //     child: FaIcon(post['user']['userName'] == userName
                    //         ? FontAwesomeIcons.solidTrashCan
                    //         : FontAwesomeIcons.solidFlag)),
                    Center(
                      child: Text(
                          post['user']['userName'] == userName
                              ? '修正する'
                              : '届け出る',
                          style: const TextStyle(
                              fontSize: Sizes.size24,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      });
}
