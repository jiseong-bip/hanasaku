import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoController {
  /// video 관련된 모든 동작을 가진녀석(?)
  late VideoPlayerController videoController;

  final Map<String, String> httpHeader;

  /// 동영상 url
  final Uri videoUrl;

  /// true일 때 음소거
  final bool muteSound;

  /// true일 때 연속재생
  final bool isLooping;

  /// true일 때 자동재생
  final bool autoPlay;

  /// 동영상 비율
  final double aspectRatio;

  CustomVideoController({
    required this.httpHeader,
    required this.videoUrl,
    required this.aspectRatio,
    this.muteSound = false,
    this.isLooping = false,
    this.autoPlay = false,
  }) {
    // 처음에 스냅샷 이미지 보여주기 용도
    videoStateNotifier = ValueNotifier(false);

    // auto play 처리부분
    initVideoController().whenComplete(() {
      if (autoPlay) {
        playVideo();
      }
    });
  }

  /// video loading후 상태변경 용도로 사용
  late ValueNotifier<bool> videoStateNotifier;

  /// video 관련 값들, ex: duration(동영상 전체 길이), position(현재 위치)
  VideoPlayerValue get getVideoValue => videoController.value;

  /// video controller 초기화 로직
  /// videoStateNotifier가 true가 되는순간 스냅샷이미지에서 동영상으로 변신
  Future<void> initVideoController() async {
    videoController = VideoPlayerController.networkUrl(videoUrl,
        httpHeaders: httpHeader,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

    await videoController.setVolume(muteSound ? 0.0 : 1.0);
    await videoController.setLooping(isLooping);

    await videoController.initialize();

    videoStateNotifier.value = getVideoValue.isInitialized;

    debugPrint('[video] init done : ${videoStateNotifier.value}');
  }

  /// 비디오 실행 일시정지 이후 재생 시 이전 위치에서 실행
  Future<void> playVideo() async {
    // video가 실행중인지 체크
    if (!(getVideoValue.isPlaying)) {
      if (getVideoValue.position == Duration.zero) {
        await videoController.play();
      } else {
        await seekTo(getVideoValue.position);
      }
    }
  }

  /// 비디오 정지
  Future<void> pauseVideo() async {
    await videoController.pause();
  }

  /// 특정 위치에서 시작
  Future<void> seekTo(Duration duration) async {
    await videoController.seekTo(duration);
  }

  /// from 0.0(음소거) to 1.0
  Future<void> setVolume(double volume) async {
    await videoController.setVolume(volume);
  }

  /// controller 초기화
  Future<void> dispose() async {
    await videoController.dispose();
    videoStateNotifier.dispose();
  }

  /// full mode일때만 사용
  /// timeline 업데이트에 사용
  void addListener(Function() listener) {
    videoController.addListener(listener);
  }

  /// dispose에 사용 필요
  void removeListener(Function() listener) {
    videoController.removeListener(listener);
  }
}
