// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:buildbucket/buildbucket_pb.dart' as bbv2;
import 'package:googleapis/firestore/v1.dart' hide Status;
import 'package:path/path.dart' as p;

import '../../../cocoon_service.dart';
import '../../request_handling/exceptions.dart';
import '../../service/firestore.dart';
import '../../service/luci_build_service/firestore_task_document_name.dart';
import '../appengine/commit.dart';
import '../appengine/task.dart' as datastore;
import '../ci_yaml/target.dart';

const String kTaskCollectionId = 'tasks';
const int kTaskDefaultTimestampValue = 0;
const int kTaskInitialAttempt = 1;
const String kTaskBringupField = 'bringup';
const String kTaskBuildNumberField = 'buildNumber';
const String kTaskCommitShaField = 'commitSha';
const String kTaskCreateTimestampField = 'createTimestamp';
const String kTaskEndTimestampField = 'endTimestamp';
const String kTaskNameField = 'name';
const String kTaskStartTimestampField = 'startTimestamp';
const String kTaskStatusField = 'status';
const String kTaskTestFlakyField = 'testFlaky';

/// Task Json keys.
const String kTaskAttempts = 'Attempts';
const String kTaskBringup = 'Bringup';
const String kTaskBuildNumber = 'BuildNumber';
const String kTaskCommitSha = 'CommitSha';
const String kTaskCreateTimestamp = 'CreateTimestamp';
const String kTaskDocumentName = 'DocumentName';
const String kTaskEndTimestamp = 'EndTimestamp';
const String kTaskStartTimestamp = 'StartTimestamp';
const String kTaskStatus = 'Status';
const String kTaskTaskName = 'TaskName';
const String kTaskTestFlaky = 'TestFlaky';

class Task extends Document {
  /// Lookup [Task] from Firestore.
  ///
  /// `documentName` follows `/projects/{project}/databases/{database}/documents/{document_path}`
  static Future<Task> fromFirestore(
    FirestoreService firestoreService,
    FirestoreTaskDocumentName documentName,
  ) async {
    final document = await firestoreService.getDocument(
      p.posix.join(
        kDatabase,
        'documents',
        kTaskCollectionId,
        documentName.documentName,
      ),
    );
    return Task.fromDocument(taskDocument: document);
  }

  /// Create [Task] from a task Document.
  static Task fromDocument({required Document taskDocument}) {
    return Task()
      ..fields = taskDocument.fields!
      ..name = taskDocument.name!;
  }

  /// The task was cancelled.
  static const String statusCancelled = 'Cancelled';

  /// The task is yet to be run.
  static const String statusNew = 'New';

  /// The task failed to run due to an unexpected issue.
  static const String statusInfraFailure = 'Infra Failure';

  /// The task is currently running.
  static const String statusInProgress = 'In Progress';

  /// The task was run successfully.
  static const String statusSucceeded = 'Succeeded';

  /// The task failed to run successfully.
  static const String statusFailed = 'Failed';

  /// The task was skipped or canceled while running.
  ///
  /// This status is only used by LUCI tasks.
  static const String statusSkipped = 'Skipped';

  static const Set<String> taskFailStatusSet = <String>{
    Task.statusInfraFailure,
    Task.statusFailed,
    Task.statusCancelled,
  };

  /// The list of legal values for the [status] property.
  static const List<String> legalStatusValues = <String>[
    statusCancelled,
    statusFailed,
    statusInfraFailure,
    statusInProgress,
    statusNew,
    statusSkipped,
    statusSucceeded,
  ];

  static const List<String> finishedStatusValues = <String>[
    statusCancelled,
    statusFailed,
    statusInfraFailure,
    statusSkipped,
    statusSucceeded,
  ];

  /// The timestamp (in milliseconds since the Epoch) that this task was
  /// created.
  ///
  /// This is _not_ when the task first started running, as tasks start out in
  /// the 'New' state until they've been picked up by an [Agent].
  int? get createTimestamp =>
      int.parse(fields![kTaskCreateTimestampField]!.integerValue!);

  /// The timestamp (in milliseconds since the Epoch) that this task started
  /// running.
  ///
  /// Tasks may be run more than once. If this task has been run more than
  /// once, this timestamp represents when the task was most recently started.
  int? get startTimestamp =>
      int.parse(fields![kTaskStartTimestampField]!.integerValue!);

