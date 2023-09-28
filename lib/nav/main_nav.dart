// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/chat/chat_list_screen.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/contents/contents_list_screen.dart';
import 'package:hanasaku/create/create_post.dart';
import 'package:hanasaku/home/category_screen.dart';

import 'package:hanasaku/home/posts_screen.dart';
import 'package:hanasaku/home/subscription.dart';
import 'package:hanasaku/nav/nav_button.dart';
import 'package:hanasaku/profile/my_page_screen.dart';

import 'package:hanasaku/setup/provider_model.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  late Stream<dynamic> logLikeStream;
  late Stream<dynamic> logCommentStream;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    // Capture the context when initializing the state
  }
  // Future<void> _onCategoryTab(BuildContext context) async {
  //   final result = await Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => const CategoryPage())) ??
  //       categoryId;
  //   setState(() {
  //     categoryId = result;
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
  }

  void onTapCreate() {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) => const CreateScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    logLikeStream = client.subscribe(SubscriptionOptions(
      document: likeSubscription,
    ));
    logCommentStream = client.subscribe(SubscriptionOptions(
      document: commentSubscription,
    ));

    logLikeStream.listen((event) {
      final listResultModel =
          Provider.of<ListResultModel>(context, listen: false);
      listResultModel.updateList(event.data, null);
    });

    logCommentStream.listen((event) {
      final listResultModel =
          Provider.of<ListResultModel>(context, listen: false);
      listResultModel.updateList(null, event.data);
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Consumer<UserInfoProvider>(
            builder: (context, userInfo, child) {
              return Offstage(
                offstage: _selectedIndex != 0,
                child:
                    // PageView(
                    //   controller: controller,
                    //   scrollDirection: Axis.horizontal,
                    //   children: [
                    //     const CategoryPage(),
                    //     PostsScreen(categoryId: userInfo.getCurrentCategory())
                    //   ],
                    // )
                    userInfo.getCurrentCategory() == 0
                        ? const CategoryPage()
                        : PostsScreen(
                            categoryId: userInfo.getCurrentCategory()),
              );
            },
          ),
          Offstage(
            offstage: _selectedIndex != 1,
            child: const ContentsScreen(),
          ),
          Offstage(
            offstage: _selectedIndex != 3,
            child: ChatRoomScreen(
              key: GlobalKey(),
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 4,
            child: const MyPageScreen(),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NavTab(
                //text: "Home",
                isSelected: _selectedIndex == 0,
                icon: FontAwesomeIcons.house,
                selectedIcon: FontAwesomeIcons.house,
                onTap: () => _onTap(0),
              ),
              NavTab(
                //text: "Contents",
                isSelected: _selectedIndex == 1,
                icon: FontAwesomeIcons.podcast,
                selectedIcon: FontAwesomeIcons.podcast,
                onTap: () => _onTap(1),
              ),
              NavTab(
                //text: "Create",
                isSelected: _selectedIndex == 2,
                icon: FontAwesomeIcons.squarePlus,
                selectedIcon: FontAwesomeIcons.squarePlus,
                onTap: () => {
                  onTapCreate(),
                },
              ),
              NavTab(
                //text: "Chats",
                isSelected: _selectedIndex == 3,
                icon: FontAwesomeIcons.message,
                selectedIcon: FontAwesomeIcons.solidMessage,
                onTap: () => _onTap(3),
              ),
              NavTab(
                //text: "Profile",
                isSelected: _selectedIndex == 4,
                icon: FontAwesomeIcons.user,
                selectedIcon: FontAwesomeIcons.solidUser,
                onTap: () => _onTap(4),
              ),
            ],
          ),
        ),
      ),
      //bottomNavigationBar: ,
    );
  }
}
