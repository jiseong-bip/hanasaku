// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/provider/postinfo_provider.dart';

import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class BottomTextBar extends StatefulWidget {
  final String comment;
  final bool recommentMode;
  final bool isContent;
  final Function(bool isSendPost) onCommentChanged;

  final int postId;
  const BottomTextBar({
    super.key,
    required this.postId,
    required this.onCommentChanged,
    required this.recommentMode,
    required this.comment,
    required this.isContent,
  });

  @override
  State<BottomTextBar> createState() => _BottomTextBarState();
}

class _BottomTextBarState extends State<BottomTextBar> {
  String? nickName;
  bool _isWriting = false;
  bool _isSend = false;
  bool? _isContent;
  File? _profileImage;

  TextEditingController commentController = TextEditingController();

  Future<void> _loadSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.jpg';
    final savedImage = File(imagePath);

    if (savedImage.existsSync()) {
      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  Future<void> toggleCommentSend(
      BuildContext context, int postId, String comment) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions postOptions = MutationOptions(
      document: gql('''
        mutation Mutation(\$comment: String!, \$postId: Int!) {
          createComment(comment: \$comment, postId: \$postId) {
            ok
          }
        }
      '''),
      variables: <String, dynamic>{
        'postId': postId,
        'comment': comment,
      },
      update: (cache, result) => result,
    );

    final MutationOptions contentOptions = MutationOptions(
      document: gql('''
        mutation CreateContentComment(\$comment: String!, \$createContentCommentContentId2: Int!) {
  createContentComment(comment: \$comment, contentId: \$createContentCommentContentId2) {
    ok
  }
}
      '''),
      variables: <String, dynamic>{
        'createContentCommentContentId2': postId,
        'comment': comment,
      },
      update: (cache, result) => result,
    );
    try {
      final QueryResult result =
          await client.mutate(_isContent! ? contentOptions : postOptions);

      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;
        print(resultData);
        if (resultData['createComment'] != null ||
            resultData['createContentComment'] != null) {
          final bool isLikeSuccessful = _isContent!
              ? resultData['createContentComment']['ok']
              : resultData['createComment']['ok'];
          if (isLikeSuccessful) {
            commentController.clear();
            setState(() {
              _isSend = !_isSend;
            });
            widget.onCommentChanged(_isSend);
            _isSend = !_isSend;
            // Call the callback to notify PostWidget of the change in isLiked
            print('succes to send comment');
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

  Future<void> toggleRecommentSend(
      BuildContext context, int commentId, String comment) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation Mutation(\$originCommentId: Int!, \$postId: Int!, \$comment: String!) {
  createRecomment(originCommentId: \$originCommentId, postId:      \$postId, comment: \$comment) {
    ok
  }
}

      '''),
      variables: <String, dynamic>{
        "originCommentId": commentId,
        'comment': comment,
        "postId": widget.postId,
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

        if (resultData != null && resultData['createRecomment'] != null) {
          final bool isLikeSuccessful = resultData['createRecomment']['ok'];
          if (isLikeSuccessful) {
            commentController.clear();
            setState(() {
              _isSend = !_isSend;
            });
            widget.onCommentChanged(_isSend);
            _isSend = !_isSend;
            // Call the callback to notify PostWidget of the change in isLiked
            print('succes to send comment');
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

  void _stopWriting() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isWriting = false;
    });
  }

  void _onStartWriting() {
    setState(() {
      _isWriting = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _isContent = widget.isContent;
    initName();
    _loadSavedImage();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final postInfo = Provider.of<PostInfo>(context, listen: false);
    return BottomAppBar(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.size16,
          vertical: Sizes.size12,
        ),
        child: Row(
          children: [
            _profileImage != null
                ? CircleAvatar(
                    radius: 18,
                    backgroundImage: FileImage(_profileImage!),
                  )
                : CircleAvatar(
                    radius: 18,
                    child: SvgPicture.asset(
                      'assets/user.svg',
                      width: 36,
                      height: 36,
                    ),
                  ),
            Gaps.h10,
            Expanded(
              child: TextField(
                onTap: _onStartWriting,
                controller: commentController,
                minLines: null,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                    hintText: widget.recommentMode
                        ? "Add ${widget.comment} recomment"
                        : "Add comment...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Sizes.size12,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: Sizes.size10,
                      horizontal: Sizes.size12,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: Sizes.size14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isWriting)
                            GestureDetector(
                              onTap: () {
                                _stopWriting();
                                widget.recommentMode
                                    ? toggleRecommentSend(
                                        context,
                                        postInfo.getCommentId(),
                                        commentController.text)
                                    : toggleCommentSend(context, widget.postId,
                                        commentController.text);
                              },
                              child: FaIcon(
                                FontAwesomeIcons.circleArrowUp,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
