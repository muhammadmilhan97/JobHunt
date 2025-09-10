// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Application _$ApplicationFromJson(Map<String, dynamic> json) {
  return _Application.fromJson(json);
}

/// @nodoc
mixin _$Application {
  String get id => throw _privateConstructorUsedError;
  String get jobId => throw _privateConstructorUsedError;
  String get jobSeekerId => throw _privateConstructorUsedError;
  String get employerId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get cvUrl => throw _privateConstructorUsedError;
  String? get jobTitle => throw _privateConstructorUsedError;
  String? get employerName => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get coverLetter => throw _privateConstructorUsedError;
  int? get expectedSalary => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Application to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApplicationCopyWith<Application> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApplicationCopyWith<$Res> {
  factory $ApplicationCopyWith(
          Application value, $Res Function(Application) then) =
      _$ApplicationCopyWithImpl<$Res, Application>;
  @useResult
  $Res call(
      {String id,
      String jobId,
      String jobSeekerId,
      String employerId,
      String status,
      String cvUrl,
      String? jobTitle,
      String? employerName,
      String? notes,
      String? coverLetter,
      int? expectedSalary,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ApplicationCopyWithImpl<$Res, $Val extends Application>
    implements $ApplicationCopyWith<$Res> {
  _$ApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? jobSeekerId = null,
    Object? employerId = null,
    Object? status = null,
    Object? cvUrl = null,
    Object? jobTitle = freezed,
    Object? employerName = freezed,
    Object? notes = freezed,
    Object? coverLetter = freezed,
    Object? expectedSalary = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      jobSeekerId: null == jobSeekerId
          ? _value.jobSeekerId
          : jobSeekerId // ignore: cast_nullable_to_non_nullable
              as String,
      employerId: null == employerId
          ? _value.employerId
          : employerId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      cvUrl: null == cvUrl
          ? _value.cvUrl
          : cvUrl // ignore: cast_nullable_to_non_nullable
              as String,
      jobTitle: freezed == jobTitle
          ? _value.jobTitle
          : jobTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      employerName: freezed == employerName
          ? _value.employerName
          : employerName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      coverLetter: freezed == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedSalary: freezed == expectedSalary
          ? _value.expectedSalary
          : expectedSalary // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApplicationImplCopyWith<$Res>
    implements $ApplicationCopyWith<$Res> {
  factory _$$ApplicationImplCopyWith(
          _$ApplicationImpl value, $Res Function(_$ApplicationImpl) then) =
      __$$ApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String jobId,
      String jobSeekerId,
      String employerId,
      String status,
      String cvUrl,
      String? jobTitle,
      String? employerName,
      String? notes,
      String? coverLetter,
      int? expectedSalary,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ApplicationImplCopyWithImpl<$Res>
    extends _$ApplicationCopyWithImpl<$Res, _$ApplicationImpl>
    implements _$$ApplicationImplCopyWith<$Res> {
  __$$ApplicationImplCopyWithImpl(
      _$ApplicationImpl _value, $Res Function(_$ApplicationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? jobSeekerId = null,
    Object? employerId = null,
    Object? status = null,
    Object? cvUrl = null,
    Object? jobTitle = freezed,
    Object? employerName = freezed,
    Object? notes = freezed,
    Object? coverLetter = freezed,
    Object? expectedSalary = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ApplicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      jobSeekerId: null == jobSeekerId
          ? _value.jobSeekerId
          : jobSeekerId // ignore: cast_nullable_to_non_nullable
              as String,
      employerId: null == employerId
          ? _value.employerId
          : employerId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      cvUrl: null == cvUrl
          ? _value.cvUrl
          : cvUrl // ignore: cast_nullable_to_non_nullable
              as String,
      jobTitle: freezed == jobTitle
          ? _value.jobTitle
          : jobTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      employerName: freezed == employerName
          ? _value.employerName
          : employerName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      coverLetter: freezed == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedSalary: freezed == expectedSalary
          ? _value.expectedSalary
          : expectedSalary // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApplicationImpl implements _Application {
  const _$ApplicationImpl(
      {required this.id,
      required this.jobId,
      required this.jobSeekerId,
      required this.employerId,
      required this.status,
      required this.cvUrl,
      this.jobTitle,
      this.employerName,
      this.notes,
      this.coverLetter,
      this.expectedSalary,
      required this.createdAt,
      this.updatedAt});

  factory _$ApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApplicationImplFromJson(json);

  @override
  final String id;
  @override
  final String jobId;
  @override
  final String jobSeekerId;
  @override
  final String employerId;
  @override
  final String status;
  @override
  final String cvUrl;
  @override
  final String? jobTitle;
  @override
  final String? employerName;
  @override
  final String? notes;
  @override
  final String? coverLetter;
  @override
  final int? expectedSalary;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Application(id: $id, jobId: $jobId, jobSeekerId: $jobSeekerId, employerId: $employerId, status: $status, cvUrl: $cvUrl, jobTitle: $jobTitle, employerName: $employerName, notes: $notes, coverLetter: $coverLetter, expectedSalary: $expectedSalary, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApplicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.jobSeekerId, jobSeekerId) ||
                other.jobSeekerId == jobSeekerId) &&
            (identical(other.employerId, employerId) ||
                other.employerId == employerId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cvUrl, cvUrl) || other.cvUrl == cvUrl) &&
            (identical(other.jobTitle, jobTitle) ||
                other.jobTitle == jobTitle) &&
            (identical(other.employerName, employerName) ||
                other.employerName == employerName) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.coverLetter, coverLetter) ||
                other.coverLetter == coverLetter) &&
            (identical(other.expectedSalary, expectedSalary) ||
                other.expectedSalary == expectedSalary) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      jobId,
      jobSeekerId,
      employerId,
      status,
      cvUrl,
      jobTitle,
      employerName,
      notes,
      coverLetter,
      expectedSalary,
      createdAt,
      updatedAt);

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApplicationImplCopyWith<_$ApplicationImpl> get copyWith =>
      __$$ApplicationImplCopyWithImpl<_$ApplicationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApplicationImplToJson(
      this,
    );
  }
}

abstract class _Application implements Application {
  const factory _Application(
      {required final String id,
      required final String jobId,
      required final String jobSeekerId,
      required final String employerId,
      required final String status,
      required final String cvUrl,
      final String? jobTitle,
      final String? employerName,
      final String? notes,
      final String? coverLetter,
      final int? expectedSalary,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$ApplicationImpl;

  factory _Application.fromJson(Map<String, dynamic> json) =
      _$ApplicationImpl.fromJson;

  @override
  String get id;
  @override
  String get jobId;
  @override
  String get jobSeekerId;
  @override
  String get employerId;
  @override
  String get status;
  @override
  String get cvUrl;
  @override
  String? get jobTitle;
  @override
  String? get employerName;
  @override
  String? get notes;
  @override
  String? get coverLetter;
  @override
  int? get expectedSalary;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApplicationImplCopyWith<_$ApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
