import 'package:flutter/material.dart';
import 'package:hanasaku/contents_tab/video_widget/src/controller/video_controller.dart';
import 'package:hanasaku/contents_tab/video_widget/src/util/enum.dart';
import 'package:hanasaku/contents_tab/video_widget/src/view/video_player_widget.dart';

/// 전체화면 위젯
class FullScreenVideoWidget extends StatefulWidget {
  const FullScreenVideoWidget(
      {Key? key,
      required this.videoUrl,
      required this.aspectRatio,
      required this.httpHeader})
      : super(key: key);

  final Uri videoUrl;
  final Map<String, String> httpHeader;
  final double aspectRatio;

  @override
  _FullScreenVideoWidgetState createState() => _FullScreenVideoWidgetState();
}

class _FullScreenVideoWidgetState extends State<FullScreenVideoWidget>
    with SingleTickerProviderStateMixin {
  late CustomVideoController _controller;

  @override
  void initState() {
    _controller = CustomVideoController(
        videoUrl: widget.videoUrl,
        muteSound: false,
        isLooping: false,
        autoPlay: false,
        aspectRatio: 1 / widget.aspectRatio,
        httpHeader: widget.httpHeader);

    super.initState();
  }

  @override
  void dispose() async {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: Future.delayed(
          const Duration(milliseconds: 500),
        ),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RotatedBox(
              quarterTurns: 1,
              child: VideoPlayerWidget(
                videoController: _controller,
                videoOption: VideoOption.full,
                isFullScreen: true,
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
