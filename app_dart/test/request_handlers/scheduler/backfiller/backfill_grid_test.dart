// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cocoon_server_test/test_logging.dart';
import 'package:cocoon_service/src/request_handlers/scheduler/backfill_grid.dart';
import 'package:cocoon_service/src/service/luci_build_service/opaque_commit.dart';
import 'package:test/test.dart';

import '../../../src/utilities/entity_generators.dart';
import 'backfill_matcher.dart';

void main() {
  useTestLoggerPerTest();

  test('createBackfillTask', () async {
    final commit = OpaqueCommit.fromFirestore(generateFirestoreCommit(1));
    final task = OpaqueTask.fromFirestore(
      generateFirestoreTask(2, commitSha: commit.sha),
    );
    final target = generateTarget(1, name: task.name);

    final grid = BackfillGrid.from(
      [
        (commit, [task]),
      ],
      tipOfTreeTargets: [target],
    );

    expect(
      grid.createBackfillTask(task, priority: 1001),
      isBackfillTask
          .hasTask(task)
          .hasTarget(target)
          .hasCommit(commit)
          .hasPriority(1001),
    );
  });

  test('columns', () {
    final c1 = OpaqueCommit.fromFirestore(generateFirestoreCommit(1));
    final c2 = OpaqueCommit.fromFirestore(generateFirestoreCommit(2));
    final t1c1 = OpaqueTask.fromFirestore(
      generateFirestoreTask(1, commitSha: c1.sha),
    );
    final t1c2 = OpaqueTask.fromFirestore(
      generateFirestoreTask(1, commitSha: c2.sha),
    );
    final t2c1 = OpaqueTask.fromFirestore(
      generateFirestoreTask(2, commitSha: c1.sha),
    );
    final t2c2 = OpaqueTask.fromFirestore(
      generateFirestoreTask(2, commitSha: c2.sha),
    );
    final tg1 = generateTarget(1, name: t1c1.name);
    final tg2 = generateTarget(2, name: t2c1.name);
    final grid = BackfillGrid.from(
      [
        (c1, [t1c1, t2c1]),
        (c2, [t1c2, t2c2]),
      ],
      tipOfTreeTargets: [tg1, tg2],
    );

    expect(grid.columns, [
      [t1c1, t1c2],
      [t2c1, t2c2],
    ]);
  });

  test('filters out tasks that are missing from ToT', () {
    final commit = OpaqueCommit.fromFirestore(generateFirestoreCommit(1));
    final taskExists = OpaqueTask.fromFirestore(
      generateFirestoreTask(1, commitSha: commit.sha),
    );
    final taskMissing = OpaqueTask.fromFirestore(
      generateFirestoreTask(2, commitSha: commit.sha),
    );
    final targetExists = generateTarget(1, name: taskExists.name);

    final grid = BackfillGrid.from(
      [
        (commit, [taskExists, taskMissing]),
      ],
      tipOfTreeTargets: [targetExists],
    );

    expect(grid.columns, [
      [taskExists],
    ]);
  });

  test('getTargetFor', () {
    final commit = OpaqueCommit.fromFirestore(generateFirestoreCommit(1));
    final task = OpaqueTask.fromFirestore(
      generateFirestoreTask(2, commitSha: commit.sha),
    );
    final target = generateTarget(1, name: task.name);

    final grid = BackfillGrid.from(
      [
        (commit, [task]),
      ],
      tipOfTreeTargets: [target],
    );

    expect(grid.getTargetFor(task), target);
  });
}
