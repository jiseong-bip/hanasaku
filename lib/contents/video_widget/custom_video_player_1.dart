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
  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  ValueNotifier<bool> showControls = ValueNotifier<bool>(true);

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
        isPlaying.value = false;
      } else {
        controller.play();
        isPlaying.value = true;
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
              builder: (context) => CustomVideoFullScreen(playerState: this),
              fullscreenDialog: true // 현재 상태를 전달
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
              ValueListenableBuilder<bool>(
                  valueListenable: showControls,
                  builder: (context, showControlsValue, child) {
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: showControlsValue
                          ? Column(
                              children: [
                                VideoProgressIndicator(
                                  controller,
                                  allowScrubbing: true,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.replay_5,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            final newPosition =
                                                controller.value.position -
                                                    const Duration(seconds: 5);
                                            controller.seekTo(newPosition);
                                          },
                                        ),
                                        ValueListenableBuilder<bool>(
                                          valueListenable: isPlaying,
                                          builder:
                                              (context, isPlayingValue, child) {
                                            return IconButton(
                                              icon: isPlayingValue
                                                  ? const Icon(Icons.pause,
                                                      color: Colors.white)
                                                  : const Icon(Icons.play_arrow,
                                                      color: Colors.white),
                                              onPressed: _handleTap,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.forward_5,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            final newPosition =
                                                controller.value.position +
                                                    const Duration(seconds: 5);
                                            controller.seekTo(newPosition);
                                            setState(() {});
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
                            )
                          : const SizedBox.shrink(),
                    );
                  }),
          ],
        ),
      ),
    );
  }

  _handleTap() {
    _togglePlayback();

    showControls.value = true;

    if (controller.value.isPlaying) {
      Future.delayed(const Duration(seconds: 5), () {
        if (controller.value.isPlaying) {
          showControls.value = false;
        }
      });
    } else {
      showControls.value = true;
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
      backgroundColor: Colors.black,
      body: Center(child: playerState._buildVideoPlayer()),
    );
  }
}
