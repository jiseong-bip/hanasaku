import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
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
    streamController.add("");
    super.dispose();
  }

  void _onTapDelete() {
    setState(() {});
    Provider.of<ListResultModel>(context, listen: false).clear();
  }

  @override
  Widget build(BuildContext context) {
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
      body:
          Consumer<ListResultModel>(builder: (context, listResultModel, child) {
        return listResultModel.listResult.isEmpty
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
            : ListView.separated(
                separatorBuilder: (context, index) => Gaps.v20,
                itemCount: listResultModel.listResult.length,
                itemBuilder: (context, index) {
                  int reverseIndex =
                      listResultModel.listResult.length - 1 - index;
                  return listResultModel.listResult[reverseIndex]!
                          .containsKey('postLikeAlarm')
                      ? GestureDetector(
                          onTap: () {
                            MyApp.navigatorKey.currentState!.push(
                                MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                        postId: listResultModel.listResult[
                                                reverseIndex]!['postLikeAlarm']
                                            ['post']['id'],
                                        isContent: false)));
                          },
                          child: Card(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.size16 + Sizes.size2,
                              vertical: Sizes.size16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${listResultModel.listResult[reverseIndex]!['postLikeAlarm']['user']['userName']}が'),
                                    Text(
                                      '${listResultModel.listResult[reverseIndex]!['postLikeAlarm']['post']['title']}に「いいね」しました。',
                                      style: const TextStyle(
                                        fontSize: Sizes.size16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
                                        postId: listResultModel
                                                .listResult[reverseIndex]![
                                            'postCommentAlarm']['post']['id'],
                                        isContent: false)));
                          },
                          child: Card(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.size16 + Sizes.size2,
                              vertical: Sizes.size16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${listResultModel.listResult[reverseIndex]!['postCommentAlarm']['user']['userName']}が'),
                                    Text(
                                      '${listResultModel.listResult[reverseIndex]!['postCommentAlarm']['post']['title']}にコメントしました。',
                                      style: const TextStyle(
                                        fontSize: Sizes.size16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
              );
      }),
    );
  }
}
