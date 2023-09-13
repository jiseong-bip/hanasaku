import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
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
    super.initState();
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
                  color: Theme.of(context).primaryColor,
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
                      ? Card(
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
                                      '${listResultModel.listResult[reverseIndex]!['postLikeAlarm']['user']['userName']}가'),
                                  Text(
                                    '${listResultModel.listResult[reverseIndex]!['postLikeAlarm']['post']['title']}에 좋아요를 눌렀습니다',
                                    style: const TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const FaIcon(
                                FontAwesomeIcons.solidHeart,
                                color: Colors.red,
                                size: Sizes.size24,
                              )
                            ],
                          ),
                        ))
                      : Card(
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
                                      '${listResultModel.listResult[reverseIndex]!['postCommentAlarm']['user']['userName']}가'),
                                  Text(
                                    '${listResultModel.listResult[reverseIndex]!['postCommentAlarm']['post']['title']}에 댓글을 달았습니다',
                                    style: const TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              FaIcon(
                                FontAwesomeIcons.solidComment,
                                color: Colors.grey.shade400,
                                size: Sizes.size24,
                              )
                            ],
                          ),
                        ));
                },
              );
      }),
    );
  }
}
