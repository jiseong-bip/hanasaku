// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/chat/chat_bottom_textfield.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  final int? roomId, userId;
  final String userName;
  const ChatRoom({
    super.key,
    this.roomId,
    this.userId,
    required this.userName,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String? nickName;
  List _chatList = <dynamic>[];
  int userId = 0;
  bool _isSelectMode = false;
  List<bool> _isSelected = [];
  List<int> selectedMessageIds = [];
  int? _roomId;

  final TextEditingController commentController = TextEditingController();

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
  }

  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    initName();
    if (widget.roomId != null) {
      Future.delayed(Duration.zero, () {
        _fetchChatList(FetchPolicy.networkOnly, widget.roomId!);
      });
    }
    if (widget.userId != null) {
      userId = widget.userId!;
    }
  }

  Future<void> _fetchChatList(FetchPolicy fetchPolicy, int? roomId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: chatQuery,
      variables: {
        "viewChatRoomRoomId2": roomId!,
      },
      fetchPolicy: fetchPolicy,
    );

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        _chatList.clear();
        _chatList = [...result.data!['viewChatRoom']['messages']];

        for (var chat in _chatList) {
          if (chat['user']['userName'] != nickName) {
            userId = chat['user']['id'];
          }
        }

        if (_chatList.isEmpty) {
          _deleteRoom(roomId);
        }
      });
      _readMessages();
    } else {
      print(result.exception);
    }
  }

  Future<void> _deleteRoom(int selectedChatIds) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation LeaveChatRoom(\$roomId: Int!) {
          leaveChatRoom(roomId: \$roomId) {
            ok
          }
        }
      '''),
      variables: {
        'roomId': selectedChatIds,
      },
      onError: (error) {
        print(error);
      },
    );

    try {
      print('sending..');
      final QueryResult result = await client.mutate(options);
      print('done Sending..');
      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null && resultData['leaveChatRoom'] != null) {
          final bool isLikeSuccessful = resultData['leaveChatRoom']['ok'];

          if (isLikeSuccessful) {
            print('good');
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

  Future<void> _deleteSelectedMessages() async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    print(selectedMessageIds);
    List<int> idsToDelete = List.from(selectedMessageIds);
    for (int messageId in idsToDelete) {
      final MutationOptions options = MutationOptions(
        document: gql('''
          mutation DeleteMessage(\$messageId: Int!) {
            deleteMessage(messageId: \$messageId) {
              ok
            }
          }
        '''),
        variables: {
          'messageId': messageId,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        print(result.exception);
      }
    }
    print('delete _roomId : $_roomId');

    _fetchChatList(FetchPolicy.networkOnly, _roomId);
  }

  Future<void> _readMessages() async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    for (var messages in _chatList) {
      var messgaeId = messages['id'];
      final MutationOptions options = MutationOptions(
        document: gql('''
          mutation ReadMessage(\$messageId: Int!) {
            readMessage(messageId: \$messageId) {
              ok
            }
          }
        '''),
        variables: {
          'messageId': messgaeId,
        },
      );

      final QueryResult result = await client.mutate(options);
      if (result.hasException) {
        print(result.exception);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.roomId);
    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.userName),
          actions: [
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.trash,
                color: Colors.grey.shade500,
                size: Sizes.size20,
              ),
              onPressed: () {
                setState(() {
                  _isSelectMode = !_isSelectMode;
                  _isSelected = List<bool>.filled(_chatList.length, false);
                  selectedMessageIds.clear();
                });
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: _isSelectMode
                        ? () {
                            if (_chatList[index]['user']['userName'] ==
                                nickName) {
                              setState(() {
                                _isSelected[index] = !_isSelected[index];
                                if (_isSelected[index]) {
                                  selectedMessageIds
                                      .add(_chatList[index]['id']);
                                } else {
                                  selectedMessageIds
                                      .remove(_chatList[index]['id']);
                                }
                              });
                            }
                          }
                        : null,
                    child: _chatList[index]['user']['userName'] == nickName
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size12,
                                vertical: Sizes.size5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Sizes.size10),
                                      constraints: const BoxConstraints(
                                          minHeight: 35, maxHeight: 35),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color(0xFFEFAFC3)),
                                      child: Center(
                                        child: Text(
                                          '${_chatList[index]['message']}',
                                          style: const TextStyle(
                                            fontSize: Sizes.size16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                if (_isSelectMode)
                                  Checkbox(
                                    activeColor: Theme.of(context).primaryColor,
                                    focusColor: Theme.of(context).primaryColor,
                                    shape: const CircleBorder(),
                                    value: _isSelected[index],
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _isSelected[index] = newValue!;
                                        if (_isSelected[index]) {
                                          selectedMessageIds
                                              .add(_chatList[index]['id']);
                                        } else {
                                          selectedMessageIds
                                              .remove(_chatList[index]['id']);
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size12,
                                vertical: Sizes.size5),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                          minHeight: 35, maxHeight: 35),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color(0xFFE3E7EB)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Sizes.size10,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${_chatList[index]['message']}',
                                            style: const TextStyle(
                                              fontSize: Sizes.size16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                if (_isSelectMode &&
                                    _chatList[index]['user']['userName'] ==
                                        nickName)
                                  Checkbox(
                                    value: _isSelected[index],
                                    onChanged: _chatList[index]['user']
                                                ['userName'] ==
                                            nickName
                                        ? (bool? newValue) {
                                            setState(() {
                                              _isSelected[index] = newValue!;
                                              if (_isSelected[index]) {
                                                selectedMessageIds.add(
                                                    _chatList[index]['id']);
                                              } else {
                                                selectedMessageIds.remove(
                                                    _chatList[index]['id']);
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                              ],
                            ),
                          ),
                  );
                },
              ),
            ),
            if (_isSelectMode)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        for (int i = _chatList.length - 1; i >= 0; i--) {
                          if (_isSelected[i]) {
                            _chatList.removeAt(i);
                          }
                        }
                        _isSelected =
                            List<bool>.filled(_chatList.length, false);
                        _deleteSelectedMessages();
                        setState(() {
                          _isSelectMode = false;
                          _isSelected =
                              List<bool>.filled(_chatList.length, false);
                          selectedMessageIds.clear();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Sizes.size12),
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            'delete',
                            style: TextStyle(
                                fontSize: Sizes.size20,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            BottomTextBar(
              commentController: commentController,
              roomId: widget.roomId == null ? null : widget.roomId!,
              userId: userId,
              onMessageChanged: (isSendPost, roomId) {
                setState(() {
                  _roomId = roomId;
                  _fetchChatList(FetchPolicy.networkOnly, _roomId);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
