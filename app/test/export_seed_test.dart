import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:msw_community/api.dart';

/// Writes the app's sample data to ../backend/seed.json.
/// Run: flutter test test/export_seed_test.dart
void main() {
  test('export seed for the SQLite backend', () {
    final out = File('../backend/seed.json');
    out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(seedJson()));
    expect(out.existsSync(), true);
  });
}
