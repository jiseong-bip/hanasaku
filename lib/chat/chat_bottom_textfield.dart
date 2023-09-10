// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class BottomTextBar extends StatefulWidget {
  final TextEditingController commentController;
  final int userId;
  final int? roomId;
  final Function(bool isSendPost, int? roomId) onMessageChanged;

  const BottomTextBar({
    super.key,
    required this.commentController,
    required this.onMessageChanged,
    required this.userId,
    this.roomId,
  });

  @override
  State<BottomTextBar> createState() => _BottomTextBarState();
}

class _BottomTextBarState extends State<BottomTextBar> {
  String? nickName;
  bool _isWriting = false;
  bool _isSend = false;

  Future<void> toggleChatSend(BuildContext context, String chat) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation SendMessage(\$message: String!, \$userId: Int!, \$roomId: Int) {
          sendMessage(message: \$message, userId: \$userId, roomId: \$roomId) {
            ok
            error
            roomId
          }
        }
      '''),
      variables: <String, dynamic>{
        "userId": widget.userId,
        "message": chat,
        "roomId": widget.roomId,
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

        if (resultData != null && resultData['sendMessage'] != null) {
          final bool isLikeSuccessful = resultData['sendMessage']['ok'];
          if (isLikeSuccessful) {
            widget.commentController.clear();
            setState(() {
              _isSend = !_isSend;
            });

            widget.onMessageChanged(
                _isSend, resultData['sendMessage']['roomId']);
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
    initName();
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context).getNickName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.size16,
          vertical: Sizes.size10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade500,
              foregroundColor: Colors.white,
              child: Text(
                nickName ?? ' ',
                style: const TextStyle(fontSize: Sizes.size14),
              ),
            ),
            Gaps.h10,
            Expanded(
              child: TextField(
                onTap: _onStartWriting,
                controller: widget.commentController,
                minLines: null,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                    hintText: "Add comment...",
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
                                toggleChatSend(
                                    context, widget.commentController.text);
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
