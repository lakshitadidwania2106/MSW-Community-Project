import 'package:flutter_test/flutter_test.dart';
import 'package:msw_community/data.dart';

void main() {
  test('30 days of reels and 5 portals', () {
    expect(reelTopics.length, 30);
    expect(roles.length, 5);
  });
}
