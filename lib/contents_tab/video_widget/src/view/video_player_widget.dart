import 'package:flutter/material.dart';
import 'package:hanasaku/contents_tab/video_widget/src/controller/video_controller.dart';
import 'package:hanasaku/contents_tab/video_widget/src/util/enum.dart';
import 'package:hanasaku/contents_tab/video_widget/src/util/extension.dart';
import 'package:hanasaku/contents_tab/video_widget/src/view/full_screen_video.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget(
      {Key? key,
      required this.videoController,
      this.videoOption = VideoOption.none,
      this.isFullScreen = false,
      this.placeHolder,
      this.widgetSize})
      : super(key: key);

  final CustomVideoController videoController;
  final VideoOption videoOption;
  final bool isFullScreen;
  final Widget? placeHolder;
  final Size? widgetSize;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  /// video controller
  late CustomVideoController _controller;

  /// 플레이/일시정지 상태변경
  ValueNotifier<PlayerButtonState>? _playButtonNotifier;

  /// 볼륨 상태 변경 true = mute
  ValueNotifier<bool>? _volumeNotifier;

  /// indicator, 시간 갱신
  ValueNotifier<Duration>? _timelineNotifier;

  // ValueNotifier<bool>? _visibilityNotifier;

  late Size _size;

  @override
  void initState() {
    super.initState();
    _controller = widget.videoController;

    // timeline 처리
    if (widget.videoOption == VideoOption.full ||
        widget.videoOption == VideoOption.bottomBarOnly) {
      _volumeNotifier = ValueNotifier(_controller.muteSound);
      _timelineNotifier = ValueNotifier(Duration.zero);
      // _visibilityNotifier = ValueNotifier(true);
    }

    // play/stop 토글
    if (widget.videoOption != VideoOption.none) {
      _playButtonNotifier = ValueNotifier(PlayerButtonState.stopped);

      _controller.addListener(_listener);
    }
  }

  /// timeline slider, text 업데이트용
  void _listener() {
    _timelineNotifier!.value = _controller.getVideoValue.position;

    if (!_controller.isLooping &&
        !_controller.getVideoValue.isPlaying &&
        _controller.getVideoValue.position ==
            _controller.getVideoValue.duration) {
      _playButtonNotifier!.value = PlayerButtonState.stopped;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _playButtonNotifier?.dispose();
    _volumeNotifier?.dispose();
    _timelineNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.videoStateNotifier,
      builder: (_, isLoaded, __) {
        return _videoOptionWidget(isLoaded);
      },
    );
  }

  /// video player부분
  Widget _videoWidget(bool isLoaded) {
    _size = widget.widgetSize ?? MediaQuery.of(context).size;

    return isLoaded
        ? widget.isFullScreen
            ? AspectRatio(
                aspectRatio: _controller.aspectRatio,
                child: VideoPlayer(_controller.videoController),
              )
            : SizedBox(
                height: _size.height,
                width: _size.width,
                child: AspectRatio(
                  aspectRatio: _controller.aspectRatio,
                  child: VideoPlayer(_controller.videoController),
                ),
              )
        : (widget.placeHolder ?? Container());
  }

  /// 선택된 옵션에 따라 widget변경
  Widget _videoOptionWidget(bool isLoaded) {
    switch (widget.videoOption) {
      case VideoOption.none:
        return _videoWidget(isLoaded);
      case VideoOption.centerButtonOnly:
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            _videoWidget(isLoaded),
            _toggleButton(),
          ],
        );
      case VideoOption.bottomBarOnly:
        return Column(
          children: [
            _videoWidget(isLoaded),
            Align(
              alignment: Alignment.bottomCenter,
              child: _bottomBar(),
            ),
          ],
        );
      case VideoOption.full:
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            _videoWidget(isLoaded),
            _toggleButton(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _bottomBar(),
            ),
          ],
        );
    }
  }

  /// 재생/정지 토글 버튼 bottomBar, center button에 사용
  Widget _toggleButton({bool isBottomButton = false, double iconSize = 30}) {
    return ValueListenableBuilder<PlayerButtonState>(
        valueListenable: _playButtonNotifier!,
        builder: (_, state, __) {
          switch (state) {
            case PlayerButtonState.stopped:
              return IconButton(
                iconSize: iconSize,
                icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  await _controller.playVideo();
                  _playButtonNotifier!.value = PlayerButtonState.playing;
                },
              );
            case PlayerButtonState.playing:
              // 하단부분에 들어가는 정지 버튼
              if (isBottomButton) {
                return IconButton(
                  iconSize: iconSize,
                  icon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    await _controller.pauseVideo();
                    _playButtonNotifier!.value = PlayerButtonState.paused;
                  },
                );
              }

              return Center(
                child: InkWell(
                  radius: 20,
                  onTap: () async {
                    await _controller.pauseVideo();
                    _playButtonNotifier!.value = PlayerButtonState.paused;
                  },
                ),
              );
            case PlayerButtonState.paused:
              return IconButton(
                iconSize: iconSize,
                icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  await _controller.playVideo();
                  _playButtonNotifier!.value = PlayerButtonState.playing;
                },
              );
          }
        });
  }

  /// 동영상 플레이 indicator/ (재생/정지) / 사운드/뮤트 / 확대축소
  Widget _bottomBar() {
    return SizedBox(
      width: _size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ValueListenableBuilder<Duration>(
              valueListenable: _timelineNotifier!,
              builder: (_, duration, __) {
                return Transform.translate(
                  offset: const Offset(0, 30),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(trackHeight: 2),
                    child: Slider(
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.black54,
                      min: 0.0,
                      max: 1.0,
                      value: (duration.inMilliseconds /
                                  _controller
                                      .getVideoValue.duration.inMilliseconds) <
                              1.0
                          ? (duration.inMilliseconds /
                              _controller.getVideoValue.duration.inMilliseconds)
                          : 0.0,
                      onChanged: (value) {
                        double touchedPosition = value *
                            _controller.getVideoValue.duration.inMilliseconds;

                        _controller.seekTo(
                            Duration(milliseconds: touchedPosition.round()));
                      },
                    ),
                  ),
                );
              }),
          Row(
            children: [
              _toggleButton(isBottomButton: true, iconSize: 14),
              Expanded(
                child: ValueListenableBuilder<Duration>(
                    valueListenable: _timelineNotifier!,
                    builder: (_, duration, __) {
                      return Text(
                        duration.getTime,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      );
                    }),
              ),
              IconButton(
                onPressed: () async {
                  await _controller
                      .setVolume(_volumeNotifier!.value ? 1.0 : 0.0);
                  _volumeNotifier!.value = !_volumeNotifier!.value;
                },
                icon: ValueListenableBuilder<bool>(
                    valueListenable: _volumeNotifier!,
                    builder: (_, isMute, __) {
                      return Icon(
                        isMute
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 14,
                      );
                    }),
              ),
              IconButton(
                onPressed: () async {
                  if (widget.isFullScreen) {
                    Navigator.pop(context);
                  } else {
                    await _controller.pauseVideo();
                    _playButtonNotifier!.value = PlayerButtonState.paused;

                    Navigator.push(
                      context,
                      expandVideoRoute(
                        pushPage: FullScreenVideoWidget(
                          videoUrl: _controller.videoUrl,
                          aspectRatio: MediaQuery.of(context).size.aspectRatio,
                          httpHeader: _controller.httpHeader,
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(
                  widget.isFullScreen
                      ? Icons.close_fullscreen_rounded
                      : Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Route expandVideoRoute({required Widget pushPage}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => pushPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(
            begin: -0.05,
            end: 0.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
