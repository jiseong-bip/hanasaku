/// Duration 시간변환 유틸
extension DurationToTime on Duration {
  String get getTime {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    if (inHours == 0) {
      return '$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return "${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}