import 'package:flutter/material.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/main.dart';
import 'package:hanasaku/profile/widget/notice_widget.dart';
import 'package:hanasaku/setup/navigator.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          MyApp.navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const NoticeWidget()));
        },
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size10,
            vertical: Sizes.size12,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(),
            ),
          ),
          child: const Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'HANASAKUがオープンしました！',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Gaps.v5,
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '23.0921',
                  style: TextStyle(
                    fontSize: Sizes.size12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
