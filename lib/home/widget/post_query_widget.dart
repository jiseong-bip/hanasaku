// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/home/widget/post_widget.dart';
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
  double _height = 0.0;
  late Timer _timer;
  //final Color _color = Colors.transparent;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchMorePosts(FetchPolicy.networkOnly);
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _height = 96.0;
      });
      // Start the timer after the initial animation
      _startTimer();
    });

    widget.scrollController.addListener(_onScroll);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _height = _height == 0.0 ? 96.0 : 0.0;
      });
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _timer.cancel();
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
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
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
      child: Stack(
        children: [
          if (_posts.isEmpty)
            Center(
                child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(seconds: 5),
                        height: _height,
                        width: 96, // Adjust the width as needed
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        width: 96, // Adjust the width as needed
                        height: 96, // Adjust the height as needed
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/appicon.png",
                            width: 80, // Adjust the width as needed
                            height: 80, // Adjust the height as needed
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gaps.v16,
                  const Text('皆さんのお話をお待ちしております。'),
                ],
              ),
            )),
          ListView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return Post(
                post: _posts[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
