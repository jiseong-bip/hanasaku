import 'package:flutter/material.dart';

import 'package:hanasaku/home/detail_screen.dart';

class TokenDisplayWidget extends StatefulWidget {
  const TokenDisplayWidget({super.key});

  @override
  State<TokenDisplayWidget> createState() => _TokenDisplayWidgetState();
}

class _TokenDisplayWidgetState extends State<TokenDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: DetailScreen(
      postId: 1,
      isContent: true,
      videoKey: 'contents/s3test-0916.mp4',
    ));
  }
}
