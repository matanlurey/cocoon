// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as p;

const double _kGoldenDiffTolerance = 0.005;

/// Wrapper function for golden tests in Cocoon.
///
/// Ensures tests are only run on linux for consistency, and golden files are
/// stored in a goldens directory that is separate from the code.
Future<void> expectGoldenMatches(
  dynamic actual,
  String goldenFileKey, {
  String? reason,
  Object? skip = false, // true or a String
}) {
  final goldenPath = path.join('goldens', goldenFileKey);
  goldenFileComparator = CocoonFileComparator(
    path.join(
      (goldenFileComparator as LocalFileComparator).basedir.toString(),
      goldenFileKey,
    ),
  );
  return expectLater(
    actual,
    matchesGoldenFile(goldenPath),
    reason: reason,
    skip: skip is String || skip == true || kIsWeb || !Platform.isLinux,
  );
}

class CocoonFileComparator extends LocalFileComparator {
  CocoonFileComparator(String testFile) : super(Uri.parse(testFile));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent > _kGoldenDiffTolerance) {
      final error = await generateFailureOutput(result, golden, basedir);
      if (!kIsWeb && Platform.environment.containsKey('LUCI_CONTEXT')) {
        stderr.writeln(
          '${p.join(basedir.toFilePath(), golden.toFilePath())} has failed. '
          'For your convenience CI provides it as a base64 encoded image below. #[IMAGE]:',
        );
        stderr.writeln(base64Encode(imageBytes));
        stderr.writeln('#[/IMAGE]');
      }
      throw FlutterError(error);
    }
    if (!result.passed && !kIsWeb) {
      stderr.writeln(
        'A tolerable difference of ${result.diffPercent * 100}% was found when '
        'comparing $golden.',
      );
    }
    return result.passed || result.diffPercent <= _kGoldenDiffTolerance;
  }
}
