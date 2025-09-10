// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Job _$JobFromJson(Map<String, dynamic> json) {
  return _Job.fromJson(json);
}

/// @nodoc
mixin _$Job {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get company => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get locationCity => throw _privateConstructorUsedError;
  String get locationCountry => throw _privateConstructorUsedError;
  int? get salaryMin => throw _privateConstructorUsedError;
  int? get salaryMax => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get requirements => throw _privateConstructorUsedError;
  List<String> get skills => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get employerId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobCopyWith<Job> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCopyWith<$Res> {
  factory $JobCopyWith(Job value, $Res Function(Job) then) =
      _$JobCopyWithImpl<$Res, Job>;
  @useResult
  $Res call(
      {String id,
      String title,
      String company,
      String category,
      String locationCity,
      String locationCountry,
      int? salaryMin,
      int? salaryMax,
      String type,
      String? logoUrl,
      String description,
      List<String> requirements,
      List<String> skills,
      DateTime createdAt,
      String employerId,
      bool isActive,
      DateTime? updatedAt});
}

/// @nodoc
class _$JobCopyWithImpl<$Res, $Val extends Job> implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? company = null,
    Object? category = null,
    Object? locationCity = null,
    Object? locationCountry = null,
    Object? salaryMin = freezed,
    Object? salaryMax = freezed,
    Object? type = null,
    Object? logoUrl = freezed,
    Object? description = null,
    Object? requirements = null,
    Object? skills = null,
    Object? createdAt = null,
    Object? employerId = null,
    Object? isActive = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      company: null == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      locationCity: null == locationCity
          ? _value.locationCity
          : locationCity // ignore: cast_nullable_to_non_nullable
              as String,
      locationCountry: null == locationCountry
          ? _value.locationCountry
          : locationCountry // ignore: cast_nullable_to_non_nullable
              as String,
      salaryMin: freezed == salaryMin
          ? _value.salaryMin
          : salaryMin // ignore: cast_nullable_to_non_nullable
              as int?,
      salaryMax: freezed == salaryMax
          ? _value.salaryMax
          : salaryMax // ignore: cast_nullable_to_non_nullable
              as int?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      requirements: null == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      skills: null == skills
          ? _value.skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      employerId: null == employerId
          ? _value.employerId
          : employerId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobImplCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$$JobImplCopyWith(_$JobImpl value, $Res Function(_$JobImpl) then) =
      __$$JobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String company,
      String category,
      String locationCity,
      String locationCountry,
      int? salaryMin,
      int? salaryMax,
      String type,
      String? logoUrl,
      String description,
      List<String> requirements,
      List<String> skills,
      DateTime createdAt,
      String employerId,
      bool isActive,
      DateTime? updatedAt});
}

/// @nodoc
class __$$JobImplCopyWithImpl<$Res> extends _$JobCopyWithImpl<$Res, _$JobImpl>
    implements _$$JobImplCopyWith<$Res> {
  __$$JobImplCopyWithImpl(_$JobImpl _value, $Res Function(_$JobImpl) _then)
      : super(_value, _then);

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? company = null,
    Object? category = null,
    Object? locationCity = null,
    Object? locationCountry = null,
    Object? salaryMin = freezed,
    Object? salaryMax = freezed,
    Object? type = null,
    Object? logoUrl = freezed,
    Object? description = null,
    Object? requirements = null,
    Object? skills = null,
    Object? createdAt = null,
    Object? employerId = null,
    Object? isActive = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$JobImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      company: null == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      locationCity: null == locationCity
          ? _value.locationCity
          : locationCity // ignore: cast_nullable_to_non_nullable
              as String,
      locationCountry: null == locationCountry
          ? _value.locationCountry
          : locationCountry // ignore: cast_nullable_to_non_nullable
              as String,
      salaryMin: freezed == salaryMin
          ? _value.salaryMin
          : salaryMin // ignore: cast_nullable_to_non_nullable
              as int?,
      salaryMax: freezed == salaryMax
          ? _value.salaryMax
          : salaryMax // ignore: cast_nullable_to_non_nullable
              as int?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      requirements: null == requirements
          ? _value._requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      skills: null == skills
          ? _value._skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      employerId: null == employerId
          ? _value.employerId
          : employerId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobImpl implements _Job {
  const _$JobImpl(
      {required this.id,
      required this.title,
      required this.company,
      required this.category,
      required this.locationCity,
      required this.locationCountry,
      this.salaryMin,
      this.salaryMax,
      required this.type,
      this.logoUrl,
      required this.description,
      required final List<String> requirements,
      required final List<String> skills,
      required this.createdAt,
      required this.employerId,
      this.isActive = true,
      this.updatedAt})
      : _requirements = requirements,
        _skills = skills;

  factory _$JobImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String company;
  @override
  final String category;
  @override
  final String locationCity;
  @override
  final String locationCountry;
  @override
  final int? salaryMin;
  @override
  final int? salaryMax;
  @override
  final String type;
  @override
  final String? logoUrl;
  @override
  final String description;
  final List<String> _requirements;
  @override
  List<String> get requirements {
    if (_requirements is EqualUnmodifiableListView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requirements);
  }

  final List<String> _skills;
  @override
  List<String> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

  @override
  final DateTime createdAt;
  @override
  final String employerId;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Job(id: $id, title: $title, company: $company, category: $category, locationCity: $locationCity, locationCountry: $locationCountry, salaryMin: $salaryMin, salaryMax: $salaryMax, type: $type, logoUrl: $logoUrl, description: $description, requirements: $requirements, skills: $skills, createdAt: $createdAt, employerId: $employerId, isActive: $isActive, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.locationCity, locationCity) ||
                other.locationCity == locationCity) &&
            (identical(other.locationCountry, locationCountry) ||
                other.locationCountry == locationCountry) &&
            (identical(other.salaryMin, salaryMin) ||
                other.salaryMin == salaryMin) &&
            (identical(other.salaryMax, salaryMax) ||
                other.salaryMax == salaryMax) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._requirements, _requirements) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.employerId, employerId) ||
                other.employerId == employerId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      company,
      category,
      locationCity,
      locationCountry,
      salaryMin,
      salaryMax,
      type,
      logoUrl,
      description,
      const DeepCollectionEquality().hash(_requirements),
      const DeepCollectionEquality().hash(_skills),
      createdAt,
      employerId,
      isActive,
      updatedAt);

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      __$$JobImplCopyWithImpl<_$JobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobImplToJson(
      this,
    );
  }
}

abstract class _Job implements Job {
  const factory _Job(
      {required final String id,
      required final String title,
      required final String company,
      required final String category,
      required final String locationCity,
      required final String locationCountry,
      final int? salaryMin,
      final int? salaryMax,
      required final String type,
      final String? logoUrl,
      required final String description,
      required final List<String> requirements,
      required final List<String> skills,
      required final DateTime createdAt,
      required final String employerId,
      final bool isActive,
      final DateTime? updatedAt}) = _$JobImpl;

  factory _Job.fromJson(Map<String, dynamic> json) = _$JobImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get company;
  @override
  String get category;
  @override
  String get locationCity;
  @override
  String get locationCountry;
  @override
  int? get salaryMin;
  @override
  int? get salaryMax;
  @override
  String get type;
  @override
  String? get logoUrl;
  @override
  String get description;
  @override
  List<String> get requirements;
  @override
  List<String> get skills;
  @override
  DateTime get createdAt;
  @override
  String get employerId;
  @override
  bool get isActive;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
