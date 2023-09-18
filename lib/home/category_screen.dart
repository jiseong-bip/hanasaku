import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/graphql/function_mutaion.dart';
import 'package:hanasaku/home/graphql/function_query.dart';
import 'package:provider/provider.dart';

import '../setup/userinfo_provider_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool gearIconClicked = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getMyCategory(context);
    });
  }

  void _stopWriting() {
    FocusScope.of(context).unfocus();
  }

  int? findIdolIndex(String idolName) {
    List<Map<String, dynamic>> categories =
        Provider.of<UserInfoProvider>(context, listen: false).getCategoryName();
    for (int i = 0; i < categories.length; i++) {
      if (categories[i]['name'].toLowerCase() == idolName.toLowerCase()) {
        return i;
      }
    }
    return null;
  }

  void scrollToIdol(String idolName) {
    int? index = findIdolIndex(idolName);
    if (index != null) {
      double position = index *
          MediaQuery.of(context).size.height *
          0.2; // Since itemExtent is screenHeight * 0.2
      _scrollController.animateTo(position,
          duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => _stopWriting(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey,
                              style: BorderStyle.solid,
                              width: 0.80),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            labelText: "Search Idol",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                scrollToIdol(_searchController.text);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            gearIconClicked = !gearIconClicked;
                          });
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.gear,
                          color: gearIconClicked
                              ? Theme.of(context).primaryColor
                              : null,
                        ))
                  ],
                ),
              ),
              Expanded(
                child: Consumer<UserInfoProvider>(
                    builder: (context, userInFoProvider, child) {
                  bool disableJoin = userInFoProvider
                          .getCategoryName()
                          .where((item) => item["isSelected"] == true)
                          .length >=
                      3;

                  return ListWheelScrollView(
                    controller: _scrollController,
                    diameterRatio: 6,
                    itemExtent:
                        screenHeight * 0.2, // Adjust based on your needs
                    children: userInFoProvider.getCategoryName().map((data) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Sizes.size12, horizontal: Sizes.size16),
                        child: CategoryWidget(
                          id: data['id'],
                          data: data,
                          disableJoin: disableJoin,
                          gearIconClicked: gearIconClicked,
                          onJoin: (int id) {
                            if (!userInFoProvider.getIsSelectedById(id)!) {
                              userInFoProvider.setSelectedCategory(id);
                              setCategoryId(context, id);
                            } else if (gearIconClicked) {
                              userInFoProvider.setSelectedCategory(id);
                              deleteCategoryId(context, id);
                            }
                          },
                          idolName: data['name'],
                          idolColor: [
                            Color(int.parse(data['topColor'])),
                            Color(int.parse(data['bottomColor']))
                          ],
                          isJoined:
                              userInFoProvider.getIsSelectedById(data['id'])!,
                          userInfo: userInFoProvider,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final String idolName;
  final int id;
  final Map<String, dynamic> data;
  final List<Color> idolColor;
  final bool isJoined;
  final bool disableJoin;
  final bool gearIconClicked;
  final UserInfoProvider userInfo;
  final Function(int) onJoin;

  const CategoryWidget({
    super.key,
    required this.id,
    required this.disableJoin,
    required this.onJoin,
    required this.idolName,
    required this.idolColor,
    required this.gearIconClicked,
    required this.isJoined,
    required this.data,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    String buttonText = isJoined ? '입장하기' : '가입하기';
    if (isJoined && gearIconClicked) {
      buttonText = '탈퇴하기';
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: idolColor,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.size10,
                horizontal: Sizes.size10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.ideographic,
                children: [
                  Text(
                    '$idolName ROOM',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Sizes.size24),
                  ),
                  Gaps.h5,
                  const FaIcon(
                    FontAwesomeIcons.solidUser,
                    size: Sizes.size12,
                    color: Colors.white,
                  ),
                  Gaps.h3,
                  Text(
                    '${data['userCount']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: Sizes.size12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Sizes.size10, horizontal: Sizes.size10),
            child: GestureDetector(
              onTap: () {
                if (!disableJoin || isJoined) {
                  onJoin(id);
                }
                if (isJoined && !gearIconClicked) {
                  userInfo.setCurrentCategory(id);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Sizes.size10, horizontal: Sizes.size14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.8)),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.w600,
                    color: disableJoin && !isJoined
                        ? Colors.grey
                        : Color(int.parse(data['topColor'])),
                  ),
                ),
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.symmetric(
            //           vertical: Sizes.size10, horizontal: Sizes.size14),
            //       decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(10),
            //           color: Colors.white.withOpacity(0.6)),
            //       child: Row(
            //         children: [
            //           const FaIcon(
            //             FontAwesomeIcons.user,
            //             size: Sizes.size12,
            //           ),
            //           Gaps.h12,
            //           Text(
            //             '${data['userCount']}',
            //             style: const TextStyle(
            //               fontSize: Sizes.size16,
            //               fontWeight: FontWeight.w400,
            //             ),
            //           ),
            //           Gaps.h24,
            //           const FaIcon(
            //             FontAwesomeIcons.comment,
            //             size: Sizes.size12,
            //           ),
            //           Gaps.h12,
            //           Text(
            //             '${data['postCount']}',
            //             style: const TextStyle(
            //               fontSize: Sizes.size16,
            //               fontWeight: FontWeight.w400,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     GestureDetector(
            //       onTap: () {
            //         if (!disableJoin || isJoined) {
            //           onJoin(id);
            //         }
            //         if (isJoined && !gearIconClicked) {
            //           userInfo.setCurrentCategory(id);
            //         }
            //       },
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //             vertical: Sizes.size10, horizontal: Sizes.size14),
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(10),
            //             color: Colors.white.withOpacity(0.6)),
            //         child: Text(
            //           buttonText,
            //           style: TextStyle(
            //             fontSize: Sizes.size16,
            //             fontWeight: FontWeight.w600,
            //             color: disableJoin && !isJoined
            //                 ? Colors.grey
            //                 : Colors.black,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ),
      ],
    );
  }
}
