// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:github/github.dart';
import 'package:googleapis/firestore/v1.dart' hide Status;
import 'package:path/path.dart' as p;

import '../../../cocoon_service.dart';
import '../../service/firestore.dart';
import '../appengine/commit.dart' as datastore;

const String kCommitCollectionId = 'commits';
const String kCommitAvatarField = 'avatar';
const String kCommitBranchField = 'branch';
const String kCommitCreateTimestampField = 'createTimestamp';
const String kCommitAuthorField = 'author';
const String kCommitMessageField = 'message';
const String kCommitRepositoryPathField = 'repositoryPath';
const String kCommitShaField = 'sha';

/// Commit Json keys.
const String kCommitAvatar = 'Avatar';
const String kCommitAuthor = 'Author';
const String kCommitBranch = 'Branch';
const String kCommitCreateTimestamp = 'CreateTimestamp';
const String kCommitDocumentName = 'DocumentName';
const String kCommitMessage = 'Message';
const String kCommitRepositoryPath = 'RepositoryPath';
const String kCommitSha = 'Sha';

final class Commit extends Document {
  /// Returns [Commit] from [firestore] by the given [sha].
  static Future<Commit> fromFirestoreBySha(
    FirestoreService firestore, {
    required String sha,
  }) async {
    final documentName = p.join(
      kDatabase,
      'documents',
      kCommitCollectionId,
      sha,
    );
    final document = await firestore.getDocument(documentName);
    return Commit.fromDocument(commitDocument: document);
  }

  /// Create [Commit] from a Commit Document.
  static Commit fromDocument({required Document commitDocument}) {
    return Commit()
      ..fields = commitDocument.fields!
      ..name = commitDocument.name!;
  }

  /// The timestamp (in milliseconds since the Epoch) of when the commit
  /// landed.
  int? get createTimestamp =>
      int.parse(fields![kCommitCreateTimestampField]!.integerValue!);

  /// The SHA1 hash of the commit.
  String? get sha => fields![kCommitShaField]!.stringValue!;

  /// The GitHub username of the commit author.
  String? get author => fields![kCommitAuthorField]!.stringValue!;

  /// URL of the [author]'s profile image / avatar.
  ///
  /// The bytes loaded from the URL are expected to be encoded image bytes.
  String? get avatar => fields![kCommitAvatarField]!.stringValue!;

  /// The commit message.
  ///
  /// This may be null, since we didn't always load/store this property in
  /// the datastore, so historical entries won't have this information.
  String? get message => fields![kCommitMessageField]!.stringValue!;

  /// A serializable form of [slug].
  ///
  /// This will be of the form `<org>/<repo>`. e.g. `flutter/flutter`.
  String? get repositoryPath =>
      fields![kCommitRepositoryPathField]!.stringValue!;

  /// The branch of the commit.
  String? get branch => fields![kCommitBranchField]!.stringValue!;

  /// [RepositorySlug] of where this commit exists.
  RepositorySlug get slug => RepositorySlug.full(repositoryPath!);

  Map<String, dynamic> get facade {
    return <String, dynamic>{
      kCommitDocumentName: name,
      kCommitRepositoryPath: repositoryPath,
      kCommitCreateTimestamp: createTimestamp,
      kCommitSha: sha,
      kCommitMessage: message,
      kCommitAuthor: author,
      kCommitAvatar: avatar,
      kCommitBranch: branch,
    };
  }

  @override
  String toString() {
    final buf =
        StringBuffer()
          ..write('$runtimeType(')
          ..write(', $kCommitCreateTimestampField: $createTimestamp')
          ..write(', $kCommitAuthorField: $author')
          ..write(', $kCommitAvatarField: $avatar')
          ..write(', $kCommitBranchField: $branch')
          ..write(', $kCommitMessageField: $message')
          ..write(', $kCommitRepositoryPathField: $repositoryPath')
          ..write(', $kCommitShaField: $sha')
          ..write(')');
    return buf.toString();
  }
}

/// Generates commit document based on datastore commit data model.
Commit commitToCommitDocument(datastore.Commit commit) {
  return Commit.fromDocument(
    commitDocument: Document(
      name: '$kDatabase/documents/$kCommitCollectionId/${commit.sha}',
      fields: <String, Value>{
        kCommitAvatarField: Value(stringValue: commit.authorAvatarUrl),
        kCommitBranchField: Value(stringValue: commit.branch),
        kCommitCreateTimestampField: Value(
          integerValue: commit.timestamp.toString(),
        ),
        kCommitAuthorField: Value(stringValue: commit.author),
        kCommitMessageField: Value(stringValue: commit.message),
        kCommitRepositoryPathField: Value(stringValue: commit.repository),
        kCommitShaField: Value(stringValue: commit.sha),
      },
    ),
  );
}
