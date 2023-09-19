import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/widget/post_widget.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/navigator.dart';

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
    double screenHeight = MediaQuery.of(context).size.height;
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
                      child: Container(
                        height: screenHeight / 20,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade300),
                        child: Center(
                          child: TextField(
                            autofocus: true,
                            textAlign: TextAlign.start,
                            controller: textController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                hintText: "",
                                labelStyle: const TextStyle(
                                    color: Colors.grey), // 이 부분을 추가합니다.
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: GestureDetector(
                                    onTap: () {},
                                    child: const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ))),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          navigatorKey.currentState!.pop(context);
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.circleXmark,
                          color: Colors.grey.shade400,
                        ))
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
