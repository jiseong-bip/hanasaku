import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanasaku/setup/aws_s3.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoKey;
  const CustomVideoPlayer({Key? key, required this.videoKey}) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController controller;

  bool showIndicator = true;
  Timer? hideIndicatorTimer;

  @override
  void initState() {
    super.initState();

    final signedParams = awsS3Client.buildSignedGetParams(key: widget.videoKey);
    controller = VideoPlayerController.networkUrl(signedParams.uri,
        httpHeaders: signedParams.headers)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    hideIndicatorTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  void _toggleFullScreen() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // 가로 모드로 화면 방향 변경
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight])
          .then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CustomVideoFullScreen(playerState: this), // 현재 상태를 전달
          ),
        ).then((_) {
          // 전체 화면 모드를 종료하면 세로 모드로 다시 변경
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        });
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _handleTap,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            VideoPlayer(controller),
            if (showIndicator)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.replay_5,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final newPosition = controller.value.position -
                                    const Duration(seconds: 5);
                                controller.seekTo(newPosition);
                              },
                            ),
                            IconButton(
                              icon: controller.value.isPlaying
                                  ? const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                              onPressed: _handleTap,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.forward_5,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final newPosition = controller.value.position +
                                    const Duration(seconds: 5);
                                controller.seekTo(newPosition);
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  _handleTap() {
    _togglePlayback();

    if (controller.value.isPlaying) {
      if (hideIndicatorTimer != null && hideIndicatorTimer!.isActive) {
        hideIndicatorTimer!.cancel();
      }

      hideIndicatorTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          showIndicator = false;
        });
      });
    } else {
      setState(() {
        showIndicator = true;
      });

      if (hideIndicatorTimer != null && hideIndicatorTimer!.isActive) {
        hideIndicatorTimer!.cancel();
      }
    }
  }

  Widget getVideoPlayerWidget(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: _buildVideoPlayer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoPlayer();
  }
}

class CustomVideoFullScreen extends StatelessWidget {
  final _CustomVideoPlayerState playerState;

  const CustomVideoFullScreen({super.key, required this.playerState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: playerState._buildVideoPlayer()),
    );
  }
}