  /// The timestamp (in milliseconds since the Epoch) that this task last
  /// finished running.
  int? get endTimestamp =>
      int.parse(fields![kTaskEndTimestampField]!.integerValue!);

  /// The name of the task.
  ///
  /// This is a human-readable name, typically a test name (e.g.
  /// "hello_world__memory").
  String? get taskName => fields![kTaskNameField]!.stringValue!;

  /// The sha of the task commit.
  String? get commitSha => fields![kTaskCommitShaField]!.stringValue!;

  /// The number of attempts that have been made to run this task successfully.
  ///
  /// New tasks that have not yet been picked up by an [Agent] will have zero
  /// attempts.
  int? get attempts => int.parse(name!.split('_').last);

  /// Whether this task has been marked flaky by .ci.yaml.
  ///
  /// See also:
  ///
  ///  * <https://github.com/flutter/flutter/blob/master/.ci.yaml>
  ///
  /// A flaky (`bringup: true`) task will not block the tree.
  bool? get bringup => fields![kTaskBringupField]!.booleanValue!;

  /// Whether the test execution of this task shows flake.
  ///
  /// Test runner supports rerun, and this flag tracks if a flake happens.
  ///
  /// See also:
  ///  * <https://github.com/flutter/flutter/blob/master/dev/devicelab/lib/framework/runner.dart>
  bool? get testFlaky => fields![kTaskTestFlakyField]!.booleanValue!;

  /// The build number of luci build: https://chromium.googlesource.com/infra/luci/luci-go/+/master/buildbucket/proto/build.proto#146
  int? get buildNumber =>
      fields!.containsKey(kTaskBuildNumberField)
          ? int.parse(fields![kTaskBuildNumberField]!.integerValue!)
          : null;

  /// The status of the task.
  ///
  /// Legal values and their meanings are defined in [legalStatusValues].
  String get status {
    final taskStatus = fields![kTaskStatusField]!.stringValue!;
    if (!legalStatusValues.contains(taskStatus)) {
      throw ArgumentError('Invalid state: "$taskStatus"');
    }
    return taskStatus;
  }

  String setStatus(String value) {
    if (!legalStatusValues.contains(value)) {
      throw ArgumentError('Invalid state: "$value"');
    }
    fields![kTaskStatusField] = Value(stringValue: value);
    return value;
  }

  void setEndTimestamp(int endTimestamp) {
    fields![kTaskEndTimestampField] = Value(
      integerValue: endTimestamp.toString(),
    );
  }

  void setTestFlaky(bool testFlaky) {
    fields![kTaskTestFlakyField] = Value(booleanValue: testFlaky);
  }

  void updateFromBuild(bbv2.Build build) {
    fields![kTaskBuildNumberField] = Value(
      integerValue: build.number.toString(),
    );

    fields![kTaskCreateTimestampField] = Value(
      integerValue:
          build.createTime.toDateTime().millisecondsSinceEpoch.toString(),
    );
    fields![kTaskStartTimestampField] = Value(
      integerValue:
          build.startTime.toDateTime().millisecondsSinceEpoch.toString(),
    );
    fields![kTaskEndTimestampField] = Value(
      integerValue:
          build.endTime.toDateTime().millisecondsSinceEpoch.toString(),
    );

    _setStatusFromLuciStatus(build);
  }

