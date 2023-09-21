import 'package:flutter/material.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

class NoticeWidget extends StatelessWidget {
  const NoticeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'HANASAKUがオープンしました！',
              style: TextStyle(
                  fontSize: Sizes.size16, fontWeight: FontWeight.bold),
            ),
            Gaps.v10,
            Text(
                'こんにちは。チーム「HANASAKU」です。\n\nHANASAKUは「話の花が咲く。」の略語で、\n\n皆さんの不便のない話のために作られたサービスです。\n\n好きなアイドルRoomに入って、皆さんのお話でサービスの最初のページを飾ってみてください。\n\nより良いサービスに生まれ変わるために常に努力するHANASAKUになります。\n\nありがとうございます。')
          ],
        ),
      ),
    );
  }
}
