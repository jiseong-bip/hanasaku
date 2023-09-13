import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/idol_data.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:provider/provider.dart';

import '../setup/userinfo_provider_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<int> selectedCategoryIds = [];
  bool gearIconClicked = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> setCategoryId(int category) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation Mutation(\$categoryId: Int!) {
          selectCategory(categoryId: \$categoryId) {
            ok
          }
        }
      '''),
      variables: <String, dynamic>{"categoryId": category},
      update: (cache, result) => result,
    );

    try {
      final QueryResult result = await client.mutate(options);
      if (result.data!['selectCategory']['ok']) {
        print('setCategory ok');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seletedCategory = Provider.of<CategoryIdChange>(context);
    var providerCategoryIds = seletedCategory.getSelectedCategoryIds();
    bool disableJoin = seletedCategory.getSelectedCategoryIds().length >= 3;

    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  gearIconClicked = !gearIconClicked;
                });
              },
              icon: const FaIcon(FontAwesomeIcons.gear))
        ],
      ),
      body: ListWheelScrollView(
        diameterRatio: 6,
        itemExtent: screenHeight * 0.3, // Adjust based on your needs
        children: idolData.map((data) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Sizes.size12, horizontal: Sizes.size16),
            child: CategoryWidget(
              id: data['id'],
              disableJoin: disableJoin,
              gearIconClicked: gearIconClicked,
              onJoin: (int id) {
                if (!providerCategoryIds.contains(id)) {
                  setState(() {
                    seletedCategory.setSelectedCategoryIds(id);
                    setCategoryId(id);
                  });
                } else if (gearIconClicked) {
                  setState(() {
                    seletedCategory.removeSelectedCategoryIds(id);
                  });
                }
              },
              idolName: data['type'],
              idolColor: data['color'],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final String idolName;
  final int id;
  final List<Color> idolColor;
  final bool disableJoin;
  final bool gearIconClicked;
  final Function(int) onJoin;

  const CategoryWidget({
    super.key,
    required this.id,
    required this.disableJoin,
    required this.onJoin,
    required this.idolName,
    required this.idolColor,
    required this.gearIconClicked,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final categoryIdModel =
        Provider.of<CategoryIdChange>(context, listen: false);
    bool isJoined = categoryIdModel.getSelectedCategoryIds().contains(id);
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
            alignment: Alignment.topCenter,
            child: Text(
              idolName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Sizes.size32),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.size16),
            child: GestureDetector(
              onTap: () {
                if (!disableJoin || isJoined) {
                  onJoin(id);
                }
                if (isJoined) {
                  categoryIdModel.setCategoryId(id);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Sizes.size10, horizontal: Sizes.size14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.6)),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: Sizes.size24,
                    fontWeight: FontWeight.w600,
                    color:
                        disableJoin && !isJoined ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
