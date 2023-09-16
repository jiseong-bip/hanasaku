import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';
import 'package:hanasaku/setup/aws_s3.dart';
import 'package:video_player/video_player.dart';

class TokenDisplayWidget extends StatefulWidget {
  const TokenDisplayWidget({super.key});

  @override
  State<TokenDisplayWidget> createState() => _TokenDisplayWidgetState();
}

class _TokenDisplayWidgetState extends State<TokenDisplayWidget> {
  String? _token;
  late Stream<dynamic> logLikeStream;
  late Stream<dynamic> logCommentStream;
  late VideoPlayerController controller;
  final signedParams =
      awsS3Client.buildSignedGetParams(key: "contents/s3test-0916.mp4");
  bool showIndicator = true;
  Timer? hideIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _fetchUid();
    controller = VideoPlayerController.networkUrl(signedParams.uri,
        httpHeaders: signedParams.headers)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  _fetchUid() async {
    final authRepo = AuthenticationRepository();
    final token = await authRepo.getUserUid();
    setState(() {
      _token = token;
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
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: _buildVideoPlayer()),
          ),
        ),
      );
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
            Transform.scale(
              scale: 1, // 조절하려는 크기 비율입니다.
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
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
                              icon: const Icon(Icons.replay_5),
                              onPressed: () {
                                final newPosition = controller.value.position -
                                    const Duration(seconds: 5);
                                controller.seekTo(newPosition);
                              },
                            ),
                            IconButton(
                              icon: controller.value.isPlaying
                                  ? const Icon(Icons.pause)
                                  : const Icon(Icons.play_arrow),
                              onPressed: _handleTap,
                            ),
                            IconButton(
                              icon: const Icon(Icons.forward_5),
                              onPressed: () {
                                final newPosition = controller.value.position +
                                    const Duration(seconds: 5);
                                controller.seekTo(newPosition);
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
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
      // 비디오가 재생 중일 때는 5초 후에 VideoProgressIndicator를 숨깁니다.
      if (hideIndicatorTimer != null && hideIndicatorTimer!.isActive) {
        hideIndicatorTimer!.cancel();
      }

      hideIndicatorTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          showIndicator = false;
        });
      });
    } else {
      // 비디오가 멈춰있을 때는 VideoProgressIndicator를 항상 나타나게 합니다.
      setState(() {
        showIndicator = true;
      });

      // 재생 중이 아닐 때는 기존의 타이머를 취소합니다.
      if (hideIndicatorTimer != null && hideIndicatorTimer!.isActive) {
        hideIndicatorTimer!.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double videoHeight = screenHeight / 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _toggleFullScreen,
          )
        ],
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          height: videoHeight,
          child: _buildVideoPlayer(),
        ),
      ),
    );
  }
}
