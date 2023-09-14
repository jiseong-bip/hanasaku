// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/idol_data.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/detail_page.dart';
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
        document: likedPostQuery, fetchPolicy: FetchPolicy.cacheAndNetwork);

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        if (result.data!['me']['postLikes'] != null) {
          _posts.addAll(result.data!['me']['postLikes']);
        }

        print(_posts);
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
        body: const Center(
          child: Center(
            child: Text('いいねを押してください'),
          ), // or Text("Loading...")
        ),
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
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "${idolData.singleWhere((idol) => idol["id"] == categoryId)["type"]}"),
                        Gaps.h14,
                        _expandedCategoryId == categoryId
                            ? const FaIcon(FontAwesomeIcons.angleUp)
                            : const FaIcon(FontAwesomeIcons.angleDown)
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
                                builder: (context) => DetailPage(
                                      postId: post?['post']['id'],
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
                                style: const TextStyle(fontSize: Sizes.size20),
                              ),
                              Gaps.v10,
                              Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up_alt,
                                    color: Theme.of(context).primaryColor,
                                    size: Sizes.size16,
                                  ),
                                  Gaps.h5,
                                  Text('${post?['post']['likes'].length}'),
                                  Gaps.h10,
                                  const FaIcon(
                                    FontAwesomeIcons.comment,
                                    size: Sizes.size16,
                                  ),
                                  Gaps.h5,
                                  Text('${post?['post']['comments'].length}'),
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
