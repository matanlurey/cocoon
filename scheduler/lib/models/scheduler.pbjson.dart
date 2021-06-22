///
//  Generated code. Do not modify.
//  source: scheduler/lib/src/models/scheduler.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use schedulerSystemDescriptor instead')
const SchedulerSystem$json = const {
  '1': 'SchedulerSystem',
  '2': const [
    const {'1': 'cocoon', '2': 1},
    const {'1': 'luci', '2': 2},
  ],
};

/// Descriptor for `SchedulerSystem`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List schedulerSystemDescriptor =
    $convert.base64Decode('Cg9TY2hlZHVsZXJTeXN0ZW0SCgoGY29jb29uEAESCAoEbHVjaRAC');
@$core.Deprecated('Use schedulerConfigDescriptor instead')
const SchedulerConfig$json = const {
  '1': 'SchedulerConfig',
  '2': const [
    const {'1': 'targets', '3': 1, '4': 3, '5': 11, '6': '.Target', '10': 'targets'},
    const {'1': 'enabled_branches', '3': 2, '4': 3, '5': 9, '10': 'enabledBranches'},
  ],
};

/// Descriptor for `SchedulerConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schedulerConfigDescriptor = $convert.base64Decode(
    'Cg9TY2hlZHVsZXJDb25maWcSIQoHdGFyZ2V0cxgBIAMoCzIHLlRhcmdldFIHdGFyZ2V0cxIpChBlbmFibGVkX2JyYW5jaGVzGAIgAygJUg9lbmFibGVkQnJhbmNoZXM=');
@$core.Deprecated('Use targetDescriptor instead')
const Target$json = const {
  '1': 'Target',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'dependencies', '3': 2, '4': 3, '5': 9, '10': 'dependencies'},
    const {'1': 'bringup', '3': 3, '4': 1, '5': 8, '7': 'false', '10': 'bringup'},
    const {'1': 'timeout', '3': 4, '4': 1, '5': 5, '7': '30', '10': 'timeout'},
    const {'1': 'testbed', '3': 5, '4': 1, '5': 9, '7': 'linux-vm', '10': 'testbed'},
    const {'1': 'properties', '3': 6, '4': 3, '5': 11, '6': '.Target.PropertiesEntry', '10': 'properties'},
    const {'1': 'builder', '3': 7, '4': 1, '5': 9, '10': 'builder'},
    const {'1': 'scheduler', '3': 8, '4': 1, '5': 14, '6': '.SchedulerSystem', '7': 'cocoon', '10': 'scheduler'},
    const {'1': 'presubmit', '3': 9, '4': 1, '5': 8, '7': 'true', '10': 'presubmit'},
    const {'1': 'postsubmit', '3': 10, '4': 1, '5': 8, '7': 'true', '10': 'postsubmit'},
    const {'1': 'run_if', '3': 11, '4': 3, '5': 9, '10': 'runIf'},
    const {'1': 'enabled_branches', '3': 12, '4': 3, '5': 9, '10': 'enabledBranches'},
    const {'1': 'recipe', '3': 13, '4': 1, '5': 9, '10': 'recipe'},
  ],
  '3': const [Target_PropertiesEntry$json],
};

@$core.Deprecated('Use targetDescriptor instead')
const Target_PropertiesEntry$json = const {
  '1': 'PropertiesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `Target`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List targetDescriptor = $convert.base64Decode(
    'CgZUYXJnZXQSEgoEbmFtZRgBIAEoCVIEbmFtZRIiCgxkZXBlbmRlbmNpZXMYAiADKAlSDGRlcGVuZGVuY2llcxIfCgdicmluZ3VwGAMgASgIOgVmYWxzZVIHYnJpbmd1cBIcCgd0aW1lb3V0GAQgASgFOgIzMFIHdGltZW91dBIiCgd0ZXN0YmVkGAUgASgJOghsaW51eC12bVIHdGVzdGJlZBI3Cgpwcm9wZXJ0aWVzGAYgAygLMhcuVGFyZ2V0LlByb3BlcnRpZXNFbnRyeVIKcHJvcGVydGllcxIYCgdidWlsZGVyGAcgASgJUgdidWlsZGVyEjYKCXNjaGVkdWxlchgIIAEoDjIQLlNjaGVkdWxlclN5c3RlbToGY29jb29uUglzY2hlZHVsZXISIgoJcHJlc3VibWl0GAkgASgIOgR0cnVlUglwcmVzdWJtaXQSJAoKcG9zdHN1Ym1pdBgKIAEoCDoEdHJ1ZVIKcG9zdHN1Ym1pdBIVCgZydW5faWYYCyADKAlSBXJ1bklmEikKEGVuYWJsZWRfYnJhbmNoZXMYDCADKAlSD2VuYWJsZWRCcmFuY2hlcxIWCgZyZWNpcGUYDSABKAlSBnJlY2lwZRo9Cg9Qcm9wZXJ0aWVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');
