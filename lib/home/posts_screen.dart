import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/notify_screen.dart';
import 'package:hanasaku/home/post_query_widget.dart';

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
    final categoryIdModel = Provider.of<CategoryIdChange>(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            categoryIdModel.setCategoryId(0);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Sizes.size16, vertical: Sizes.size14),
            child: FaIcon(FontAwesomeIcons.bars),
          ),
        ),
        title: const Text('Home'),
        actions: [
          Row(
            children: [
              IconButton(
                alignment: Alignment.bottomRight,
                onPressed: () {},
                icon: const FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                ),
              ),
              IconButton(
                alignment: Alignment.bottomCenter,
                onPressed: () {
                  navigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => const NotifyScreen()));
                },
                icon: const FaIcon(FontAwesomeIcons.bell),
              ),
            ],
          ),
        ],
      ),
      body: PostsQuery(
        categoryId: widget.categoryId,
        postsPerPage: postsPerPage,
        scrollController: scrollController,
      ),
    );
  }
}
