// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_dashboard/logic/qualified_task.dart';
import 'package:flutter_dashboard/model/task.pb.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QualifiedTask.sourceConfigurationUrl for luci', () {
    final luciTask = Task()..builderName = 'abc';

    expect(
      QualifiedTask.fromTask(luciTask).sourceConfigurationUrl,
      Uri.parse(
        'https://ci.chromium.org/p/flutter/builders/luci.flutter.prod/abc',
      ),
    );
  });

  test('QualifiedTask.sourceConfigurationUrl for dart-internal', () {
    final dartInternalTask = Task(builderName: 'Linux flutter_release_builder');

    expect(
      QualifiedTask.fromTask(dartInternalTask).sourceConfigurationUrl,
      Uri.parse(
        'https://ci.chromium.org/p/dart-internal/builders/luci.flutter.prod/Linux%20flutter_release_builder',
      ),
    );
  });

  test('QualifiedTask.isLuci', () {
    expect(const QualifiedTask(pool: 'pool', task: 'Linux abc').isLuci, true);
    expect(
      const QualifiedTask(
        pool: 'pool',
        task: 'Linux flutter_release_builder',
      ).isLuci,
      false,
    );
  });
}
