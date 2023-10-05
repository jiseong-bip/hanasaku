// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hanasaku/chat/chat_list_screen.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/contents/contents_list_screen.dart';
import 'package:hanasaku/create/create_post.dart';
import 'package:hanasaku/home/screens/category_screen.dart';
import 'package:hanasaku/home/screens/notify_screen.dart';

import 'package:hanasaku/home/screens/posts_screen.dart';

import 'package:hanasaku/main.dart';
import 'package:hanasaku/nav/nav_button.dart';
import 'package:hanasaku/profile/my_page_screen.dart';
import 'package:hanasaku/setup/local_notification.dart';

import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:provider/provider.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  // late Stream<dynamic> logLikeStream;
  // late Stream<dynamic> logCommentStream;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var messageString = "";
  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

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
    LocalNotification.requestPermission();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
          stream: streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              if (snapshot.data == 'post') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const NotifyScreen();
                  }));
                });
              }
            }
            return Stack(
              children: [
                Consumer<UserInfoProvider>(
                  builder: (context, userInfo, child) {
                    return Offstage(
                      offstage: _selectedIndex != 0,
                      child: userInfo.getCurrentCategory() == 0
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
            );
          }),
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
