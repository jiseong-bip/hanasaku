import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/idol_data.dart';

import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/notify_screen.dart';
import 'package:hanasaku/home/post_query_widget.dart';
import 'package:hanasaku/home/widget/search_widget.dart';

import 'package:hanasaku/setup/navigator.dart';

import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class PostsScreen extends StatefulWidget {
  final int categoryId;
  const PostsScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  int postsPerPage = 5;
  int currentPostCount = 0;

  List<Map<String, dynamic>> allPosts = [];
  final ScrollController scrollController = ScrollController();

  List<dynamic>? posts;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userInfoModel = Provider.of<UserInfoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            userInfoModel.setCurrentCategory(0);
          },
          child: const Padding(
            padding: EdgeInsets.only(
                left: Sizes.size16, top: Sizes.size20, bottom: Sizes.size20),
            child: FaIcon(
              FontAwesomeIcons.listUl,
              size: Sizes.size20,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
            '${idolData.singleWhere((idol) => idol["id"] == widget.categoryId)["type"]} Room'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  navigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => const SearchWidget()));
                },
                icon: const FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: Sizes.size20,
                ),
              ),
              IconButton(
                onPressed: () {
                  navigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => const NotifyScreen()));
                },
                icon: const FaIcon(
                  FontAwesomeIcons.bell,
                  size: Sizes.size20,
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // 왼쪽으로 스와이프 했을 때의 동작
            userInfoModel.setCurrentCategory(0);
          }
        },
        child: PostsQuery(
          categoryId: widget.categoryId,
          postsPerPage: postsPerPage,
          scrollController: scrollController,
        ),
      ),
    );
  }
}