  void resetAsRetry({int attempt = 1}) {
    name =
        '$kDatabase/documents/$kTaskCollectionId/${commitSha}_${taskName}_$attempt';
    fields = <String, Value>{
      kTaskCreateTimestampField: Value(
        integerValue: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
      kTaskEndTimestampField: Value(
        integerValue: kTaskDefaultTimestampValue.toString(),
      ),
      kTaskBringupField: Value(booleanValue: bringup),
      kTaskNameField: Value(stringValue: taskName),
      kTaskStartTimestampField: Value(
        integerValue: kTaskDefaultTimestampValue.toString(),
      ),
      kTaskStatusField: Value(stringValue: Task.statusNew),
      kTaskTestFlakyField: Value(booleanValue: false),
      kTaskCommitShaField: Value(stringValue: commitSha),
    };
  }

  String _setStatusFromLuciStatus(bbv2.Build build) {
    // Updates can come out of order. Ensure completed statuses are kept.
    if (_isStatusCompleted()) {
      return status;
    }

    if (build.status == bbv2.Status.STARTED) {
      return setStatus(statusInProgress);
    } else if (build.status == bbv2.Status.SUCCESS) {
      return setStatus(statusSucceeded);
    } else if (build.status == bbv2.Status.CANCELED) {
      return setStatus(statusCancelled);
    } else if (build.status == bbv2.Status.FAILURE) {
      return setStatus(statusFailed);
    } else if (build.status == bbv2.Status.INFRA_FAILURE) {
      return setStatus(statusInfraFailure);
    } else {
      throw BadRequestException('${build.status} is unknown');
    }
  }

  bool _isStatusCompleted() {
    const completedStatuses = <String>[
      statusCancelled,
      statusFailed,
      statusInfraFailure,
      statusSucceeded,
    ];
    return completedStatuses.contains(status);
  }

  Map<String, dynamic> get facade {
    return <String, dynamic>{
      kTaskDocumentName: name,
      kTaskCommitSha: commitSha,
      kTaskCreateTimestamp: createTimestamp,
      kTaskStartTimestamp: startTimestamp,
      kTaskEndTimestamp: endTimestamp,
      kTaskTaskName: taskName,
      kTaskAttempts: attempts,
      kTaskBringup: bringup,
      kTaskTestFlaky: testFlaky,
      kTaskBuildNumber: buildNumber,
      kTaskStatus: status,
    };
  }

  @override
  String toString() {
    final buf =
        StringBuffer()
          ..write('$runtimeType(')
          ..write('$kTaskBuildNumberField: $buildNumber')
          ..write(', $kTaskCreateTimestampField: $createTimestamp')
          ..write(', $kTaskStartTimestampField: $startTimestamp')
          ..write(', $kTaskEndTimestampField: $endTimestamp')
          ..write(', $kTaskNameField: $name')
          ..write(', $kTaskBringupField: $bringup')
          ..write(', $kTaskTestFlakyField: $testFlaky')
          ..write(', $kTaskStatusField: $status')
          ..write(')');
    return buf.toString();
  }
}

/// Generates task documents based on targets.
List<Task> targetsToTaskDocuments(Commit commit, List<Target> targets) {
  final iterableDocuments = targets.map(
    (Target target) => Task.fromDocument(
      taskDocument: Document(
        name:
            '$kDatabase/documents/$kTaskCollectionId/${commit.sha}_${target.value.name}_$kTaskInitialAttempt',
        fields: <String, Value>{
          kTaskCreateTimestampField: Value(
            integerValue: commit.timestamp!.toString(),
          ),
          kTaskEndTimestampField: Value(
            integerValue: kTaskDefaultTimestampValue.toString(),
          ),
          kTaskBringupField: Value(booleanValue: target.value.bringup),
          kTaskNameField: Value(stringValue: target.value.name),
          kTaskStartTimestampField: Value(
            integerValue: kTaskDefaultTimestampValue.toString(),
          ),
          kTaskStatusField: Value(stringValue: Task.statusNew),
          kTaskTestFlakyField: Value(booleanValue: false),
          kTaskCommitShaField: Value(stringValue: commit.sha),
        },
      ),
    ),
  );
  return iterableDocuments.toList();
}

/// Generates task document based on datastore task data model.
Task taskToDocument(datastore.Task task) {
  final commitSha = task.commitKey!.id!.split('/').last;
  return Task.fromDocument(
    taskDocument: Document(
      name:
          '$kDatabase/documents/$kTaskCollectionId/${commitSha}_${task.name}_${task.attempts}',
      fields: <String, Value>{
        kTaskCreateTimestampField: Value(
          integerValue: task.createTimestamp.toString(),
        ),
        kTaskEndTimestampField: Value(
          integerValue: task.endTimestamp.toString(),
        ),
        kTaskBringupField: Value(booleanValue: task.isFlaky),
        kTaskNameField: Value(stringValue: task.name),
        kTaskStartTimestampField: Value(
          integerValue: task.startTimestamp.toString(),
        ),
        kTaskStatusField: Value(stringValue: task.status),
        kTaskTestFlakyField: Value(booleanValue: task.isTestFlaky),
        kTaskCommitShaField: Value(stringValue: commitSha),
      },
    ),
  );
}
