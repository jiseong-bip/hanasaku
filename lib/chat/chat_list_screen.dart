// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/chat/chat_room_screen.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  String? nickName;
  final List _chatList = [];
  bool _isSelectMode = false;
  List<bool> _isSelected = [];
  final List _selectedChatIds = [];

  @override
  void initState() {
    super.initState();
    _isSelected = List<bool>.filled(_chatList.length, false);
    initName();
    Future.delayed(Duration.zero, () {
      _fetchChatList(FetchPolicy.networkOnly);
    });
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

  Future<void> _fetchChatList(FetchPolicy fetchPolicy) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: chatRoomsQuery,
      fetchPolicy: fetchPolicy,
    );

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        _chatList.clear();
        _chatList.addAll(result.data!['viewChatRooms']);
        _isSelected = List<bool>.filled(_chatList.length, false);
      });
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _isSelectMode = !_isSelectMode;
                _isSelected = List<bool>.filled(_chatList.length, false);
                _selectedChatIds.clear();
              });
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchChatList(FetchPolicy.networkOnly),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size12, vertical: Sizes.size10),
          child: _chatList.isEmpty
              ? const Text('대화를 걸어보세요')
              : ListView.separated(
                  separatorBuilder: (context, index) => Gaps.v12,
                  itemCount: _chatList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: _isSelectMode
                          ? () {
                              setState(() {
                                _isSelected[index] = !_isSelected[index];
                                if (_isSelected[index]) {
                                  _selectedChatIds.add(_chatList[index]['id']);
                                } else {
                                  _selectedChatIds
                                      .remove(_chatList[index]['id']);
                                }
                              });
                            }
                          : () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChatRoom(
                                        roomId: _chatList[index]['id'],
                                      )));
                            },
                      child: Row(
                        children: [
                          Container(
                            width: Sizes.size52, // 아이콘 크기 + 여분의 여백
                            height: Sizes.size52, // 아이콘 크기 + 여분의 여백
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle, // 원 모양으로 만들기
                              color: Colors.blue, // 배경 색상 설정
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.user,
                                size: Sizes.size32,
                                color: Colors.white, // 아이콘 색상 설정
                              ),
                            ),
                          ),
                          Gaps.h14,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_chatList[index]['user']['userName']}',
                                  style: const TextStyle(
                                    fontSize: Sizes.size16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Gaps.v10,
                                (_chatList[index]['lastMessage']['isRead'] ||
                                        _chatList[index]['lastMessage']['user']
                                                ['userName'] ==
                                            nickName)
                                    ? Text(
                                        '${_chatList[index]['lastMessage']['message']}',
                                        style: TextStyle(
                                            fontSize: Sizes.size20,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey.shade600),
                                      )
                                    : Text(
                                        '${_chatList[index]['lastMessage']['message']}',
                                        style: const TextStyle(
                                          fontSize: Sizes.size20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          Text(
                            getTime(
                                _chatList[index]['lastMessage']['createDate']),
                          ),
                          if (_isSelectMode)
                            Checkbox(
                              value: _isSelected[index],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _isSelected[index] = newValue!;
                                  if (_isSelected[index]) {
                                    _selectedChatIds
                                        .add(_chatList[index]['id']);
                                  } else {
                                    _selectedChatIds
                                        .remove(_chatList[index]['id']);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: _isSelectMode
          ? BottomAppBar(
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        for (var id in _selectedChatIds) {
                          print(id);
                          _deleteRoom(id);
                        }

                        for (int i = _chatList.length - 1; i >= 0; i--) {
                          if (_isSelected[i]) {
                            _chatList.removeAt(i);
                          }
                        }
                        _isSelected =
                            List<bool>.filled(_chatList.length, false);
                        _selectedChatIds.clear();
                        _isSelectMode = false;
                        setState(() {});
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
