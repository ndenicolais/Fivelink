import 'dart:io';

import 'package:fivelink/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppInfo version matches pubspec.yaml', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final RegExpMatch? match = RegExp(
      r'^version:\s*(\S+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'version: x.y.z+n not found');
    expect(
      '${AppInfo.version}+${AppInfo.buildNumber}',
      '${match![1]}+${match[2]}',
      reason: 'update AppInfo when bumping the version in pubspec.yaml',
    );
  });
}
