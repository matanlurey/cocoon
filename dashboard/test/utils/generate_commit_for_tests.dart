// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fixnum/fixnum.dart';
import 'package:flutter_dashboard/model/commit.pb.dart';

import 'generate_task_for_tests.dart' show utc$2020_9_1_12_30;
export 'generate_task_for_tests.dart' show utc$2020_9_1_12_30;

/// Generates a [Commit] for use in a test fixture.
Commit generateCommitForTest({
  DateTime? timestamp,
  String author = 'author',
  String avatarUrl = '',
  String sha = 'abc123',
  String branch = 'master',
  String message = 'Commit message',
  String repository = 'flutter/flutter',
}) {
  timestamp ??= utc$2020_9_1_12_30;
  return Commit(
    timestamp: Int64(timestamp.millisecondsSinceEpoch),
    sha: sha,
    author: author,
    authorAvatarUrl: avatarUrl,
    branch: branch,
    message: message,
    repository: repository,
  );
}
