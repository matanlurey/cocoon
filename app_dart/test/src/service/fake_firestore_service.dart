// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:cocoon_service/src/model/firestore/commit.dart';
import 'package:cocoon_service/src/model/firestore/github_build_status.dart';
import 'package:cocoon_service/src/model/firestore/github_gold_status.dart';
import 'package:cocoon_service/src/model/firestore/task.dart';
import 'package:cocoon_service/src/service/config.dart';
import 'package:cocoon_service/src/service/firestore.dart';
import 'package:github/src/common/model/repos.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../utilities/mocks.dart';

mixin _FakeInMemoryFirestoreService implements FirestoreService {
  /// Every document currently stored in the fake.
  Iterable<Document> get documents => _documents.values;
  final _documents = <String, Document>{};

  @protected
  String get expectedProjectId => Config.flutterGcpProjectId;

  @protected
  String get expectedDatabaseId => Config.flutterGcpFirestoreDatabase;

  void _assertExpectedDatabase(String database) {
    final parts = p.posix.split(database);
    if (parts.length != 4) {
      fail('Unexpected database: "$database"');
    }
    final [pLiteral, pName, dLiteral, dName] = parts;
    if (pLiteral != 'projects' || dLiteral != 'databases') {
      fail('Unexpected database: "$database"');
    }
    if (pName != expectedProjectId || dName != expectedDatabaseId) {
      fail('Unexpected database: "$database"');
    }
  }

  final _random = Random();
  String _generateUniqueId() {
    const length = 20;
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        'abcdefghijklmnopqrstuvwxyz'
        '0123456789';
    final buffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      final randomIndex = _random.nextInt(chars.length);
      buffer.write(chars[randomIndex]);
    }

    final result = buffer.toString();
    if (_documents.containsKey(result)) {
      return _generateUniqueId();
    }

    return result;
  }

  DateTime _now() => DateTime.now();

  /// Returns the document specified by [documentName].
  ///
  /// If the document does not exist, returns `null`.
  Document? tryPeekDocument(String documentName) => _documents[documentName];

  /// Returns the document that ends with [relativePath].
  ///
  /// The document must exist.
  Document peekDocumentByPath(String relativePath) {
    final documentName = p.posix.join(
      'projects',
      expectedProjectId,
      'databases',
      expectedDatabaseId,
      'documents',
      relativePath,
    );
    final existingDocument = tryPeekDocument(documentName);
    if (existingDocument == null) {
      fail('No document "$documentName" found');
    }
    return existingDocument;
  }

  /// Stores a [document].
  ///
  /// Note that this method bypasses normal database conventions, and is
  /// intended to represent changes to the database that happen _before_ a test
  /// runs, or as a side-effect not covered in a test.
  ///
  /// Either [Document.name] or [name] must be set, or this method fails.
  ///
  /// If [created] is set, it is used, otherwise [DateTime.now] is used for
  /// a new document, and the _prevous_ [Document.createTime] is used for a
  /// pre-existing document.
  ///
  /// If [updated] is set, it is used, otherwise [DateTime.now] is used.
  ///
  /// Returns `true` if a new document was inserted, and `false` if updated.
  bool putDocument(
    Document document, {
    String? name,
    DateTime? created,
    DateTime? updated,
  }) {
    name ??= document.name;
    if (name == null) {
      throw ArgumentError.value(document, 'document', 'name must be set');
    }
    if (_failOnWrite[name] case final exception?) {
      throw exception;
    }
    final existing = tryPeekDocument(name);
    if (existing == null) {
      _documents[name] = Document(
        name: name,
        fields: {...?document.fields},
        createTime: (created ?? _now()).toUtc().toIso8601String(),
        updateTime: (updated ?? _now()).toUtc().toIso8601String(),
      );
      return true;
    }
    _documents[name] = Document(
      name: name,
      fields: {...?document.fields},
      createTime: created?.toUtc().toIso8601String() ?? existing.createTime,
      updateTime: (updated ?? _now()).toUtc().toIso8601String(),
    );
    return false;
  }

  final _failOnWrite = <String, Exception>{};

  /// Instructs the fake to throw an exception if [document] is written.
  void failOnWrite(Document document, [DetailedApiRequestError? exception]) {
    if (document.name == null) {
      fail('Missing "name" field');
    }
    _failOnWrite[document.name!] =
        exception ??
        DetailedApiRequestError(500, 'Used failOnWrite(${document.name})');
  }

  @override
  Future<BatchWriteResponse> batchWriteDocuments(
    BatchWriteRequest request,
    String database,
  ) async {
    _assertExpectedDatabase(database);
    // See https://github.com/googleapis/googleapis/blob/6d0c44aecd4c2ddc29703605215e74898e8967f8/google/rpc/code.proto#L32.
    final response = <Status>[];
    for (final write in request.writes ?? const <Write>[]) {
      final document = write.update;
      if (document == null) {
        response.add(Status(code: 3, message: 'Missing "update" field'));
        continue;
      }
      switch (write.currentDocument) {
        // Must find an existing document to update.
        case final p? when p.exists == true:
          final name = document.name;
          if (name == null) {
            response.add(Status(code: 3, message: 'Missing "name" field'));
            continue;
          }
          final existing = tryPeekDocument(name);
          if (existing == null) {
            response.add(Status(code: 9, message: '"$name" does not exist'));
            continue;
          }
          putDocument(document);

        // Must not find an existing document and insert.
        case final p? when p.exists == false:
          final name = document.name ?? _generateUniqueId();
          if (tryPeekDocument(name) != null) {
            response.add(Status(code: 9, message: '"$name" already exists'));
            continue;
          }
          putDocument(document, name: name);

        // Upsert: update if existing and insert if missing.
        default:
          final name = document.name ?? _generateUniqueId();
          putDocument(document, name: name);
      }
      response.add(Status(code: 0));
    }
    return BatchWriteResponse(status: response);
  }
}

