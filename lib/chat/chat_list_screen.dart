// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/chat/chat_room_screen.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/aws_s3.dart';
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
  List<Object?> avatarImagekey = [];
  late Future<File> _cachedFile;

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
      return "${dayDifference}d ago";
    } else if (hoursDifference != 0) {
      return "${hoursDifference}h ago";
    } else {
      return "${minDifference}m ago";
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
        for (var user in _chatList) {
          user['user']['avatar'] != null
              ? avatarImagekey.add({
                  '__typename': 'userAvator',
                  'avatar': user['user']['avatar']
                })
              : null;
        }
        _isSelected = List<bool>.filled(_chatList.length, false);
      });
      await getListImage(avatarImagekey);
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
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.grey.shade500,
              size: Sizes.size28,
            ),
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
          child: Stack(
            children: [
              if (_chatList.isEmpty) const Center(child: Text('会話をかけてみてください.')),
              ListView.separated(
                separatorBuilder: (context, index) => Gaps.v14,
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  if (_chatList[index]['user']['avatar'] != null) {
                    _cachedFile = DefaultCacheManager()
                        .getSingleFile(_chatList[index]['user']['avatar']);
                  }

                  return InkWell(
                    onTap: _isSelectMode
                        ? () {
                            setState(() {
                              _isSelected[index] = !_isSelected[index];
                              if (_isSelected[index]) {
                                _selectedChatIds.add(_chatList[index]['id']);
                              } else {
                                _selectedChatIds.remove(_chatList[index]['id']);
                              }
                            });
                          }
                        : () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatRoom(
                                      userId: _chatList[index]['user']['id'],
                                      userName: _chatList[index]['user']
                                          ['userName'],
                                      roomId: _chatList[index]['id'],
                                    )));
                          },
                    child: Container(
                      constraints:
                          const BoxConstraints(minHeight: 55, maxHeight: 55),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _chatList[index]['user']['avatar'] != null
                              ? FutureBuilder(
                                  future: _cachedFile,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        // 에러 처리
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (snapshot.hasData) {
                                        final file = snapshot.data as File;

                                        // 파일을 이미지로 변환하여 CircleAvatar의 backgroundImage로 설정
                                        return CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              Image.file(file).image,
                                        );
                                      } else {
                                        return const Text(
                                            'No data'); // 데이터 없음 처리
                                      }
                                    } else {
                                      return const CircularProgressIndicator(); // 로딩 중 처리
                                    }
                                  })
                              : CircleAvatar(
                                  radius: 20,
                                  child: SvgPicture.asset(
                                    'assets/user.svg',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                          Gaps.h14,
                          Expanded(
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '${_chatList[index]['user']['userName']}',
                                    style: const TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                (_chatList[index]['lastMessage']['isRead'] ||
                                        _chatList[index]['lastMessage']['user']
                                                ['userName'] ==
                                            nickName)
                                    ? Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          '${_chatList[index]['lastMessage']['message']}',
                                          style: TextStyle(
                                              fontSize: Sizes.size16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey.shade600),
                                        ),
                                      )
                                    : Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          '${_chatList[index]['lastMessage']['message']}',
                                          style: const TextStyle(
                                            fontSize: Sizes.size16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              getTime(
                                _chatList[index]['lastMessage']['createDate'],
                              ),
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: Sizes.size12),
                            ),
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
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isSelectMode
          ? BottomAppBar(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: Theme.of(context).primaryColor,
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
