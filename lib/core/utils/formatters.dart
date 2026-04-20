import 'package:intl/intl.dart';

final _won = NumberFormat.decimalPattern('ko_KR');

String formatPriceWon(int won) => '${_won.format(won)}원';

String formatPlaytime(int minutes) {
  if (minutes <= 0) return '-';
  if (minutes < 60) return '${minutes}분';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '${h}시간';
  return '${h}시간 ${m}분';
}

String formatScore(double score) => score.toStringAsFixed(1);