/// A partial fake implementation of [FirestoreService].
///
/// For methods that are implemented by [_FakeInMemoryFirestoreService],
/// operates as an in-memory fake, with writes/reads flowing through the API,
/// which is an in-memory database simulation.
///
/// For other methods, they delegate to [mock], which can be manipulated at
/// test runtime similar to any other mock (i.e. `when(firestore.mock)`).
///
/// The awkwardness will be removed after
/// https://github.com/flutter/flutter/issues/165931.
final class FakeFirestoreService
    with _FakeInMemoryFirestoreService
    implements FirestoreService {
  /// A mock [FirestoreService] for legacy methods that don't faked-out APIs.
  final mock = MockFirestoreService();

  @override
  Future<ProjectsDatabasesDocumentsResource> documentResource() {
    return mock.documentResource();
  }

  @override
  List<Document> documentsFromQueryResponse(
    List<RunQueryResponseElement> runQueryResponseElements,
  ) {
    return mock.documentsFromQueryResponse(runQueryResponseElements);
  }

  @override
  Filter generateFilter(
    Map<String, Object> filterMap,
    String compositeFilterOp,
  ) {
    return mock.generateFilter(filterMap, compositeFilterOp);
  }

  @override
  List<Order>? generateOrders(Map<String, String>? orderMap) {
    return mock.generateOrders(orderMap);
  }

  @override
  Future<Document> getDocument(String name) {
    return mock.getDocument(name);
  }

  @override
  Value getValueFromFilter(Object comparisonOject) {
    return mock.getValueFromFilter(comparisonOject);
  }

  @override
  Future<List<Document>> query(
    String collectionId,
    Map<String, Object> filterMap, {
    int? limit,
    Map<String, String>? orderMap,
    String compositeFilterOp = kCompositeFilterOpAnd,
  }) {
    return mock.query(
      collectionId,
      filterMap,
      limit: limit,
      orderMap: orderMap,
      compositeFilterOp: compositeFilterOp,
    );
  }

  @override
  Future<List<Task>> queryCommitTasks(String commitSha) {
    return mock.queryCommitTasks(commitSha);
  }

  @override
  Future<GithubBuildStatus> queryLastBuildStatus(
    RepositorySlug slug,
    int prNumber,
    String head,
  ) {
    return mock.queryLastBuildStatus(slug, prNumber, head);
  }

  @override
  Future<GithubGoldStatus> queryLastGoldStatus(
    RepositorySlug slug,
    int prNumber,
  ) {
    return mock.queryLastGoldStatus(slug, prNumber);
  }

  @override
  Future<List<Commit>> queryRecentCommits({
    int limit = 100,
    int? timestamp,
    String? branch,
    required RepositorySlug slug,
  }) {
    return mock.queryRecentCommits(
      limit: limit,
      timestamp: timestamp,
      branch: branch,
      slug: slug,
    );
  }

  @override
  Future<List<Task>> queryRecentTasksByName({
    int limit = 100,
    required String name,
  }) {
    return mock.queryRecentTasksByName(limit: limit, name: name);
  }

  @override
  Future<CommitResponse> writeViaTransaction(List<Write> writes) {
    return mock.writeViaTransaction(writes);
  }
}
