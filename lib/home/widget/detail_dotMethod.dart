// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/screens/edit_post_screen.dart';
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

Future<dynamic> postDotMethod(
    BuildContext context,
    Map<String, dynamic>? post,
    String? userName,
    List? imageKey,
    int postId,
    String title,
    String? content) {
  return showModalBottomSheet(
      constraints:
          const BoxConstraints(minWidth: double.infinity, maxHeight: 121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return post?['user']['userName'] == userName
            ? Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: CupertinoButton(
                      child: const Text(
                        '修正する',
                        style: TextStyle(
                            fontSize: Sizes.size24,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        List<XFile> xImages = [];
                        if (imageKey != null) {
                          for (var key in imageKey) {
                            var image = await DefaultCacheManager()
                                .getSingleFile((key['url']));
                            xImages.add(XFile(image.path));
                          }
                        }
                        _showEditPostScreen(
                          context,
                          xImages,
                          postId,
                          title,
                          content,
                        );
                      },
                    ),
                  ),
                  Gaps.v1,
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: CupertinoButton(
                      child: const Text(
                        '削除する',
                        style: TextStyle(
                            fontSize: Sizes.size24,
                            fontWeight: FontWeight.bold),
                      ), //삭제하기
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Column(
                              children: <Widget>[
                                Text(
                                  '本当に削除しますか',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  //deletPost
                                  onTap: () async {
                                    await deletePost(context, postId);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MainNav()),
                                        (route) => false);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
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
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
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
                          ),
                        );
                      },
                    ),
                  )
                ],
              )
            : CupertinoButton(
                child: const Text(
                  '届け出る',
                  style: TextStyle(
                    fontSize: Sizes.size24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Column(
                              children: <Widget>[
                                Text(
                                  '本当に申告しますか',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                            // content: Text('Of course not!'),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  //reportPost
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MainNav()),
                                        (route) => false);
                                    reportPost(context, postId);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
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
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
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
                });
      });
}

Future<dynamic> commentDotMethod(
    BuildContext context, Map<String, dynamic> comment, String? userName) {
  return showModalBottomSheet(
    constraints:
        const BoxConstraints(minWidth: double.infinity, maxHeight: 121),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(10.0),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return CupertinoButton(
        child: Text(
          //삭제하기:신고하기
          comment['user']['userName'] == userName ? '削除する' : '届け出る',
          style: const TextStyle(
            fontSize: Sizes.size24,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          comment['user']['userName'] == userName
              ? showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Column(
                          children: <Widget>[
                            Text(
                              '本当に削除しますか', //삭제하시겠습니까
                            ),
                          ],
                        ),
                        // content: Text('Of course not!'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              //deletPost
                              onTap: () {
                                deleteComment(context, comment['id']);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                //postInfo의 comments UPDATE해야함
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context).primaryColor),
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
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          //deletPost
                          onTap: () {
                            reportComment(context, comment['id']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
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
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
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
                  ),
                );
        },
      );
    },
  );
}

Future<dynamic> reCommenDotMethod(
    BuildContext context, Map<String, dynamic> recomment, String? userName) {
  return showModalBottomSheet(
      constraints:
          const BoxConstraints(minWidth: double.infinity, maxHeight: 121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return CupertinoButton(
            child: Text(
              recomment['user']['userName'] == userName ? '削除する' : '届け出る',
              style: const TextStyle(
                fontSize: Sizes.size24,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              recomment['user']['userName'] == userName
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  //deletPost
                                  onTap: () {
                                    deleteComment(context, recomment['id']);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    //postInfo의 comments UPDATE해야함
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
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
                                        borderRadius: BorderRadius.circular(5),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  //deletPost
                                  onTap: () {
                                    reportComment(context, recomment['id']);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
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
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
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
            });
      });
}

Future<dynamic> contentDotMethod(
    BuildContext context, String? userName, int contentId) {
  return showModalBottomSheet(
    constraints:
        const BoxConstraints(minWidth: double.infinity, maxHeight: 121),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(10.0),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return CupertinoButton(
        child: const Text(
          '届け出る', //신고하다
          style: TextStyle(
            fontSize: Sizes.size24,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Column(
                children: <Widget>[
                  Text(
                    '本当に申告しますか',
                    style: TextStyle(),
                  ),
                ],
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    //reportPost
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      await reportContent(context, contentId);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).primaryColor),
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
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
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
            ),
          );
        },
      );
    },
  );
}

Future<dynamic> contentCommentDotMethod(
    BuildContext context, Map<String, dynamic> comment, String? userName) {
  return showModalBottomSheet(
    constraints:
        const BoxConstraints(minWidth: double.infinity, maxHeight: 121),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(10.0),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return CupertinoButton(
        child: Text(
          //삭제하기:신고하기
          comment['user']['userName'] == userName ? '削除する' : '届け出る',
          style: const TextStyle(
            fontSize: Sizes.size24,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          comment['user']['userName'] == userName
              ? showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Column(
                          children: <Widget>[
                            Text(
                              '本当に削除しますか', //삭제하시겠습니까
                            ),
                          ],
                        ),
                        // content: Text('Of course not!'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              //deletPost
                              onTap: () {
                                deleteContentComment(context, comment['id']);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                //postInfo의 comments UPDATE해야함
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context).primaryColor),
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
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          //deletPost
                          onTap: () {
                            reportContentComment(context, comment['id']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
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
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
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
                  ),
                );
        },
      );
    },
  );
}
