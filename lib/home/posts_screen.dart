import 'package:flutter/material.dart';
import 'package:hanasaku/home/post_query_widget.dart';

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
    return Scaffold(
      body: PostsQuery(
        categoryId: widget.categoryId,
        postsPerPage: postsPerPage,
        scrollController: scrollController,
      ),
    );
  }
}
