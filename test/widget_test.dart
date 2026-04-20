import 'package:flutter_test/flutter_test.dart';

import 'package:room_search/core/utils/formatters.dart';

void main() {
  test('formatPriceWon adds 원 and thousands separator', () {
    expect(formatPriceWon(28000), '28,000원');
  });

  test('formatPlaytime renders hours+minutes', () {
    expect(formatPlaytime(75), '1시간 15분');
    expect(formatPlaytime(45), '45분');
    expect(formatPlaytime(120), '2시간');
  });
}
