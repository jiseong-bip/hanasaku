import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/screens/detail_screen.dart';
import 'package:hanasaku/main.dart';
import 'package:hanasaku/setup/local_notification.dart';
import 'package:hanasaku/setup/provider_model.dart';
import 'package:provider/provider.dart';

class NotifyScreen extends StatefulWidget {
  const NotifyScreen({
    super.key,
  });

  @override
  State<NotifyScreen> createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  @override
  void initState() {
    LocalNotification.resetBadge();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTapDelete() {
    setState(() {});
    Provider.of<ListResultModel>(context, listen: false).clear();
  }

  @override
  Widget build(BuildContext context) {
    final listResultModel = ListResultService.instance.listResultModel;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size10,
            ),
            child: IconButton(
                onPressed: _onTapDelete,
                icon: FaIcon(
                  FontAwesomeIcons.trash,
                  color: Colors.grey.shade400,
                )),
          )
        ],
      ),
      body: listResultModel.pushNotiList.isEmpty
          ? const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.bellSlash,
                      size: Sizes.size40,
                    ),
                  ]),
            )
          : ListView.builder(
              itemCount: listResultModel.pushNotiList.length,
              itemBuilder: (context, index) {
                int reverseIndex =
                    listResultModel.pushNotiList.length - 1 - index;
                return listResultModel.pushNotiList[reverseIndex]!['data']
                            ['type'] ==
                        'postLike'
                    ? GestureDetector(
                        onTap: () {
                          MyApp.navigatorKey.currentState!.push(
                              MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                      postId: int.parse(
                                          listResultModel.pushNotiList[
                                              reverseIndex]!['data']['postId']),
                                      isContent: false)));
                        },
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size10,
                            vertical: Sizes.size12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // Expanded 위젯 추가
                                child: Text(
                                  '${listResultModel.pushNotiList[reverseIndex]!['message']}',
                                  style: const TextStyle(
                                    fontSize: Sizes.size16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow:
                                      TextOverflow.visible, // overflow 속성 변경
                                  maxLines:
                                      2, // maxLines 속성 설정 (원하는 줄 수로 변경 가능)
                                ),
                              ),
                              FaIcon(
                                FontAwesomeIcons.solidHeart,
                                color: Theme.of(context).primaryColor,
                                size: Sizes.size24,
                              )
                            ],
                          ),
                        )),
                      )
                    : GestureDetector(
                        onTap: () {
                          MyApp.navigatorKey.currentState!.push(
                              MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                      postId: int.parse(listResultModel
                                              .pushNotiList[reverseIndex]![
                                          'data']['type']['postId']),
                                      isContent: false)));
                        },
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size10,
                            vertical: Sizes.size12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // Expanded 위젯 추가
                                child: Text(
                                  '${listResultModel.pushNotiList[reverseIndex]!['message']}',
                                  style: const TextStyle(
                                    fontSize: Sizes.size16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow:
                                      TextOverflow.visible, // overflow 속성 변경
                                  maxLines:
                                      2, // maxLines 속성 설정 (원하는 줄 수로 변경 가능)
                                ),
                              ),
                              const FaIcon(
                                FontAwesomeIcons.solidComment,
                                color: Color(0xFFC1DE92),
                                size: Sizes.size24,
                              )
                            ],
                          ),
                        )),
                      );
              },
            ),
    );
  }
}
