// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/idol_data.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/detail_screen.dart';
import 'package:hanasaku/query&mutation/querys.dart';

class CommentPostScreen extends StatefulWidget {
  const CommentPostScreen({super.key});

  @override
  State<CommentPostScreen> createState() => _CommentPostScreenState();
}

class _CommentPostScreenState extends State<CommentPostScreen> {
  final List _posts = [];
  bool isExpanded = false;
  int? _expandedCategoryId;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchMyPosts(FetchPolicy.cacheAndNetwork);
    });
  }

  Future<void> _fetchMyPosts(FetchPolicy fetchPolicy) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
        document: myCommentQuery,
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll);
    try {
      final QueryResult result = await client.query(options);

      if (!result.hasException) {
        setState(() {
          if (result.data!['me']['postComments'] != null) {
            _posts.addAll(result.data!['me']['postComments']);
          }
        });
      } else {
        print(result.exception);
      }
    } catch (e) {
      if (e is CacheMissException) {
        // 캐시 미스 예외 처리, 예: 데이터 다시 가져오기
        await _fetchMyPosts(FetchPolicy.networkOnly);
      } else {
        print("Error occurred: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Grouping posts by categoryId
    if (_posts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('コメント欄の掲示物'),
        ),
        body: const Center(
          child: Center(
            child: Text('コメントしてみてください'),
          ), // or Text("Loading...")
        ),
      );
    }

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
        title: const Text('コメント欄の掲示物'),
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
                                fontFamily: MyFontFamily.lineSeedJP,
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
                                      avatorKey: post?['user']['avatar'],
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
                                    fontFamily: MyFontFamily.lineSeedJP,
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
                                        fontFamily: MyFontFamily.lineSeedJP),
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
                                        fontFamily: MyFontFamily.lineSeedJP),
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
