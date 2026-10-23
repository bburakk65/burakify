/// 3:07 veya 1:02:03 biçiminde süre yazar.
String formatDuration(Duration d) {
  final int totalSeconds = d.inSeconds < 0 ? 0 : d.inSeconds;
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int seconds = totalSeconds % 60;
  final String ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    final String mm = minutes.toString().padLeft(2, '0');
    return '$hours:$mm:$ss';
  }
  return '$minutes:$ss';
}
