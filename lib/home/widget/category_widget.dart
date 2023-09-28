import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';

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

    String buttonText = isJoined ? 'Go' : 'Join';
    if (isJoined && gearIconClicked) {
      buttonText = 'Out';
    }
    return Stack(
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
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(3, 5)),
            ],
          ),
          child: Stack(
            children: [
              if (isJoined)
                Positioned(
                  left: -25,
                  top: 0,
                  bottom: 0,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                      )),
                ),
              Column(
                children: [
                  Align(
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
                            idolName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Sizes.size24),
                          ),
                          Gaps.h5,
                          const Text(
                            'Room',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Sizes.size16 + Sizes.size2),
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
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              top: Sizes.size5, bottom: Sizes.size10, right: Sizes.size5),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: Colors.white,
                    child: null,
                  ),
                ),
                Gaps.h5,
                GestureDetector(
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
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 5)),
                      ],
                    ),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
