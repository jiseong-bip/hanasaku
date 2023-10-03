// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/widget/post_widget.dart';
import 'package:hanasaku/main.dart';
import 'package:hanasaku/query&mutation/querys.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController textController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final List _posts = [];

  Future<void> _fetchMorePosts(String keyword) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: searchPost,
      variables: {
        'keyword': keyword,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        _posts.clear();
        _posts.addAll(result.data!['searchPost']);
      });
    } else {
      print(result.exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(
                    vertical: Sizes.size16, horizontal: Sizes.size10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 2, color: Colors.grey.shade300))),
                child: Row(
                  children: [
                    Expanded(
                        child: SearchBar(
                      shadowColor: const MaterialStatePropertyAll(Colors.white),
                      controller: textController,
                      leading: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                      ),
                      trailing: [
                        GestureDetector(
                          onTap: () {
                            textController.clear();
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.grey.shade300),
                      hintText: 'Search',
                      hintStyle: MaterialStateProperty.all(
                          const TextStyle(color: Colors.grey)),
                      onSubmitted: (value) {
                        _fetchMorePosts(value);
                      },
                    )),
                    Gaps.h5,
                    GestureDetector(
                      onTap: () {
                        MyApp.navigatorKey.currentState!.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: Sizes.size12),
                      ),
                    ),
                  ],
                ),
              ),
              if (_posts.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return Post(
                        post: _posts[index],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
