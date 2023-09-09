import 'package:flutter/material.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

class RecommentWidget extends StatefulWidget {
  const RecommentWidget({
    super.key,
    required List<dynamic> posts,
  }) : _posts = posts;

  final List<dynamic> _posts;

  @override
  State<RecommentWidget> createState() => _RecommentWidgetState();
}

class _RecommentWidgetState extends State<RecommentWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget._posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size16),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size10, vertical: Sizes.size10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      child: Text(
                        widget._posts[index]['user']['userName'],
                        style: TextStyle(
                          fontSize: Sizes.size10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Gaps.h10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget._posts[index]['user']['userName'],
                          style: const TextStyle(
                            fontSize: Sizes.size14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget._posts[index]['comment']}',
                          style: const TextStyle(
                            fontSize: Sizes.size16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
