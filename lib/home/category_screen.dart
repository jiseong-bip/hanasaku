import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.gear))
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            CategoryWidget(
              left: 'assets/idol/bts.jpeg',
              right: 'assets/idol/blackpink.jpeg',
              lId: 1,
              rId: 2,
            ),
            CategoryWidget(
              left: 'assets/idol/twice.jpeg',
              right: 'assets/idol/asepa.jpeg',
              lId: 3,
              rId: 4,
            ),
            CategoryWidget(
              left: 'assets/idol/enhypen.jpeg',
              right: 'assets/idol/exo.jpeg',
              lId: 5,
              rId: 6,
            ),
            CategoryWidget(
              left: 'assets/idol/idle.jpeg',
              right: 'assets/idol/itzy.jpeg',
              lId: 7,
              rId: 8,
            ),
            CategoryWidget(
              left: 'assets/idol/ive.jpeg',
              right: 'assets/idol/kepler.jpeg',
              lId: 9,
              rId: 10,
            ),
            CategoryWidget(
              left: 'assets/idol/newjeans.jpeg',
              right: 'assets/idol/nmix.jpeg',
              lId: 11,
              rId: 12,
            ),
            CategoryWidget(
              left: 'assets/idol/nct.jpeg',
              right: 'assets/idol/lesserafim.jpeg',
              lId: 13,
              rId: 14,
            ),
            CategoryWidget(
              left: 'assets/idol/redvelvet.jpeg',
              right: 'assets/idol/strayKids.jpeg',
              lId: 15,
              rId: 16,
            ),
            CategoryWidget(
              left: 'assets/idol/toxto.jpeg',
              right: 'assets/idol/treasure.jpeg',
              lId: 17,
              rId: 18,
            ),
            CategoryWidget(
              left: 'assets/idol/seventeen.jpeg',
              right: 'assets/idol/zerobaseone.jpeg',
              lId: 19,
              rId: 20,
            ),
            Gaps.v28,
          ],
        ),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final String left, right;
  final int lId, rId;
  const CategoryWidget({
    super.key,
    required this.left,
    required this.right,
    required this.lId,
    required this.rId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Sizes.size10, horizontal: Sizes.size10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                width: 180,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  left,
                ),
              ),
              Gaps.v12,
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 0.6, color: Colors.grey.shade600)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size20,
                    vertical: Sizes.size5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(lId);
                    },
                    child: const Text(
                      '입장하기',
                      style: TextStyle(
                          fontSize: Sizes.size16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: 180,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  right,
                  width: 180,
                  height: 100,
                ),
              ),
              Gaps.v12,
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 0.6, color: Colors.grey.shade600)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size20,
                    vertical: Sizes.size5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(rId);
                    },
                    child: const Text(
                      '입장하기',
                      style: TextStyle(
                          fontSize: Sizes.size16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
