import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/home/graphql/function_mutaion.dart';
import 'package:hanasaku/home/graphql/function_query.dart';
import 'package:hanasaku/home/widget/category_widget.dart';
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
          child: Stack(
            children: [
              Consumer<UserInfoProvider>(
                  builder: (context, userInFoProvider, child) {
                bool disableJoin = userInFoProvider
                        .getCategoryName()
                        .where((item) => item["isSelected"] == true)
                        .length >=
                    3;

                return ListWheelScrollView(
                  controller: _scrollController,
                  diameterRatio: 2,
                  itemExtent: screenHeight * 0.2, // Adjust based on your needs
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: Sizes.size10,
                        left: Sizes.size10,
                        right: Sizes.size10),
                    child: Row(
                      children: [
                        Expanded(
                            child: SizedBox(
                          height: 40,
                          child: SearchBar(
                            constraints: const BoxConstraints(
                                maxHeight: double.infinity),
                            elevation: const MaterialStatePropertyAll(0),
                            shadowColor:
                                const MaterialStatePropertyAll(Colors.white),
                            controller: _searchController,
                            leading: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                            ),
                            trailing: [
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
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
                              scrollToIdol(value);
                            },
                          ),
                        )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                gearIconClicked = !gearIconClicked;
                              });
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.sliders,
                              color: gearIconClicked
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade600,
                            ))
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Sizes.size12),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: screenHeight * 0.2,
                      decoration:
                          BoxDecoration(color: Colors.grey.withOpacity(0.8)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
