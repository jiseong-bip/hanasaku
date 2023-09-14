// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/home/post_widget.dart';
import 'package:hanasaku/query&mutation/querys.dart';

class PostsQuery extends StatefulWidget {
  final int categoryId;
  final int postsPerPage;
  final ScrollController scrollController;

  const PostsQuery({
    super.key,
    required this.categoryId,
    required this.postsPerPage,
    required this.scrollController,
  });

  @override
  State<PostsQuery> createState() => _PostsQueryState();
}

class _PostsQueryState extends State<PostsQuery> {
  final List _posts = [];

  int _offset = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchMorePosts(FetchPolicy.networkOnly);
    });

    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels ==
        widget.scrollController.position.maxScrollExtent) {
      _fetchMorePosts(FetchPolicy.cacheFirst);
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _offset = 0;
      _posts.clear();
    });
    await _fetchMorePosts(FetchPolicy.networkOnly);
  }

  Future<void> _fetchMorePosts(FetchPolicy fetchPolicy) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: viewPostsQuery,
      variables: {
        'categoryId': widget.categoryId,
        'take': widget.postsPerPage,
        'offset': _offset,
      },
      fetchPolicy: fetchPolicy,
    );

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        _posts.addAll(result.data!['viewPosts']);
        _offset += widget.postsPerPage;
      });
    } else {
      print(result.exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView.builder(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return Post(
              post: _posts[index],
            );
          }),
    );
  }
}
