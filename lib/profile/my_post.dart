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

class MyPostScreen extends StatefulWidget {
  const MyPostScreen({super.key});

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  final List _posts = [];
  bool isExpanded = false;
  int? _expandedCategoryId;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchMyPosts();
    });
  }

  Future<void> _fetchMyPosts() async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
        document: myPostQuery, fetchPolicy: FetchPolicy.cacheAndNetwork);

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        if (result.data!['me']['posts'] != null) {
          _posts.addAll(result.data!['me']['posts']);
        }
      });
    } else {
      print(result.exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(idolData.singleWhere((idol) => idol["id"] == 1)["color"]);
    if (_posts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '私が書いた掲示物',
            style: TextStyle(fontFamily: MyFontFamily.lineSeedJP),
          ),
        ),
        body: const Center(
          child: Center(
            child: Text(
              '掲示物を作成してみてください',
              style: TextStyle(fontFamily: MyFontFamily.lineSeedJP),
            ),
          ), // or Text("Loading...")
        ),
      );
    }
    Map<int, List> groupedPosts = {};
    for (var post in _posts) {
      int categoryId = post['categoryId'];
      if (!groupedPosts.containsKey(categoryId)) {
        groupedPosts[categoryId] = [];
      }
      groupedPosts[categoryId]?.add(post);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '私が書いた掲示物',
          style: TextStyle(
              fontFamily: MyFontFamily.lineSeedJP, fontWeight: FontWeight.w400),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          for (int categoryId in groupedPosts.keys) ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 50.0,
                maxHeight: 60.0,
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
                                      postId: post?['id'],
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
                                "${post?['title']}",
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
                                    '${post?['likeCount']}',
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
                                    '${post?['comments'].length}',
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
