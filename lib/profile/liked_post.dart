// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/idol_data.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/screens/detail_screen.dart';
import 'package:hanasaku/query&mutation/querys.dart';

class LikedPostScreen extends StatefulWidget {
  const LikedPostScreen({super.key});

  @override
  State<LikedPostScreen> createState() => _LikedPostScreenState();
}

class _LikedPostScreenState extends State<LikedPostScreen> {
  final List _posts = [];
  bool isExpanded = false;
  int? _expandedCategoryId;
  double _height = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchMyPosts();
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _height = 96.0;
      });
      // Start the timer after the initial animation
      _startTimer();
    });
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
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchMyPosts() async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: likedPostQuery,
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    );

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        if (result.data!['me']['postLikes'] != null) {
          _posts.addAll(result.data!['me']['postLikes']);
        }
      });
    } else {
      print(result.exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_posts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('いいねを押した掲示物'),
        ),
        body: Center(
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
      );
    }
    // Step 1: Grouping posts by categoryId
    Map<int, List> groupedPosts = {};
    for (var post in _posts) {
      int categoryId = post['post']['categoryId'];
      if (!groupedPosts.containsKey(categoryId)) {
        groupedPosts[categoryId] = [];
      }
      groupedPosts[categoryId]?.add(post);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('私が書いた掲示物'),
      ),
      body: CustomScrollView(
        slivers: [
          for (int categoryId in groupedPosts.keys) ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 50.0,
                maxHeight: 50.0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_expandedCategoryId == categoryId) {
                        _expandedCategoryId =
                            null; // collapse if already expanded
                      } else {
                        _expandedCategoryId =
                            categoryId; // expand this category
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.size10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: idolData.singleWhere(
                            (idol) => idol["id"] == categoryId)["color"],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "${idolData.singleWhere((idol) => idol["id"] == categoryId)["type"]} Room",
                            style: const TextStyle(
                                fontSize: Sizes.size20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        _expandedCategoryId == categoryId
                            ? const Align(
                                alignment: Alignment.centerRight,
                                child: FaIcon(
                                  FontAwesomeIcons.angleUp,
                                  size: Sizes.size20,
                                  color: Colors.white,
                                ))
                            : const Align(
                                alignment: Alignment.centerRight,
                                child: FaIcon(
                                  FontAwesomeIcons.angleDown,
                                  size: Sizes.size20,
                                  color: Colors.white,
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_expandedCategoryId ==
                categoryId) // Only show if this category is expanded
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  ((context, postIndex) {
                    final post = groupedPosts[categoryId]?[postIndex];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                      postId: post?['post']['id'],
                                      isContent: false,
                                    )));
                      },
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size16,
                            vertical: Sizes.size10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${post?['post']['title']}",
                                style: const TextStyle(
                                    fontSize: Sizes.size16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Gaps.v10,
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.solidHeart,
                                    color: Theme.of(context).primaryColor,
                                    size: Sizes.size16,
                                  ),
                                  Gaps.h5,
                                  Text(
                                    '${post?['post']['likeCount']}',
                                    style: const TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                  Gaps.h10,
                                  FaIcon(
                                    FontAwesomeIcons.comment,
                                    color: Colors.grey.shade600,
                                    size: Sizes.size16,
                                  ),
                                  Gaps.h5,
                                  Text(
                                    '${post?['post']['comments'].length}',
                                    style: const TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  childCount: groupedPosts[categoryId]?.length ?? 0,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
