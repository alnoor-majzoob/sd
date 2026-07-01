// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScheduleWorkspacesTable extends ScheduleWorkspaces
    with TableInfo<$ScheduleWorkspacesTable, ScheduleWorkspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleWorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 7),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, timestamp, status, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_workspaces';
  @override
  VerificationContext validateIntegrity(Insertable<ScheduleWorkspace> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleWorkspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleWorkspace(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $ScheduleWorkspacesTable createAlias(String alias) {
    return $ScheduleWorkspacesTable(attachedDatabase, alias);
  }
}

class ScheduleWorkspace extends DataClass
    implements Insertable<ScheduleWorkspace> {
  final int id;
  final String name;
  final DateTime timestamp;
  final String status;
  final String color;
  const ScheduleWorkspace(
      {required this.id,
      required this.name,
      required this.timestamp,
      required this.status,
      required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['status'] = Variable<String>(status);
    map['color'] = Variable<String>(color);
    return map;
  }

  ScheduleWorkspacesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleWorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      timestamp: Value(timestamp),
      status: Value(status),
      color: Value(color),
    );
  }

  factory ScheduleWorkspace.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleWorkspace(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      status: serializer.fromJson<String>(json['status']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'status': serializer.toJson<String>(status),
      'color': serializer.toJson<String>(color),
    };
  }

  ScheduleWorkspace copyWith(
          {int? id,
          String? name,
          DateTime? timestamp,
          String? status,
          String? color}) =>
      ScheduleWorkspace(
        id: id ?? this.id,
        name: name ?? this.name,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
        color: color ?? this.color,
      );
  ScheduleWorkspace copyWithCompanion(ScheduleWorkspacesCompanion data) {
    return ScheduleWorkspace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      status: data.status.present ? data.status.value : this.status,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleWorkspace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, timestamp, status, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleWorkspace &&
          other.id == this.id &&
          other.name == this.name &&
          other.timestamp == this.timestamp &&
          other.status == this.status &&
          other.color == this.color);
}

class ScheduleWorkspacesCompanion extends UpdateCompanion<ScheduleWorkspace> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> timestamp;
  final Value<String> status;
  final Value<String> color;
  const ScheduleWorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
    this.color = const Value.absent(),
  });
  ScheduleWorkspacesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime timestamp,
    required String status,
    required String color,
  })  : name = Value(name),
        timestamp = Value(timestamp),
        status = Value(status),
        color = Value(color);
  static Insertable<ScheduleWorkspace> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? timestamp,
    Expression<String>? status,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (timestamp != null) 'timestamp': timestamp,
      if (status != null) 'status': status,
      if (color != null) 'color': color,
    });
  }

  ScheduleWorkspacesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? timestamp,
      Value<String>? status,
      Value<String>? color}) {
    return ScheduleWorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleWorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_workspaces (id)'));
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationDaysMeta =
      const VerificationMeta('durationDays');
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
      'duration_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _expectedTraineesMeta =
      const VerificationMeta('expectedTrainees');
  @override
  late final GeneratedColumn<int> expectedTrainees = GeneratedColumn<int>(
      'expected_trainees', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deliveryTypeMeta =
      const VerificationMeta('deliveryType');
  @override
  late final GeneratedColumn<String> deliveryType = GeneratedColumn<String>(
      'delivery_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specialtyMeta =
      const VerificationMeta('specialty');
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
      'specialty', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hoursPerDayMeta =
      const VerificationMeta('hoursPerDay');
  @override
  late final GeneratedColumn<int> hoursPerDay = GeneratedColumn<int>(
      'hours_per_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _preferredCitySiteMeta =
      const VerificationMeta('preferredCitySite');
  @override
  late final GeneratedColumn<String> preferredCitySite =
      GeneratedColumn<String>('preferred_city_site', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _beneficiaryMeta =
      const VerificationMeta('beneficiary');
  @override
  late final GeneratedColumn<String> beneficiary = GeneratedColumn<String>(
      'beneficiary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _earliestStartMeta =
      const VerificationMeta('earliestStart');
  @override
  late final GeneratedColumn<DateTime> earliestStart =
      GeneratedColumn<DateTime>('earliest_start', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _latestEndMeta =
      const VerificationMeta('latestEnd');
  @override
  late final GeneratedColumn<DateTime> latestEnd = GeneratedColumn<DateTime>(
      'latest_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fixedDateMeta =
      const VerificationMeta('fixedDate');
  @override
  late final GeneratedColumn<DateTime> fixedDate = GeneratedColumn<DateTime>(
      'fixed_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _courseNameArMeta =
      const VerificationMeta('courseNameAr');
  @override
  late final GeneratedColumn<String> courseNameAr = GeneratedColumn<String>(
      'course_name_ar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workspaceId,
        courseId,
        name,
        durationDays,
        expectedTrainees,
        deliveryType,
        specialty,
        hoursPerDay,
        preferredCitySite,
        beneficiary,
        priority,
        earliestStart,
        latestEnd,
        fixedDate,
        notes,
        courseNameAr
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(Insertable<Course> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('duration_days')) {
      context.handle(
          _durationDaysMeta,
          durationDays.isAcceptableOrUnknown(
              data['duration_days']!, _durationDaysMeta));
    } else if (isInserting) {
      context.missing(_durationDaysMeta);
    }
    if (data.containsKey('expected_trainees')) {
      context.handle(
          _expectedTraineesMeta,
          expectedTrainees.isAcceptableOrUnknown(
              data['expected_trainees']!, _expectedTraineesMeta));
    } else if (isInserting) {
      context.missing(_expectedTraineesMeta);
    }
    if (data.containsKey('delivery_type')) {
      context.handle(
          _deliveryTypeMeta,
          deliveryType.isAcceptableOrUnknown(
              data['delivery_type']!, _deliveryTypeMeta));
    } else if (isInserting) {
      context.missing(_deliveryTypeMeta);
    }
    if (data.containsKey('specialty')) {
      context.handle(_specialtyMeta,
          specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta));
    }
    if (data.containsKey('hours_per_day')) {
      context.handle(
          _hoursPerDayMeta,
          hoursPerDay.isAcceptableOrUnknown(
              data['hours_per_day']!, _hoursPerDayMeta));
    }
    if (data.containsKey('preferred_city_site')) {
      context.handle(
          _preferredCitySiteMeta,
          preferredCitySite.isAcceptableOrUnknown(
              data['preferred_city_site']!, _preferredCitySiteMeta));
    }
    if (data.containsKey('beneficiary')) {
      context.handle(
          _beneficiaryMeta,
          beneficiary.isAcceptableOrUnknown(
              data['beneficiary']!, _beneficiaryMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('earliest_start')) {
      context.handle(
          _earliestStartMeta,
          earliestStart.isAcceptableOrUnknown(
              data['earliest_start']!, _earliestStartMeta));
    }
    if (data.containsKey('latest_end')) {
      context.handle(_latestEndMeta,
          latestEnd.isAcceptableOrUnknown(data['latest_end']!, _latestEndMeta));
    }
    if (data.containsKey('fixed_date')) {
      context.handle(_fixedDateMeta,
          fixedDate.isAcceptableOrUnknown(data['fixed_date']!, _fixedDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('course_name_ar')) {
      context.handle(
          _courseNameArMeta,
          courseNameAr.isAcceptableOrUnknown(
              data['course_name_ar']!, _courseNameArMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workspace_id'])!,
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      durationDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_days'])!,
      expectedTrainees: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expected_trainees'])!,
      deliveryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}delivery_type'])!,
      specialty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specialty']),
      hoursPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hours_per_day']),
      preferredCitySite: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preferred_city_site']),
      beneficiary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority']),
      earliestStart: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}earliest_start']),
      latestEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}latest_end']),
      fixedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fixed_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      courseNameAr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_name_ar']),
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class Course extends DataClass implements Insertable<Course> {
  final int id;
  final int workspaceId;
  final String courseId;
  final String name;
  final int durationDays;
  final int expectedTrainees;
  final String deliveryType;
  final String? specialty;
  final int? hoursPerDay;
  final String? preferredCitySite;
  final String? beneficiary;
  final String? priority;
  final DateTime? earliestStart;
  final DateTime? latestEnd;
  final DateTime? fixedDate;
  final String? notes;
  final String? courseNameAr;
  const Course(
      {required this.id,
      required this.workspaceId,
      required this.courseId,
      required this.name,
      required this.durationDays,
      required this.expectedTrainees,
      required this.deliveryType,
      this.specialty,
      this.hoursPerDay,
      this.preferredCitySite,
      this.beneficiary,
      this.priority,
      this.earliestStart,
      this.latestEnd,
      this.fixedDate,
      this.notes,
      this.courseNameAr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['course_id'] = Variable<String>(courseId);
    map['name'] = Variable<String>(name);
    map['duration_days'] = Variable<int>(durationDays);
    map['expected_trainees'] = Variable<int>(expectedTrainees);
    map['delivery_type'] = Variable<String>(deliveryType);
    if (!nullToAbsent || specialty != null) {
      map['specialty'] = Variable<String>(specialty);
    }
    if (!nullToAbsent || hoursPerDay != null) {
      map['hours_per_day'] = Variable<int>(hoursPerDay);
    }
    if (!nullToAbsent || preferredCitySite != null) {
      map['preferred_city_site'] = Variable<String>(preferredCitySite);
    }
    if (!nullToAbsent || beneficiary != null) {
      map['beneficiary'] = Variable<String>(beneficiary);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<String>(priority);
    }
    if (!nullToAbsent || earliestStart != null) {
      map['earliest_start'] = Variable<DateTime>(earliestStart);
    }
    if (!nullToAbsent || latestEnd != null) {
      map['latest_end'] = Variable<DateTime>(latestEnd);
    }
    if (!nullToAbsent || fixedDate != null) {
      map['fixed_date'] = Variable<DateTime>(fixedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || courseNameAr != null) {
      map['course_name_ar'] = Variable<String>(courseNameAr);
    }
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      courseId: Value(courseId),
      name: Value(name),
      durationDays: Value(durationDays),
      expectedTrainees: Value(expectedTrainees),
      deliveryType: Value(deliveryType),
      specialty: specialty == null && nullToAbsent
          ? const Value.absent()
          : Value(specialty),
      hoursPerDay: hoursPerDay == null && nullToAbsent
          ? const Value.absent()
          : Value(hoursPerDay),
      preferredCitySite: preferredCitySite == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredCitySite),
      beneficiary: beneficiary == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiary),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      earliestStart: earliestStart == null && nullToAbsent
          ? const Value.absent()
          : Value(earliestStart),
      latestEnd: latestEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(latestEnd),
      fixedDate: fixedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      courseNameAr: courseNameAr == null && nullToAbsent
          ? const Value.absent()
          : Value(courseNameAr),
    );
  }

  factory Course.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      courseId: serializer.fromJson<String>(json['courseId']),
      name: serializer.fromJson<String>(json['name']),
      durationDays: serializer.fromJson<int>(json['durationDays']),
      expectedTrainees: serializer.fromJson<int>(json['expectedTrainees']),
      deliveryType: serializer.fromJson<String>(json['deliveryType']),
      specialty: serializer.fromJson<String?>(json['specialty']),
      hoursPerDay: serializer.fromJson<int?>(json['hoursPerDay']),
      preferredCitySite:
          serializer.fromJson<String?>(json['preferredCitySite']),
      beneficiary: serializer.fromJson<String?>(json['beneficiary']),
      priority: serializer.fromJson<String?>(json['priority']),
      earliestStart: serializer.fromJson<DateTime?>(json['earliestStart']),
      latestEnd: serializer.fromJson<DateTime?>(json['latestEnd']),
      fixedDate: serializer.fromJson<DateTime?>(json['fixedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      courseNameAr: serializer.fromJson<String?>(json['courseNameAr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'courseId': serializer.toJson<String>(courseId),
      'name': serializer.toJson<String>(name),
      'durationDays': serializer.toJson<int>(durationDays),
      'expectedTrainees': serializer.toJson<int>(expectedTrainees),
      'deliveryType': serializer.toJson<String>(deliveryType),
      'specialty': serializer.toJson<String?>(specialty),
      'hoursPerDay': serializer.toJson<int?>(hoursPerDay),
      'preferredCitySite': serializer.toJson<String?>(preferredCitySite),
      'beneficiary': serializer.toJson<String?>(beneficiary),
      'priority': serializer.toJson<String?>(priority),
      'earliestStart': serializer.toJson<DateTime?>(earliestStart),
      'latestEnd': serializer.toJson<DateTime?>(latestEnd),
      'fixedDate': serializer.toJson<DateTime?>(fixedDate),
      'notes': serializer.toJson<String?>(notes),
      'courseNameAr': serializer.toJson<String?>(courseNameAr),
    };
  }

  Course copyWith(
          {int? id,
          int? workspaceId,
          String? courseId,
          String? name,
          int? durationDays,
          int? expectedTrainees,
          String? deliveryType,
          Value<String?> specialty = const Value.absent(),
          Value<int?> hoursPerDay = const Value.absent(),
          Value<String?> preferredCitySite = const Value.absent(),
          Value<String?> beneficiary = const Value.absent(),
          Value<String?> priority = const Value.absent(),
          Value<DateTime?> earliestStart = const Value.absent(),
          Value<DateTime?> latestEnd = const Value.absent(),
          Value<DateTime?> fixedDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> courseNameAr = const Value.absent()}) =>
      Course(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        courseId: courseId ?? this.courseId,
        name: name ?? this.name,
        durationDays: durationDays ?? this.durationDays,
        expectedTrainees: expectedTrainees ?? this.expectedTrainees,
        deliveryType: deliveryType ?? this.deliveryType,
        specialty: specialty.present ? specialty.value : this.specialty,
        hoursPerDay: hoursPerDay.present ? hoursPerDay.value : this.hoursPerDay,
        preferredCitySite: preferredCitySite.present
            ? preferredCitySite.value
            : this.preferredCitySite,
        beneficiary: beneficiary.present ? beneficiary.value : this.beneficiary,
        priority: priority.present ? priority.value : this.priority,
        earliestStart:
            earliestStart.present ? earliestStart.value : this.earliestStart,
        latestEnd: latestEnd.present ? latestEnd.value : this.latestEnd,
        fixedDate: fixedDate.present ? fixedDate.value : this.fixedDate,
        notes: notes.present ? notes.value : this.notes,
        courseNameAr:
            courseNameAr.present ? courseNameAr.value : this.courseNameAr,
      );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      name: data.name.present ? data.name.value : this.name,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      expectedTrainees: data.expectedTrainees.present
          ? data.expectedTrainees.value
          : this.expectedTrainees,
      deliveryType: data.deliveryType.present
          ? data.deliveryType.value
          : this.deliveryType,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      hoursPerDay:
          data.hoursPerDay.present ? data.hoursPerDay.value : this.hoursPerDay,
      preferredCitySite: data.preferredCitySite.present
          ? data.preferredCitySite.value
          : this.preferredCitySite,
      beneficiary:
          data.beneficiary.present ? data.beneficiary.value : this.beneficiary,
      priority: data.priority.present ? data.priority.value : this.priority,
      earliestStart: data.earliestStart.present
          ? data.earliestStart.value
          : this.earliestStart,
      latestEnd: data.latestEnd.present ? data.latestEnd.value : this.latestEnd,
      fixedDate: data.fixedDate.present ? data.fixedDate.value : this.fixedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      courseNameAr: data.courseNameAr.present
          ? data.courseNameAr.value
          : this.courseNameAr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('courseId: $courseId, ')
          ..write('name: $name, ')
          ..write('durationDays: $durationDays, ')
          ..write('expectedTrainees: $expectedTrainees, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('specialty: $specialty, ')
          ..write('hoursPerDay: $hoursPerDay, ')
          ..write('preferredCitySite: $preferredCitySite, ')
          ..write('beneficiary: $beneficiary, ')
          ..write('priority: $priority, ')
          ..write('earliestStart: $earliestStart, ')
          ..write('latestEnd: $latestEnd, ')
          ..write('fixedDate: $fixedDate, ')
          ..write('notes: $notes, ')
          ..write('courseNameAr: $courseNameAr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      workspaceId,
      courseId,
      name,
      durationDays,
      expectedTrainees,
      deliveryType,
      specialty,
      hoursPerDay,
      preferredCitySite,
      beneficiary,
      priority,
      earliestStart,
      latestEnd,
      fixedDate,
      notes,
      courseNameAr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.courseId == this.courseId &&
          other.name == this.name &&
          other.durationDays == this.durationDays &&
          other.expectedTrainees == this.expectedTrainees &&
          other.deliveryType == this.deliveryType &&
          other.specialty == this.specialty &&
          other.hoursPerDay == this.hoursPerDay &&
          other.preferredCitySite == this.preferredCitySite &&
          other.beneficiary == this.beneficiary &&
          other.priority == this.priority &&
          other.earliestStart == this.earliestStart &&
          other.latestEnd == this.latestEnd &&
          other.fixedDate == this.fixedDate &&
          other.notes == this.notes &&
          other.courseNameAr == this.courseNameAr);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> courseId;
  final Value<String> name;
  final Value<int> durationDays;
  final Value<int> expectedTrainees;
  final Value<String> deliveryType;
  final Value<String?> specialty;
  final Value<int?> hoursPerDay;
  final Value<String?> preferredCitySite;
  final Value<String?> beneficiary;
  final Value<String?> priority;
  final Value<DateTime?> earliestStart;
  final Value<DateTime?> latestEnd;
  final Value<DateTime?> fixedDate;
  final Value<String?> notes;
  final Value<String?> courseNameAr;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.name = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.expectedTrainees = const Value.absent(),
    this.deliveryType = const Value.absent(),
    this.specialty = const Value.absent(),
    this.hoursPerDay = const Value.absent(),
    this.preferredCitySite = const Value.absent(),
    this.beneficiary = const Value.absent(),
    this.priority = const Value.absent(),
    this.earliestStart = const Value.absent(),
    this.latestEnd = const Value.absent(),
    this.fixedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.courseNameAr = const Value.absent(),
  });
  CoursesCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String courseId,
    required String name,
    required int durationDays,
    required int expectedTrainees,
    required String deliveryType,
    this.specialty = const Value.absent(),
    this.hoursPerDay = const Value.absent(),
    this.preferredCitySite = const Value.absent(),
    this.beneficiary = const Value.absent(),
    this.priority = const Value.absent(),
    this.earliestStart = const Value.absent(),
    this.latestEnd = const Value.absent(),
    this.fixedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.courseNameAr = const Value.absent(),
  })  : workspaceId = Value(workspaceId),
        courseId = Value(courseId),
        name = Value(name),
        durationDays = Value(durationDays),
        expectedTrainees = Value(expectedTrainees),
        deliveryType = Value(deliveryType);
  static Insertable<Course> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? courseId,
    Expression<String>? name,
    Expression<int>? durationDays,
    Expression<int>? expectedTrainees,
    Expression<String>? deliveryType,
    Expression<String>? specialty,
    Expression<int>? hoursPerDay,
    Expression<String>? preferredCitySite,
    Expression<String>? beneficiary,
    Expression<String>? priority,
    Expression<DateTime>? earliestStart,
    Expression<DateTime>? latestEnd,
    Expression<DateTime>? fixedDate,
    Expression<String>? notes,
    Expression<String>? courseNameAr,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (courseId != null) 'course_id': courseId,
      if (name != null) 'name': name,
      if (durationDays != null) 'duration_days': durationDays,
      if (expectedTrainees != null) 'expected_trainees': expectedTrainees,
      if (deliveryType != null) 'delivery_type': deliveryType,
      if (specialty != null) 'specialty': specialty,
      if (hoursPerDay != null) 'hours_per_day': hoursPerDay,
      if (preferredCitySite != null) 'preferred_city_site': preferredCitySite,
      if (beneficiary != null) 'beneficiary': beneficiary,
      if (priority != null) 'priority': priority,
      if (earliestStart != null) 'earliest_start': earliestStart,
      if (latestEnd != null) 'latest_end': latestEnd,
      if (fixedDate != null) 'fixed_date': fixedDate,
      if (notes != null) 'notes': notes,
      if (courseNameAr != null) 'course_name_ar': courseNameAr,
    });
  }

  CoursesCompanion copyWith(
      {Value<int>? id,
      Value<int>? workspaceId,
      Value<String>? courseId,
      Value<String>? name,
      Value<int>? durationDays,
      Value<int>? expectedTrainees,
      Value<String>? deliveryType,
      Value<String?>? specialty,
      Value<int?>? hoursPerDay,
      Value<String?>? preferredCitySite,
      Value<String?>? beneficiary,
      Value<String?>? priority,
      Value<DateTime?>? earliestStart,
      Value<DateTime?>? latestEnd,
      Value<DateTime?>? fixedDate,
      Value<String?>? notes,
      Value<String?>? courseNameAr}) {
    return CoursesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      durationDays: durationDays ?? this.durationDays,
      expectedTrainees: expectedTrainees ?? this.expectedTrainees,
      deliveryType: deliveryType ?? this.deliveryType,
      specialty: specialty ?? this.specialty,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      preferredCitySite: preferredCitySite ?? this.preferredCitySite,
      beneficiary: beneficiary ?? this.beneficiary,
      priority: priority ?? this.priority,
      earliestStart: earliestStart ?? this.earliestStart,
      latestEnd: latestEnd ?? this.latestEnd,
      fixedDate: fixedDate ?? this.fixedDate,
      notes: notes ?? this.notes,
      courseNameAr: courseNameAr ?? this.courseNameAr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (expectedTrainees.present) {
      map['expected_trainees'] = Variable<int>(expectedTrainees.value);
    }
    if (deliveryType.present) {
      map['delivery_type'] = Variable<String>(deliveryType.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (hoursPerDay.present) {
      map['hours_per_day'] = Variable<int>(hoursPerDay.value);
    }
    if (preferredCitySite.present) {
      map['preferred_city_site'] = Variable<String>(preferredCitySite.value);
    }
    if (beneficiary.present) {
      map['beneficiary'] = Variable<String>(beneficiary.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (earliestStart.present) {
      map['earliest_start'] = Variable<DateTime>(earliestStart.value);
    }
    if (latestEnd.present) {
      map['latest_end'] = Variable<DateTime>(latestEnd.value);
    }
    if (fixedDate.present) {
      map['fixed_date'] = Variable<DateTime>(fixedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (courseNameAr.present) {
      map['course_name_ar'] = Variable<String>(courseNameAr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('courseId: $courseId, ')
          ..write('name: $name, ')
          ..write('durationDays: $durationDays, ')
          ..write('expectedTrainees: $expectedTrainees, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('specialty: $specialty, ')
          ..write('hoursPerDay: $hoursPerDay, ')
          ..write('preferredCitySite: $preferredCitySite, ')
          ..write('beneficiary: $beneficiary, ')
          ..write('priority: $priority, ')
          ..write('earliestStart: $earliestStart, ')
          ..write('latestEnd: $latestEnd, ')
          ..write('fixedDate: $fixedDate, ')
          ..write('notes: $notes, ')
          ..write('courseNameAr: $courseNameAr')
          ..write(')'))
        .toString();
  }
}

class $TrainersTable extends Trainers with TableInfo<$TrainersTable, Trainer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_workspaces (id)'));
  static const VerificationMeta _trainerIdMeta =
      const VerificationMeta('trainerId');
  @override
  late final GeneratedColumn<String> trainerId = GeneratedColumn<String>(
      'trainer_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specialtyMeta =
      const VerificationMeta('specialty');
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
      'specialty', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trainerTypeMeta =
      const VerificationMeta('trainerType');
  @override
  late final GeneratedColumn<String> trainerType = GeneratedColumn<String>(
      'trainer_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _maxDaysPerMonthMeta =
      const VerificationMeta('maxDaysPerMonth');
  @override
  late final GeneratedColumn<int> maxDaysPerMonth = GeneratedColumn<int>(
      'max_days_per_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxConsecutiveDaysMeta =
      const VerificationMeta('maxConsecutiveDays');
  @override
  late final GeneratedColumn<int> maxConsecutiveDays = GeneratedColumn<int>(
      'max_consecutive_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _costPerDayMeta =
      const VerificationMeta('costPerDay');
  @override
  late final GeneratedColumn<double> costPerDay = GeneratedColumn<double>(
      'cost_per_day', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workspaceId,
        trainerId,
        name,
        specialty,
        city,
        trainerType,
        maxDaysPerMonth,
        maxConsecutiveDays,
        costPerDay,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trainers';
  @override
  VerificationContext validateIntegrity(Insertable<Trainer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('trainer_id')) {
      context.handle(_trainerIdMeta,
          trainerId.isAcceptableOrUnknown(data['trainer_id']!, _trainerIdMeta));
    } else if (isInserting) {
      context.missing(_trainerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('specialty')) {
      context.handle(_specialtyMeta,
          specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('trainer_type')) {
      context.handle(
          _trainerTypeMeta,
          trainerType.isAcceptableOrUnknown(
              data['trainer_type']!, _trainerTypeMeta));
    }
    if (data.containsKey('max_days_per_month')) {
      context.handle(
          _maxDaysPerMonthMeta,
          maxDaysPerMonth.isAcceptableOrUnknown(
              data['max_days_per_month']!, _maxDaysPerMonthMeta));
    }
    if (data.containsKey('max_consecutive_days')) {
      context.handle(
          _maxConsecutiveDaysMeta,
          maxConsecutiveDays.isAcceptableOrUnknown(
              data['max_consecutive_days']!, _maxConsecutiveDaysMeta));
    }
    if (data.containsKey('cost_per_day')) {
      context.handle(
          _costPerDayMeta,
          costPerDay.isAcceptableOrUnknown(
              data['cost_per_day']!, _costPerDayMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trainer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trainer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workspace_id'])!,
      trainerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trainer_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      specialty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specialty']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      trainerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trainer_type']),
      maxDaysPerMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_days_per_month']),
      maxConsecutiveDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_consecutive_days']),
      costPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_per_day']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $TrainersTable createAlias(String alias) {
    return $TrainersTable(attachedDatabase, alias);
  }
}

class Trainer extends DataClass implements Insertable<Trainer> {
  final int id;
  final int workspaceId;
  final String trainerId;
  final String name;
  final String? specialty;
  final String? city;
  final String? trainerType;
  final int? maxDaysPerMonth;
  final int? maxConsecutiveDays;
  final double? costPerDay;
  final String? notes;
  const Trainer(
      {required this.id,
      required this.workspaceId,
      required this.trainerId,
      required this.name,
      this.specialty,
      this.city,
      this.trainerType,
      this.maxDaysPerMonth,
      this.maxConsecutiveDays,
      this.costPerDay,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['trainer_id'] = Variable<String>(trainerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || specialty != null) {
      map['specialty'] = Variable<String>(specialty);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || trainerType != null) {
      map['trainer_type'] = Variable<String>(trainerType);
    }
    if (!nullToAbsent || maxDaysPerMonth != null) {
      map['max_days_per_month'] = Variable<int>(maxDaysPerMonth);
    }
    if (!nullToAbsent || maxConsecutiveDays != null) {
      map['max_consecutive_days'] = Variable<int>(maxConsecutiveDays);
    }
    if (!nullToAbsent || costPerDay != null) {
      map['cost_per_day'] = Variable<double>(costPerDay);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TrainersCompanion toCompanion(bool nullToAbsent) {
    return TrainersCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      trainerId: Value(trainerId),
      name: Value(name),
      specialty: specialty == null && nullToAbsent
          ? const Value.absent()
          : Value(specialty),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      trainerType: trainerType == null && nullToAbsent
          ? const Value.absent()
          : Value(trainerType),
      maxDaysPerMonth: maxDaysPerMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(maxDaysPerMonth),
      maxConsecutiveDays: maxConsecutiveDays == null && nullToAbsent
          ? const Value.absent()
          : Value(maxConsecutiveDays),
      costPerDay: costPerDay == null && nullToAbsent
          ? const Value.absent()
          : Value(costPerDay),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Trainer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trainer(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      trainerId: serializer.fromJson<String>(json['trainerId']),
      name: serializer.fromJson<String>(json['name']),
      specialty: serializer.fromJson<String?>(json['specialty']),
      city: serializer.fromJson<String?>(json['city']),
      trainerType: serializer.fromJson<String?>(json['trainerType']),
      maxDaysPerMonth: serializer.fromJson<int?>(json['maxDaysPerMonth']),
      maxConsecutiveDays: serializer.fromJson<int?>(json['maxConsecutiveDays']),
      costPerDay: serializer.fromJson<double?>(json['costPerDay']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'trainerId': serializer.toJson<String>(trainerId),
      'name': serializer.toJson<String>(name),
      'specialty': serializer.toJson<String?>(specialty),
      'city': serializer.toJson<String?>(city),
      'trainerType': serializer.toJson<String?>(trainerType),
      'maxDaysPerMonth': serializer.toJson<int?>(maxDaysPerMonth),
      'maxConsecutiveDays': serializer.toJson<int?>(maxConsecutiveDays),
      'costPerDay': serializer.toJson<double?>(costPerDay),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Trainer copyWith(
          {int? id,
          int? workspaceId,
          String? trainerId,
          String? name,
          Value<String?> specialty = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> trainerType = const Value.absent(),
          Value<int?> maxDaysPerMonth = const Value.absent(),
          Value<int?> maxConsecutiveDays = const Value.absent(),
          Value<double?> costPerDay = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      Trainer(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        trainerId: trainerId ?? this.trainerId,
        name: name ?? this.name,
        specialty: specialty.present ? specialty.value : this.specialty,
        city: city.present ? city.value : this.city,
        trainerType: trainerType.present ? trainerType.value : this.trainerType,
        maxDaysPerMonth: maxDaysPerMonth.present
            ? maxDaysPerMonth.value
            : this.maxDaysPerMonth,
        maxConsecutiveDays: maxConsecutiveDays.present
            ? maxConsecutiveDays.value
            : this.maxConsecutiveDays,
        costPerDay: costPerDay.present ? costPerDay.value : this.costPerDay,
        notes: notes.present ? notes.value : this.notes,
      );
  Trainer copyWithCompanion(TrainersCompanion data) {
    return Trainer(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      trainerId: data.trainerId.present ? data.trainerId.value : this.trainerId,
      name: data.name.present ? data.name.value : this.name,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      city: data.city.present ? data.city.value : this.city,
      trainerType:
          data.trainerType.present ? data.trainerType.value : this.trainerType,
      maxDaysPerMonth: data.maxDaysPerMonth.present
          ? data.maxDaysPerMonth.value
          : this.maxDaysPerMonth,
      maxConsecutiveDays: data.maxConsecutiveDays.present
          ? data.maxConsecutiveDays.value
          : this.maxConsecutiveDays,
      costPerDay:
          data.costPerDay.present ? data.costPerDay.value : this.costPerDay,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trainer(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('trainerId: $trainerId, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('city: $city, ')
          ..write('trainerType: $trainerType, ')
          ..write('maxDaysPerMonth: $maxDaysPerMonth, ')
          ..write('maxConsecutiveDays: $maxConsecutiveDays, ')
          ..write('costPerDay: $costPerDay, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      workspaceId,
      trainerId,
      name,
      specialty,
      city,
      trainerType,
      maxDaysPerMonth,
      maxConsecutiveDays,
      costPerDay,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trainer &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.trainerId == this.trainerId &&
          other.name == this.name &&
          other.specialty == this.specialty &&
          other.city == this.city &&
          other.trainerType == this.trainerType &&
          other.maxDaysPerMonth == this.maxDaysPerMonth &&
          other.maxConsecutiveDays == this.maxConsecutiveDays &&
          other.costPerDay == this.costPerDay &&
          other.notes == this.notes);
}

class TrainersCompanion extends UpdateCompanion<Trainer> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> trainerId;
  final Value<String> name;
  final Value<String?> specialty;
  final Value<String?> city;
  final Value<String?> trainerType;
  final Value<int?> maxDaysPerMonth;
  final Value<int?> maxConsecutiveDays;
  final Value<double?> costPerDay;
  final Value<String?> notes;
  const TrainersCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.trainerId = const Value.absent(),
    this.name = const Value.absent(),
    this.specialty = const Value.absent(),
    this.city = const Value.absent(),
    this.trainerType = const Value.absent(),
    this.maxDaysPerMonth = const Value.absent(),
    this.maxConsecutiveDays = const Value.absent(),
    this.costPerDay = const Value.absent(),
    this.notes = const Value.absent(),
  });
  TrainersCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String trainerId,
    required String name,
    this.specialty = const Value.absent(),
    this.city = const Value.absent(),
    this.trainerType = const Value.absent(),
    this.maxDaysPerMonth = const Value.absent(),
    this.maxConsecutiveDays = const Value.absent(),
    this.costPerDay = const Value.absent(),
    this.notes = const Value.absent(),
  })  : workspaceId = Value(workspaceId),
        trainerId = Value(trainerId),
        name = Value(name);
  static Insertable<Trainer> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? trainerId,
    Expression<String>? name,
    Expression<String>? specialty,
    Expression<String>? city,
    Expression<String>? trainerType,
    Expression<int>? maxDaysPerMonth,
    Expression<int>? maxConsecutiveDays,
    Expression<double>? costPerDay,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (trainerId != null) 'trainer_id': trainerId,
      if (name != null) 'name': name,
      if (specialty != null) 'specialty': specialty,
      if (city != null) 'city': city,
      if (trainerType != null) 'trainer_type': trainerType,
      if (maxDaysPerMonth != null) 'max_days_per_month': maxDaysPerMonth,
      if (maxConsecutiveDays != null)
        'max_consecutive_days': maxConsecutiveDays,
      if (costPerDay != null) 'cost_per_day': costPerDay,
      if (notes != null) 'notes': notes,
    });
  }

  TrainersCompanion copyWith(
      {Value<int>? id,
      Value<int>? workspaceId,
      Value<String>? trainerId,
      Value<String>? name,
      Value<String?>? specialty,
      Value<String?>? city,
      Value<String?>? trainerType,
      Value<int?>? maxDaysPerMonth,
      Value<int?>? maxConsecutiveDays,
      Value<double?>? costPerDay,
      Value<String?>? notes}) {
    return TrainersCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      trainerId: trainerId ?? this.trainerId,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      city: city ?? this.city,
      trainerType: trainerType ?? this.trainerType,
      maxDaysPerMonth: maxDaysPerMonth ?? this.maxDaysPerMonth,
      maxConsecutiveDays: maxConsecutiveDays ?? this.maxConsecutiveDays,
      costPerDay: costPerDay ?? this.costPerDay,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (trainerId.present) {
      map['trainer_id'] = Variable<String>(trainerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (trainerType.present) {
      map['trainer_type'] = Variable<String>(trainerType.value);
    }
    if (maxDaysPerMonth.present) {
      map['max_days_per_month'] = Variable<int>(maxDaysPerMonth.value);
    }
    if (maxConsecutiveDays.present) {
      map['max_consecutive_days'] = Variable<int>(maxConsecutiveDays.value);
    }
    if (costPerDay.present) {
      map['cost_per_day'] = Variable<double>(costPerDay.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainersCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('trainerId: $trainerId, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('city: $city, ')
          ..write('trainerType: $trainerType, ')
          ..write('maxDaysPerMonth: $maxDaysPerMonth, ')
          ..write('maxConsecutiveDays: $maxConsecutiveDays, ')
          ..write('costPerDay: $costPerDay, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $VenuesTable extends Venues with TableInfo<$VenuesTable, Venue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VenuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_workspaces (id)'));
  static const VerificationMeta _venueIdMeta =
      const VerificationMeta('venueId');
  @override
  late final GeneratedColumn<String> venueId = GeneratedColumn<String>(
      'venue_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _capacityMeta =
      const VerificationMeta('capacity');
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
      'capacity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _venueTypeMeta =
      const VerificationMeta('venueType');
  @override
  late final GeneratedColumn<String> venueType = GeneratedColumn<String>(
      'venue_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _availableFromMeta =
      const VerificationMeta('availableFrom');
  @override
  late final GeneratedColumn<DateTime> availableFrom =
      GeneratedColumn<DateTime>('available_from', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _availableToMeta =
      const VerificationMeta('availableTo');
  @override
  late final GeneratedColumn<DateTime> availableTo = GeneratedColumn<DateTime>(
      'available_to', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _equipmentNotesMeta =
      const VerificationMeta('equipmentNotes');
  @override
  late final GeneratedColumn<String> equipmentNotes = GeneratedColumn<String>(
      'equipment_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workspaceId,
        venueId,
        name,
        capacity,
        venueType,
        city,
        availableFrom,
        availableTo,
        equipmentNotes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'venues';
  @override
  VerificationContext validateIntegrity(Insertable<Venue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('venue_id')) {
      context.handle(_venueIdMeta,
          venueId.isAcceptableOrUnknown(data['venue_id']!, _venueIdMeta));
    } else if (isInserting) {
      context.missing(_venueIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(_capacityMeta,
          capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta));
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('venue_type')) {
      context.handle(_venueTypeMeta,
          venueType.isAcceptableOrUnknown(data['venue_type']!, _venueTypeMeta));
    } else if (isInserting) {
      context.missing(_venueTypeMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('available_from')) {
      context.handle(
          _availableFromMeta,
          availableFrom.isAcceptableOrUnknown(
              data['available_from']!, _availableFromMeta));
    }
    if (data.containsKey('available_to')) {
      context.handle(
          _availableToMeta,
          availableTo.isAcceptableOrUnknown(
              data['available_to']!, _availableToMeta));
    }
    if (data.containsKey('equipment_notes')) {
      context.handle(
          _equipmentNotesMeta,
          equipmentNotes.isAcceptableOrUnknown(
              data['equipment_notes']!, _equipmentNotesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Venue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Venue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workspace_id'])!,
      venueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      capacity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}capacity'])!,
      venueType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue_type'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      availableFrom: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}available_from']),
      availableTo: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}available_to']),
      equipmentNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipment_notes']),
    );
  }

  @override
  $VenuesTable createAlias(String alias) {
    return $VenuesTable(attachedDatabase, alias);
  }
}

class Venue extends DataClass implements Insertable<Venue> {
  final int id;
  final int workspaceId;
  final String venueId;
  final String name;
  final int capacity;
  final String venueType;
  final String? city;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final String? equipmentNotes;
  const Venue(
      {required this.id,
      required this.workspaceId,
      required this.venueId,
      required this.name,
      required this.capacity,
      required this.venueType,
      this.city,
      this.availableFrom,
      this.availableTo,
      this.equipmentNotes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['venue_id'] = Variable<String>(venueId);
    map['name'] = Variable<String>(name);
    map['capacity'] = Variable<int>(capacity);
    map['venue_type'] = Variable<String>(venueType);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || availableFrom != null) {
      map['available_from'] = Variable<DateTime>(availableFrom);
    }
    if (!nullToAbsent || availableTo != null) {
      map['available_to'] = Variable<DateTime>(availableTo);
    }
    if (!nullToAbsent || equipmentNotes != null) {
      map['equipment_notes'] = Variable<String>(equipmentNotes);
    }
    return map;
  }

  VenuesCompanion toCompanion(bool nullToAbsent) {
    return VenuesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      venueId: Value(venueId),
      name: Value(name),
      capacity: Value(capacity),
      venueType: Value(venueType),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      availableFrom: availableFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(availableFrom),
      availableTo: availableTo == null && nullToAbsent
          ? const Value.absent()
          : Value(availableTo),
      equipmentNotes: equipmentNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentNotes),
    );
  }

  factory Venue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Venue(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      venueId: serializer.fromJson<String>(json['venueId']),
      name: serializer.fromJson<String>(json['name']),
      capacity: serializer.fromJson<int>(json['capacity']),
      venueType: serializer.fromJson<String>(json['venueType']),
      city: serializer.fromJson<String?>(json['city']),
      availableFrom: serializer.fromJson<DateTime?>(json['availableFrom']),
      availableTo: serializer.fromJson<DateTime?>(json['availableTo']),
      equipmentNotes: serializer.fromJson<String?>(json['equipmentNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'venueId': serializer.toJson<String>(venueId),
      'name': serializer.toJson<String>(name),
      'capacity': serializer.toJson<int>(capacity),
      'venueType': serializer.toJson<String>(venueType),
      'city': serializer.toJson<String?>(city),
      'availableFrom': serializer.toJson<DateTime?>(availableFrom),
      'availableTo': serializer.toJson<DateTime?>(availableTo),
      'equipmentNotes': serializer.toJson<String?>(equipmentNotes),
    };
  }

  Venue copyWith(
          {int? id,
          int? workspaceId,
          String? venueId,
          String? name,
          int? capacity,
          String? venueType,
          Value<String?> city = const Value.absent(),
          Value<DateTime?> availableFrom = const Value.absent(),
          Value<DateTime?> availableTo = const Value.absent(),
          Value<String?> equipmentNotes = const Value.absent()}) =>
      Venue(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        venueId: venueId ?? this.venueId,
        name: name ?? this.name,
        capacity: capacity ?? this.capacity,
        venueType: venueType ?? this.venueType,
        city: city.present ? city.value : this.city,
        availableFrom:
            availableFrom.present ? availableFrom.value : this.availableFrom,
        availableTo: availableTo.present ? availableTo.value : this.availableTo,
        equipmentNotes:
            equipmentNotes.present ? equipmentNotes.value : this.equipmentNotes,
      );
  Venue copyWithCompanion(VenuesCompanion data) {
    return Venue(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      venueId: data.venueId.present ? data.venueId.value : this.venueId,
      name: data.name.present ? data.name.value : this.name,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      venueType: data.venueType.present ? data.venueType.value : this.venueType,
      city: data.city.present ? data.city.value : this.city,
      availableFrom: data.availableFrom.present
          ? data.availableFrom.value
          : this.availableFrom,
      availableTo:
          data.availableTo.present ? data.availableTo.value : this.availableTo,
      equipmentNotes: data.equipmentNotes.present
          ? data.equipmentNotes.value
          : this.equipmentNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Venue(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('venueId: $venueId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('venueType: $venueType, ')
          ..write('city: $city, ')
          ..write('availableFrom: $availableFrom, ')
          ..write('availableTo: $availableTo, ')
          ..write('equipmentNotes: $equipmentNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workspaceId, venueId, name, capacity,
      venueType, city, availableFrom, availableTo, equipmentNotes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Venue &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.venueId == this.venueId &&
          other.name == this.name &&
          other.capacity == this.capacity &&
          other.venueType == this.venueType &&
          other.city == this.city &&
          other.availableFrom == this.availableFrom &&
          other.availableTo == this.availableTo &&
          other.equipmentNotes == this.equipmentNotes);
}

class VenuesCompanion extends UpdateCompanion<Venue> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> venueId;
  final Value<String> name;
  final Value<int> capacity;
  final Value<String> venueType;
  final Value<String?> city;
  final Value<DateTime?> availableFrom;
  final Value<DateTime?> availableTo;
  final Value<String?> equipmentNotes;
  const VenuesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.venueId = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.venueType = const Value.absent(),
    this.city = const Value.absent(),
    this.availableFrom = const Value.absent(),
    this.availableTo = const Value.absent(),
    this.equipmentNotes = const Value.absent(),
  });
  VenuesCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String venueId,
    required String name,
    required int capacity,
    required String venueType,
    this.city = const Value.absent(),
    this.availableFrom = const Value.absent(),
    this.availableTo = const Value.absent(),
    this.equipmentNotes = const Value.absent(),
  })  : workspaceId = Value(workspaceId),
        venueId = Value(venueId),
        name = Value(name),
        capacity = Value(capacity),
        venueType = Value(venueType);
  static Insertable<Venue> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? venueId,
    Expression<String>? name,
    Expression<int>? capacity,
    Expression<String>? venueType,
    Expression<String>? city,
    Expression<DateTime>? availableFrom,
    Expression<DateTime>? availableTo,
    Expression<String>? equipmentNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (venueId != null) 'venue_id': venueId,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (venueType != null) 'venue_type': venueType,
      if (city != null) 'city': city,
      if (availableFrom != null) 'available_from': availableFrom,
      if (availableTo != null) 'available_to': availableTo,
      if (equipmentNotes != null) 'equipment_notes': equipmentNotes,
    });
  }

  VenuesCompanion copyWith(
      {Value<int>? id,
      Value<int>? workspaceId,
      Value<String>? venueId,
      Value<String>? name,
      Value<int>? capacity,
      Value<String>? venueType,
      Value<String?>? city,
      Value<DateTime?>? availableFrom,
      Value<DateTime?>? availableTo,
      Value<String?>? equipmentNotes}) {
    return VenuesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      venueType: venueType ?? this.venueType,
      city: city ?? this.city,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      equipmentNotes: equipmentNotes ?? this.equipmentNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (venueId.present) {
      map['venue_id'] = Variable<String>(venueId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (venueType.present) {
      map['venue_type'] = Variable<String>(venueType.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (availableFrom.present) {
      map['available_from'] = Variable<DateTime>(availableFrom.value);
    }
    if (availableTo.present) {
      map['available_to'] = Variable<DateTime>(availableTo.value);
    }
    if (equipmentNotes.present) {
      map['equipment_notes'] = Variable<String>(equipmentNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VenuesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('venueId: $venueId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('venueType: $venueType, ')
          ..write('city: $city, ')
          ..write('availableFrom: $availableFrom, ')
          ..write('availableTo: $availableTo, ')
          ..write('equipmentNotes: $equipmentNotes')
          ..write(')'))
        .toString();
  }
}

class $CalendarDaysTable extends CalendarDays
    with TableInfo<$CalendarDaysTable, CalendarDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_workspaces (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isWorkingDayMeta =
      const VerificationMeta('isWorkingDay');
  @override
  late final GeneratedColumn<bool> isWorkingDay = GeneratedColumn<bool>(
      'is_working_day', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_working_day" IN (0, 1))'));
  static const VerificationMeta _isHolidayMeta =
      const VerificationMeta('isHoliday');
  @override
  late final GeneratedColumn<bool> isHoliday = GeneratedColumn<bool>(
      'is_holiday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_holiday" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, workspaceId, date, isWorkingDay, isHoliday];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_days';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_working_day')) {
      context.handle(
          _isWorkingDayMeta,
          isWorkingDay.isAcceptableOrUnknown(
              data['is_working_day']!, _isWorkingDayMeta));
    } else if (isInserting) {
      context.missing(_isWorkingDayMeta);
    }
    if (data.containsKey('is_holiday')) {
      context.handle(_isHolidayMeta,
          isHoliday.isAcceptableOrUnknown(data['is_holiday']!, _isHolidayMeta));
    } else if (isInserting) {
      context.missing(_isHolidayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarDay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workspace_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      isWorkingDay: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_working_day'])!,
      isHoliday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_holiday'])!,
    );
  }

  @override
  $CalendarDaysTable createAlias(String alias) {
    return $CalendarDaysTable(attachedDatabase, alias);
  }
}

class CalendarDay extends DataClass implements Insertable<CalendarDay> {
  final int id;
  final int workspaceId;
  final DateTime date;
  final bool isWorkingDay;
  final bool isHoliday;
  const CalendarDay(
      {required this.id,
      required this.workspaceId,
      required this.date,
      required this.isWorkingDay,
      required this.isHoliday});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['date'] = Variable<DateTime>(date);
    map['is_working_day'] = Variable<bool>(isWorkingDay);
    map['is_holiday'] = Variable<bool>(isHoliday);
    return map;
  }

  CalendarDaysCompanion toCompanion(bool nullToAbsent) {
    return CalendarDaysCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      date: Value(date),
      isWorkingDay: Value(isWorkingDay),
      isHoliday: Value(isHoliday),
    );
  }

  factory CalendarDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarDay(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      isWorkingDay: serializer.fromJson<bool>(json['isWorkingDay']),
      isHoliday: serializer.fromJson<bool>(json['isHoliday']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'date': serializer.toJson<DateTime>(date),
      'isWorkingDay': serializer.toJson<bool>(isWorkingDay),
      'isHoliday': serializer.toJson<bool>(isHoliday),
    };
  }

  CalendarDay copyWith(
          {int? id,
          int? workspaceId,
          DateTime? date,
          bool? isWorkingDay,
          bool? isHoliday}) =>
      CalendarDay(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        date: date ?? this.date,
        isWorkingDay: isWorkingDay ?? this.isWorkingDay,
        isHoliday: isHoliday ?? this.isHoliday,
      );
  CalendarDay copyWithCompanion(CalendarDaysCompanion data) {
    return CalendarDay(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      date: data.date.present ? data.date.value : this.date,
      isWorkingDay: data.isWorkingDay.present
          ? data.isWorkingDay.value
          : this.isWorkingDay,
      isHoliday: data.isHoliday.present ? data.isHoliday.value : this.isHoliday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarDay(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('date: $date, ')
          ..write('isWorkingDay: $isWorkingDay, ')
          ..write('isHoliday: $isHoliday')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workspaceId, date, isWorkingDay, isHoliday);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarDay &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.date == this.date &&
          other.isWorkingDay == this.isWorkingDay &&
          other.isHoliday == this.isHoliday);
}

class CalendarDaysCompanion extends UpdateCompanion<CalendarDay> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<DateTime> date;
  final Value<bool> isWorkingDay;
  final Value<bool> isHoliday;
  const CalendarDaysCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.date = const Value.absent(),
    this.isWorkingDay = const Value.absent(),
    this.isHoliday = const Value.absent(),
  });
  CalendarDaysCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required DateTime date,
    required bool isWorkingDay,
    required bool isHoliday,
  })  : workspaceId = Value(workspaceId),
        date = Value(date),
        isWorkingDay = Value(isWorkingDay),
        isHoliday = Value(isHoliday);
  static Insertable<CalendarDay> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<DateTime>? date,
    Expression<bool>? isWorkingDay,
    Expression<bool>? isHoliday,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (date != null) 'date': date,
      if (isWorkingDay != null) 'is_working_day': isWorkingDay,
      if (isHoliday != null) 'is_holiday': isHoliday,
    });
  }

  CalendarDaysCompanion copyWith(
      {Value<int>? id,
      Value<int>? workspaceId,
      Value<DateTime>? date,
      Value<bool>? isWorkingDay,
      Value<bool>? isHoliday}) {
    return CalendarDaysCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      date: date ?? this.date,
      isWorkingDay: isWorkingDay ?? this.isWorkingDay,
      isHoliday: isHoliday ?? this.isHoliday,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isWorkingDay.present) {
      map['is_working_day'] = Variable<bool>(isWorkingDay.value);
    }
    if (isHoliday.present) {
      map['is_holiday'] = Variable<bool>(isHoliday.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarDaysCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('date: $date, ')
          ..write('isWorkingDay: $isWorkingDay, ')
          ..write('isHoliday: $isHoliday')
          ..write(')'))
        .toString();
  }
}

class $AssignedCoursesTable extends AssignedCourses
    with TableInfo<$AssignedCoursesTable, AssignedCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignedCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_workspaces (id)'));
  static const VerificationMeta _assignedIdMeta =
      const VerificationMeta('assignedId');
  @override
  late final GeneratedColumn<String> assignedId = GeneratedColumn<String>(
      'assigned_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trainerIdMeta =
      const VerificationMeta('trainerId');
  @override
  late final GeneratedColumn<String> trainerId = GeneratedColumn<String>(
      'trainer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('not executed'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, workspaceId, assignedId, courseId, trainerId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assigned_courses';
  @override
  VerificationContext validateIntegrity(Insertable<AssignedCourse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('assigned_id')) {
      context.handle(
          _assignedIdMeta,
          assignedId.isAcceptableOrUnknown(
              data['assigned_id']!, _assignedIdMeta));
    } else if (isInserting) {
      context.missing(_assignedIdMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('trainer_id')) {
      context.handle(_trainerIdMeta,
          trainerId.isAcceptableOrUnknown(data['trainer_id']!, _trainerIdMeta));
    } else if (isInserting) {
      context.missing(_trainerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssignedCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignedCourse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workspace_id'])!,
      assignedId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assigned_id'])!,
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      trainerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trainer_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $AssignedCoursesTable createAlias(String alias) {
    return $AssignedCoursesTable(attachedDatabase, alias);
  }
}

class AssignedCourse extends DataClass implements Insertable<AssignedCourse> {
  final int id;
  final int workspaceId;
  final String assignedId;
  final String courseId;
  final String trainerId;
  final String status;
  const AssignedCourse(
      {required this.id,
      required this.workspaceId,
      required this.assignedId,
      required this.courseId,
      required this.trainerId,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['assigned_id'] = Variable<String>(assignedId);
    map['course_id'] = Variable<String>(courseId);
    map['trainer_id'] = Variable<String>(trainerId);
    map['status'] = Variable<String>(status);
    return map;
  }

  AssignedCoursesCompanion toCompanion(bool nullToAbsent) {
    return AssignedCoursesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      assignedId: Value(assignedId),
      courseId: Value(courseId),
      trainerId: Value(trainerId),
      status: Value(status),
    );
  }

  factory AssignedCourse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignedCourse(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      assignedId: serializer.fromJson<String>(json['assignedId']),
      courseId: serializer.fromJson<String>(json['courseId']),
      trainerId: serializer.fromJson<String>(json['trainerId']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'assignedId': serializer.toJson<String>(assignedId),
      'courseId': serializer.toJson<String>(courseId),
      'trainerId': serializer.toJson<String>(trainerId),
      'status': serializer.toJson<String>(status),
    };
  }

  AssignedCourse copyWith(
          {int? id,
          int? workspaceId,
          String? assignedId,
          String? courseId,
          String? trainerId,
          String? status}) =>
      AssignedCourse(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        assignedId: assignedId ?? this.assignedId,
        courseId: courseId ?? this.courseId,
        trainerId: trainerId ?? this.trainerId,
        status: status ?? this.status,
      );
  AssignedCourse copyWithCompanion(AssignedCoursesCompanion data) {
    return AssignedCourse(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      assignedId:
          data.assignedId.present ? data.assignedId.value : this.assignedId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      trainerId: data.trainerId.present ? data.trainerId.value : this.trainerId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignedCourse(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('assignedId: $assignedId, ')
          ..write('courseId: $courseId, ')
          ..write('trainerId: $trainerId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workspaceId, assignedId, courseId, trainerId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignedCourse &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.assignedId == this.assignedId &&
          other.courseId == this.courseId &&
          other.trainerId == this.trainerId &&
          other.status == this.status);
}

class AssignedCoursesCompanion extends UpdateCompanion<AssignedCourse> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> assignedId;
  final Value<String> courseId;
  final Value<String> trainerId;
  final Value<String> status;
  const AssignedCoursesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.assignedId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.trainerId = const Value.absent(),
    this.status = const Value.absent(),
  });
  AssignedCoursesCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String assignedId,
    required String courseId,
    required String trainerId,
    this.status = const Value.absent(),
  })  : workspaceId = Value(workspaceId),
        assignedId = Value(assignedId),
        courseId = Value(courseId),
        trainerId = Value(trainerId);
  static Insertable<AssignedCourse> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? assignedId,
    Expression<String>? courseId,
    Expression<String>? trainerId,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (assignedId != null) 'assigned_id': assignedId,
      if (courseId != null) 'course_id': courseId,
      if (trainerId != null) 'trainer_id': trainerId,
      if (status != null) 'status': status,
    });
  }

  AssignedCoursesCompanion copyWith(
      {Value<int>? id,
      Value<int>? workspaceId,
      Value<String>? assignedId,
      Value<String>? courseId,
      Value<String>? trainerId,
      Value<String>? status}) {
    return AssignedCoursesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      assignedId: assignedId ?? this.assignedId,
      courseId: courseId ?? this.courseId,
      trainerId: trainerId ?? this.trainerId,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (assignedId.present) {
      map['assigned_id'] = Variable<String>(assignedId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (trainerId.present) {
      map['trainer_id'] = Variable<String>(trainerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignedCoursesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('assignedId: $assignedId, ')
          ..write('courseId: $courseId, ')
          ..write('trainerId: $trainerId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TrainerUnavailableDatesTable extends TrainerUnavailableDates
    with TableInfo<$TrainerUnavailableDatesTable, TrainerUnavailableDate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainerUnavailableDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _trainerIdMeta =
      const VerificationMeta('trainerId');
  @override
  late final GeneratedColumn<int> trainerId = GeneratedColumn<int>(
      'trainer_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES trainers (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, trainerId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trainer_unavailable_dates';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrainerUnavailableDate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trainer_id')) {
      context.handle(_trainerIdMeta,
          trainerId.isAcceptableOrUnknown(data['trainer_id']!, _trainerIdMeta));
    } else if (isInserting) {
      context.missing(_trainerIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainerUnavailableDate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainerUnavailableDate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      trainerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}trainer_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $TrainerUnavailableDatesTable createAlias(String alias) {
    return $TrainerUnavailableDatesTable(attachedDatabase, alias);
  }
}

class TrainerUnavailableDate extends DataClass
    implements Insertable<TrainerUnavailableDate> {
  final int id;
  final int trainerId;
  final DateTime date;
  const TrainerUnavailableDate(
      {required this.id, required this.trainerId, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trainer_id'] = Variable<int>(trainerId);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  TrainerUnavailableDatesCompanion toCompanion(bool nullToAbsent) {
    return TrainerUnavailableDatesCompanion(
      id: Value(id),
      trainerId: Value(trainerId),
      date: Value(date),
    );
  }

  factory TrainerUnavailableDate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainerUnavailableDate(
      id: serializer.fromJson<int>(json['id']),
      trainerId: serializer.fromJson<int>(json['trainerId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trainerId': serializer.toJson<int>(trainerId),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  TrainerUnavailableDate copyWith({int? id, int? trainerId, DateTime? date}) =>
      TrainerUnavailableDate(
        id: id ?? this.id,
        trainerId: trainerId ?? this.trainerId,
        date: date ?? this.date,
      );
  TrainerUnavailableDate copyWithCompanion(
      TrainerUnavailableDatesCompanion data) {
    return TrainerUnavailableDate(
      id: data.id.present ? data.id.value : this.id,
      trainerId: data.trainerId.present ? data.trainerId.value : this.trainerId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainerUnavailableDate(')
          ..write('id: $id, ')
          ..write('trainerId: $trainerId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trainerId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainerUnavailableDate &&
          other.id == this.id &&
          other.trainerId == this.trainerId &&
          other.date == this.date);
}

class TrainerUnavailableDatesCompanion
    extends UpdateCompanion<TrainerUnavailableDate> {
  final Value<int> id;
  final Value<int> trainerId;
  final Value<DateTime> date;
  const TrainerUnavailableDatesCompanion({
    this.id = const Value.absent(),
    this.trainerId = const Value.absent(),
    this.date = const Value.absent(),
  });
  TrainerUnavailableDatesCompanion.insert({
    this.id = const Value.absent(),
    required int trainerId,
    required DateTime date,
  })  : trainerId = Value(trainerId),
        date = Value(date);
  static Insertable<TrainerUnavailableDate> custom({
    Expression<int>? id,
    Expression<int>? trainerId,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trainerId != null) 'trainer_id': trainerId,
      if (date != null) 'date': date,
    });
  }

  TrainerUnavailableDatesCompanion copyWith(
      {Value<int>? id, Value<int>? trainerId, Value<DateTime>? date}) {
    return TrainerUnavailableDatesCompanion(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trainerId.present) {
      map['trainer_id'] = Variable<int>(trainerId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainerUnavailableDatesCompanion(')
          ..write('id: $id, ')
          ..write('trainerId: $trainerId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $VenueUnavailableDatesTable extends VenueUnavailableDates
    with TableInfo<$VenueUnavailableDatesTable, VenueUnavailableDate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VenueUnavailableDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _venueIdMeta =
      const VerificationMeta('venueId');
  @override
  late final GeneratedColumn<int> venueId = GeneratedColumn<int>(
      'venue_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES venues (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, venueId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'venue_unavailable_dates';
  @override
  VerificationContext validateIntegrity(
      Insertable<VenueUnavailableDate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venue_id')) {
      context.handle(_venueIdMeta,
          venueId.isAcceptableOrUnknown(data['venue_id']!, _venueIdMeta));
    } else if (isInserting) {
      context.missing(_venueIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VenueUnavailableDate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VenueUnavailableDate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      venueId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}venue_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $VenueUnavailableDatesTable createAlias(String alias) {
    return $VenueUnavailableDatesTable(attachedDatabase, alias);
  }
}

class VenueUnavailableDate extends DataClass
    implements Insertable<VenueUnavailableDate> {
  final int id;
  final int venueId;
  final DateTime date;
  const VenueUnavailableDate(
      {required this.id, required this.venueId, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venue_id'] = Variable<int>(venueId);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  VenueUnavailableDatesCompanion toCompanion(bool nullToAbsent) {
    return VenueUnavailableDatesCompanion(
      id: Value(id),
      venueId: Value(venueId),
      date: Value(date),
    );
  }

  factory VenueUnavailableDate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VenueUnavailableDate(
      id: serializer.fromJson<int>(json['id']),
      venueId: serializer.fromJson<int>(json['venueId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'venueId': serializer.toJson<int>(venueId),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  VenueUnavailableDate copyWith({int? id, int? venueId, DateTime? date}) =>
      VenueUnavailableDate(
        id: id ?? this.id,
        venueId: venueId ?? this.venueId,
        date: date ?? this.date,
      );
  VenueUnavailableDate copyWithCompanion(VenueUnavailableDatesCompanion data) {
    return VenueUnavailableDate(
      id: data.id.present ? data.id.value : this.id,
      venueId: data.venueId.present ? data.venueId.value : this.venueId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VenueUnavailableDate(')
          ..write('id: $id, ')
          ..write('venueId: $venueId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, venueId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VenueUnavailableDate &&
          other.id == this.id &&
          other.venueId == this.venueId &&
          other.date == this.date);
}

class VenueUnavailableDatesCompanion
    extends UpdateCompanion<VenueUnavailableDate> {
  final Value<int> id;
  final Value<int> venueId;
  final Value<DateTime> date;
  const VenueUnavailableDatesCompanion({
    this.id = const Value.absent(),
    this.venueId = const Value.absent(),
    this.date = const Value.absent(),
  });
  VenueUnavailableDatesCompanion.insert({
    this.id = const Value.absent(),
    required int venueId,
    required DateTime date,
  })  : venueId = Value(venueId),
        date = Value(date);
  static Insertable<VenueUnavailableDate> custom({
    Expression<int>? id,
    Expression<int>? venueId,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (venueId != null) 'venue_id': venueId,
      if (date != null) 'date': date,
    });
  }

  VenueUnavailableDatesCompanion copyWith(
      {Value<int>? id, Value<int>? venueId, Value<DateTime>? date}) {
    return VenueUnavailableDatesCompanion(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (venueId.present) {
      map['venue_id'] = Variable<int>(venueId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VenueUnavailableDatesCompanion(')
          ..write('id: $id, ')
          ..write('venueId: $venueId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_workspaces (id)'));
  static const VerificationMeta _assignedCourseIdMeta =
      const VerificationMeta('assignedCourseId');
  @override
  late final GeneratedColumn<String> assignedCourseId = GeneratedColumn<String>(
      'assigned_course_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _venueIdMeta =
      const VerificationMeta('venueId');
  @override
  late final GeneratedColumn<String> venueId = GeneratedColumn<String>(
      'venue_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('not executed'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, workspaceId, assignedCourseId, venueId, startDate, endDate, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<Schedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('assigned_course_id')) {
      context.handle(
          _assignedCourseIdMeta,
          assignedCourseId.isAcceptableOrUnknown(
              data['assigned_course_id']!, _assignedCourseIdMeta));
    } else if (isInserting) {
      context.missing(_assignedCourseIdMeta);
    }
    if (data.containsKey('venue_id')) {
      context.handle(_venueIdMeta,
          venueId.isAcceptableOrUnknown(data['venue_id']!, _venueIdMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workspace_id'])!,
      assignedCourseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assigned_course_id'])!,
      venueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue_id']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final int workspaceId;
  final String assignedCourseId;
  final String? venueId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  const Schedule(
      {required this.id,
      required this.workspaceId,
      required this.assignedCourseId,
      this.venueId,
      required this.startDate,
      required this.endDate,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['assigned_course_id'] = Variable<String>(assignedCourseId);
    if (!nullToAbsent || venueId != null) {
      map['venue_id'] = Variable<String>(venueId);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      assignedCourseId: Value(assignedCourseId),
      venueId: venueId == null && nullToAbsent
          ? const Value.absent()
          : Value(venueId),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      assignedCourseId: serializer.fromJson<String>(json['assignedCourseId']),
      venueId: serializer.fromJson<String?>(json['venueId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'assignedCourseId': serializer.toJson<String>(assignedCourseId),
      'venueId': serializer.toJson<String?>(venueId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
    };
  }

  Schedule copyWith(
          {int? id,
          int? workspaceId,
          String? assignedCourseId,
          Value<String?> venueId = const Value.absent(),
          DateTime? startDate,
          DateTime? endDate,
          String? status}) =>
      Schedule(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        assignedCourseId: assignedCourseId ?? this.assignedCourseId,
        venueId: venueId.present ? venueId.value : this.venueId,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
      );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      assignedCourseId: data.assignedCourseId.present
          ? data.assignedCourseId.value
          : this.assignedCourseId,
      venueId: data.venueId.present ? data.venueId.value : this.venueId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('assignedCourseId: $assignedCourseId, ')
          ..write('venueId: $venueId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, workspaceId, assignedCourseId, venueId, startDate, endDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.assignedCourseId == this.assignedCourseId &&
          other.venueId == this.venueId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> assignedCourseId;
  final Value<String?> venueId;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.assignedCourseId = const Value.absent(),
    this.venueId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String assignedCourseId,
    this.venueId = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    this.status = const Value.absent(),
  })  : workspaceId = Value(workspaceId),
        assignedCourseId = Value(assignedCourseId),
        startDate = Value(startDate),
        endDate = Value(endDate);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? assignedCourseId,
    Expression<String>? venueId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (assignedCourseId != null) 'assigned_course_id': assignedCourseId,
      if (venueId != null) 'venue_id': venueId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
    });
  }

  SchedulesCompanion copyWith(
      {Value<int>? id,
      Value<int>? workspaceId,
      Value<String>? assignedCourseId,
      Value<String?>? venueId,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? status}) {
    return SchedulesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      assignedCourseId: assignedCourseId ?? this.assignedCourseId,
      venueId: venueId ?? this.venueId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (assignedCourseId.present) {
      map['assigned_course_id'] = Variable<String>(assignedCourseId.value);
    }
    if (venueId.present) {
      map['venue_id'] = Variable<String>(venueId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('assignedCourseId: $assignedCourseId, ')
          ..write('venueId: $venueId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScheduleWorkspacesTable scheduleWorkspaces =
      $ScheduleWorkspacesTable(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $TrainersTable trainers = $TrainersTable(this);
  late final $VenuesTable venues = $VenuesTable(this);
  late final $CalendarDaysTable calendarDays = $CalendarDaysTable(this);
  late final $AssignedCoursesTable assignedCourses =
      $AssignedCoursesTable(this);
  late final $TrainerUnavailableDatesTable trainerUnavailableDates =
      $TrainerUnavailableDatesTable(this);
  late final $VenueUnavailableDatesTable venueUnavailableDates =
      $VenueUnavailableDatesTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        scheduleWorkspaces,
        courses,
        trainers,
        venues,
        calendarDays,
        assignedCourses,
        trainerUnavailableDates,
        venueUnavailableDates,
        schedules
      ];
}

typedef $$ScheduleWorkspacesTableCreateCompanionBuilder
    = ScheduleWorkspacesCompanion Function({
  Value<int> id,
  required String name,
  required DateTime timestamp,
  required String status,
  required String color,
});
typedef $$ScheduleWorkspacesTableUpdateCompanionBuilder
    = ScheduleWorkspacesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> timestamp,
  Value<String> status,
  Value<String> color,
});

final class $$ScheduleWorkspacesTableReferences extends BaseReferences<
    _$AppDatabase, $ScheduleWorkspacesTable, ScheduleWorkspace> {
  $$ScheduleWorkspacesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CoursesTable, List<Course>> _coursesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.courses,
          aliasName: $_aliasNameGenerator(
              db.scheduleWorkspaces.id, db.courses.workspaceId));

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager($_db, $_db.courses)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TrainersTable, List<Trainer>> _trainersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.trainers,
          aliasName: $_aliasNameGenerator(
              db.scheduleWorkspaces.id, db.trainers.workspaceId));

  $$TrainersTableProcessedTableManager get trainersRefs {
    final manager = $$TrainersTableTableManager($_db, $_db.trainers)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trainersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$VenuesTable, List<Venue>> _venuesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.venues,
          aliasName: $_aliasNameGenerator(
              db.scheduleWorkspaces.id, db.venues.workspaceId));

  $$VenuesTableProcessedTableManager get venuesRefs {
    final manager = $$VenuesTableTableManager($_db, $_db.venues)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_venuesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CalendarDaysTable, List<CalendarDay>>
      _calendarDaysRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.calendarDays,
              aliasName: $_aliasNameGenerator(
                  db.scheduleWorkspaces.id, db.calendarDays.workspaceId));

  $$CalendarDaysTableProcessedTableManager get calendarDaysRefs {
    final manager = $$CalendarDaysTableTableManager($_db, $_db.calendarDays)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarDaysRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AssignedCoursesTable, List<AssignedCourse>>
      _assignedCoursesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assignedCourses,
              aliasName: $_aliasNameGenerator(
                  db.scheduleWorkspaces.id, db.assignedCourses.workspaceId));

  $$AssignedCoursesTableProcessedTableManager get assignedCoursesRefs {
    final manager = $$AssignedCoursesTableTableManager(
            $_db, $_db.assignedCourses)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_assignedCoursesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
      _schedulesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.schedules,
              aliasName: $_aliasNameGenerator(
                  db.scheduleWorkspaces.id, db.schedules.workspaceId));

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ScheduleWorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleWorkspacesTable> {
  $$ScheduleWorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  Expression<bool> coursesRefs(
      Expression<bool> Function($$CoursesTableFilterComposer f) f) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.courses,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CoursesTableFilterComposer(
              $db: $db,
              $table: $db.courses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> trainersRefs(
      Expression<bool> Function($$TrainersTableFilterComposer f) f) {
    final $$TrainersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trainers,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrainersTableFilterComposer(
              $db: $db,
              $table: $db.trainers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> venuesRefs(
      Expression<bool> Function($$VenuesTableFilterComposer f) f) {
    final $$VenuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.venues,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VenuesTableFilterComposer(
              $db: $db,
              $table: $db.venues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> calendarDaysRefs(
      Expression<bool> Function($$CalendarDaysTableFilterComposer f) f) {
    final $$CalendarDaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.calendarDays,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CalendarDaysTableFilterComposer(
              $db: $db,
              $table: $db.calendarDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> assignedCoursesRefs(
      Expression<bool> Function($$AssignedCoursesTableFilterComposer f) f) {
    final $$AssignedCoursesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignedCourses,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignedCoursesTableFilterComposer(
              $db: $db,
              $table: $db.assignedCourses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> schedulesRefs(
      Expression<bool> Function($$SchedulesTableFilterComposer f) f) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ScheduleWorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleWorkspacesTable> {
  $$ScheduleWorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));
}

class $$ScheduleWorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleWorkspacesTable> {
  $$ScheduleWorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> coursesRefs<T extends Object>(
      Expression<T> Function($$CoursesTableAnnotationComposer a) f) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.courses,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CoursesTableAnnotationComposer(
              $db: $db,
              $table: $db.courses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> trainersRefs<T extends Object>(
      Expression<T> Function($$TrainersTableAnnotationComposer a) f) {
    final $$TrainersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trainers,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrainersTableAnnotationComposer(
              $db: $db,
              $table: $db.trainers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> venuesRefs<T extends Object>(
      Expression<T> Function($$VenuesTableAnnotationComposer a) f) {
    final $$VenuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.venues,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VenuesTableAnnotationComposer(
              $db: $db,
              $table: $db.venues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> calendarDaysRefs<T extends Object>(
      Expression<T> Function($$CalendarDaysTableAnnotationComposer a) f) {
    final $$CalendarDaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.calendarDays,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CalendarDaysTableAnnotationComposer(
              $db: $db,
              $table: $db.calendarDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> assignedCoursesRefs<T extends Object>(
      Expression<T> Function($$AssignedCoursesTableAnnotationComposer a) f) {
    final $$AssignedCoursesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignedCourses,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignedCoursesTableAnnotationComposer(
              $db: $db,
              $table: $db.assignedCourses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> schedulesRefs<T extends Object>(
      Expression<T> Function($$SchedulesTableAnnotationComposer a) f) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ScheduleWorkspacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduleWorkspacesTable,
    ScheduleWorkspace,
    $$ScheduleWorkspacesTableFilterComposer,
    $$ScheduleWorkspacesTableOrderingComposer,
    $$ScheduleWorkspacesTableAnnotationComposer,
    $$ScheduleWorkspacesTableCreateCompanionBuilder,
    $$ScheduleWorkspacesTableUpdateCompanionBuilder,
    (ScheduleWorkspace, $$ScheduleWorkspacesTableReferences),
    ScheduleWorkspace,
    PrefetchHooks Function(
        {bool coursesRefs,
        bool trainersRefs,
        bool venuesRefs,
        bool calendarDaysRefs,
        bool assignedCoursesRefs,
        bool schedulesRefs})> {
  $$ScheduleWorkspacesTableTableManager(
      _$AppDatabase db, $ScheduleWorkspacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleWorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleWorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleWorkspacesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> color = const Value.absent(),
          }) =>
              ScheduleWorkspacesCompanion(
            id: id,
            name: name,
            timestamp: timestamp,
            status: status,
            color: color,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime timestamp,
            required String status,
            required String color,
          }) =>
              ScheduleWorkspacesCompanion.insert(
            id: id,
            name: name,
            timestamp: timestamp,
            status: status,
            color: color,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScheduleWorkspacesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {coursesRefs = false,
              trainersRefs = false,
              venuesRefs = false,
              calendarDaysRefs = false,
              assignedCoursesRefs = false,
              schedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (coursesRefs) db.courses,
                if (trainersRefs) db.trainers,
                if (venuesRefs) db.venues,
                if (calendarDaysRefs) db.calendarDays,
                if (assignedCoursesRefs) db.assignedCourses,
                if (schedulesRefs) db.schedules
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (coursesRefs)
                    await $_getPrefetchedData<ScheduleWorkspace,
                            $ScheduleWorkspacesTable, Course>(
                        currentTable: table,
                        referencedTable: $$ScheduleWorkspacesTableReferences
                            ._coursesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleWorkspacesTableReferences(db, table, p0)
                                .coursesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (trainersRefs)
                    await $_getPrefetchedData<ScheduleWorkspace,
                            $ScheduleWorkspacesTable, Trainer>(
                        currentTable: table,
                        referencedTable: $$ScheduleWorkspacesTableReferences
                            ._trainersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleWorkspacesTableReferences(db, table, p0)
                                .trainersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (venuesRefs)
                    await $_getPrefetchedData<ScheduleWorkspace,
                            $ScheduleWorkspacesTable, Venue>(
                        currentTable: table,
                        referencedTable: $$ScheduleWorkspacesTableReferences
                            ._venuesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleWorkspacesTableReferences(db, table, p0)
                                .venuesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (calendarDaysRefs)
                    await $_getPrefetchedData<ScheduleWorkspace,
                            $ScheduleWorkspacesTable, CalendarDay>(
                        currentTable: table,
                        referencedTable: $$ScheduleWorkspacesTableReferences
                            ._calendarDaysRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleWorkspacesTableReferences(db, table, p0)
                                .calendarDaysRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (assignedCoursesRefs)
                    await $_getPrefetchedData<ScheduleWorkspace,
                            $ScheduleWorkspacesTable, AssignedCourse>(
                        currentTable: table,
                        referencedTable: $$ScheduleWorkspacesTableReferences
                            ._assignedCoursesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleWorkspacesTableReferences(db, table, p0)
                                .assignedCoursesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (schedulesRefs)
                    await $_getPrefetchedData<ScheduleWorkspace,
                            $ScheduleWorkspacesTable, Schedule>(
                        currentTable: table,
                        referencedTable: $$ScheduleWorkspacesTableReferences
                            ._schedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleWorkspacesTableReferences(db, table, p0)
                                .schedulesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ScheduleWorkspacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScheduleWorkspacesTable,
    ScheduleWorkspace,
    $$ScheduleWorkspacesTableFilterComposer,
    $$ScheduleWorkspacesTableOrderingComposer,
    $$ScheduleWorkspacesTableAnnotationComposer,
    $$ScheduleWorkspacesTableCreateCompanionBuilder,
    $$ScheduleWorkspacesTableUpdateCompanionBuilder,
    (ScheduleWorkspace, $$ScheduleWorkspacesTableReferences),
    ScheduleWorkspace,
    PrefetchHooks Function(
        {bool coursesRefs,
        bool trainersRefs,
        bool venuesRefs,
        bool calendarDaysRefs,
        bool assignedCoursesRefs,
        bool schedulesRefs})>;
typedef $$CoursesTableCreateCompanionBuilder = CoursesCompanion Function({
  Value<int> id,
  required int workspaceId,
  required String courseId,
  required String name,
  required int durationDays,
  required int expectedTrainees,
  required String deliveryType,
  Value<String?> specialty,
  Value<int?> hoursPerDay,
  Value<String?> preferredCitySite,
  Value<String?> beneficiary,
  Value<String?> priority,
  Value<DateTime?> earliestStart,
  Value<DateTime?> latestEnd,
  Value<DateTime?> fixedDate,
  Value<String?> notes,
  Value<String?> courseNameAr,
});
typedef $$CoursesTableUpdateCompanionBuilder = CoursesCompanion Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<String> courseId,
  Value<String> name,
  Value<int> durationDays,
  Value<int> expectedTrainees,
  Value<String> deliveryType,
  Value<String?> specialty,
  Value<int?> hoursPerDay,
  Value<String?> preferredCitySite,
  Value<String?> beneficiary,
  Value<String?> priority,
  Value<DateTime?> earliestStart,
  Value<DateTime?> latestEnd,
  Value<DateTime?> fixedDate,
  Value<String?> notes,
  Value<String?> courseNameAr,
});

final class $$CoursesTableReferences
    extends BaseReferences<_$AppDatabase, $CoursesTable, Course> {
  $$CoursesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleWorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.scheduleWorkspaces.createAlias($_aliasNameGenerator(
          db.courses.workspaceId, db.scheduleWorkspaces.id));

  $$ScheduleWorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id')!;

    final manager =
        $$ScheduleWorkspacesTableTableManager($_db, $_db.scheduleWorkspaces)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationDays => $composableBuilder(
      column: $table.durationDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expectedTrainees => $composableBuilder(
      column: $table.expectedTrainees,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveryType => $composableBuilder(
      column: $table.deliveryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialty => $composableBuilder(
      column: $table.specialty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hoursPerDay => $composableBuilder(
      column: $table.hoursPerDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredCitySite => $composableBuilder(
      column: $table.preferredCitySite,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiary => $composableBuilder(
      column: $table.beneficiary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get earliestStart => $composableBuilder(
      column: $table.earliestStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get latestEnd => $composableBuilder(
      column: $table.latestEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fixedDate => $composableBuilder(
      column: $table.fixedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseNameAr => $composableBuilder(
      column: $table.courseNameAr, builder: (column) => ColumnFilters(column));

  $$ScheduleWorkspacesTableFilterComposer get workspaceId {
    final $$ScheduleWorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationDays => $composableBuilder(
      column: $table.durationDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expectedTrainees => $composableBuilder(
      column: $table.expectedTrainees,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveryType => $composableBuilder(
      column: $table.deliveryType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialty => $composableBuilder(
      column: $table.specialty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hoursPerDay => $composableBuilder(
      column: $table.hoursPerDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredCitySite => $composableBuilder(
      column: $table.preferredCitySite,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiary => $composableBuilder(
      column: $table.beneficiary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get earliestStart => $composableBuilder(
      column: $table.earliestStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get latestEnd => $composableBuilder(
      column: $table.latestEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fixedDate => $composableBuilder(
      column: $table.fixedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseNameAr => $composableBuilder(
      column: $table.courseNameAr,
      builder: (column) => ColumnOrderings(column));

  $$ScheduleWorkspacesTableOrderingComposer get workspaceId {
    final $$ScheduleWorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get durationDays => $composableBuilder(
      column: $table.durationDays, builder: (column) => column);

  GeneratedColumn<int> get expectedTrainees => $composableBuilder(
      column: $table.expectedTrainees, builder: (column) => column);

  GeneratedColumn<String> get deliveryType => $composableBuilder(
      column: $table.deliveryType, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<int> get hoursPerDay => $composableBuilder(
      column: $table.hoursPerDay, builder: (column) => column);

  GeneratedColumn<String> get preferredCitySite => $composableBuilder(
      column: $table.preferredCitySite, builder: (column) => column);

  GeneratedColumn<String> get beneficiary => $composableBuilder(
      column: $table.beneficiary, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get earliestStart => $composableBuilder(
      column: $table.earliestStart, builder: (column) => column);

  GeneratedColumn<DateTime> get latestEnd =>
      $composableBuilder(column: $table.latestEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get fixedDate =>
      $composableBuilder(column: $table.fixedDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get courseNameAr => $composableBuilder(
      column: $table.courseNameAr, builder: (column) => column);

  $$ScheduleWorkspacesTableAnnotationComposer get workspaceId {
    final $$ScheduleWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workspaceId,
            referencedTable: $db.scheduleWorkspaces,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleWorkspacesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduleWorkspaces,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$CoursesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CoursesTable,
    Course,
    $$CoursesTableFilterComposer,
    $$CoursesTableOrderingComposer,
    $$CoursesTableAnnotationComposer,
    $$CoursesTableCreateCompanionBuilder,
    $$CoursesTableUpdateCompanionBuilder,
    (Course, $$CoursesTableReferences),
    Course,
    PrefetchHooks Function({bool workspaceId})> {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workspaceId = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> durationDays = const Value.absent(),
            Value<int> expectedTrainees = const Value.absent(),
            Value<String> deliveryType = const Value.absent(),
            Value<String?> specialty = const Value.absent(),
            Value<int?> hoursPerDay = const Value.absent(),
            Value<String?> preferredCitySite = const Value.absent(),
            Value<String?> beneficiary = const Value.absent(),
            Value<String?> priority = const Value.absent(),
            Value<DateTime?> earliestStart = const Value.absent(),
            Value<DateTime?> latestEnd = const Value.absent(),
            Value<DateTime?> fixedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> courseNameAr = const Value.absent(),
          }) =>
              CoursesCompanion(
            id: id,
            workspaceId: workspaceId,
            courseId: courseId,
            name: name,
            durationDays: durationDays,
            expectedTrainees: expectedTrainees,
            deliveryType: deliveryType,
            specialty: specialty,
            hoursPerDay: hoursPerDay,
            preferredCitySite: preferredCitySite,
            beneficiary: beneficiary,
            priority: priority,
            earliestStart: earliestStart,
            latestEnd: latestEnd,
            fixedDate: fixedDate,
            notes: notes,
            courseNameAr: courseNameAr,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workspaceId,
            required String courseId,
            required String name,
            required int durationDays,
            required int expectedTrainees,
            required String deliveryType,
            Value<String?> specialty = const Value.absent(),
            Value<int?> hoursPerDay = const Value.absent(),
            Value<String?> preferredCitySite = const Value.absent(),
            Value<String?> beneficiary = const Value.absent(),
            Value<String?> priority = const Value.absent(),
            Value<DateTime?> earliestStart = const Value.absent(),
            Value<DateTime?> latestEnd = const Value.absent(),
            Value<DateTime?> fixedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> courseNameAr = const Value.absent(),
          }) =>
              CoursesCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            courseId: courseId,
            name: name,
            durationDays: durationDays,
            expectedTrainees: expectedTrainees,
            deliveryType: deliveryType,
            specialty: specialty,
            hoursPerDay: hoursPerDay,
            preferredCitySite: preferredCitySite,
            beneficiary: beneficiary,
            priority: priority,
            earliestStart: earliestStart,
            latestEnd: latestEnd,
            fixedDate: fixedDate,
            notes: notes,
            courseNameAr: courseNameAr,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CoursesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({workspaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$CoursesTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$CoursesTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CoursesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CoursesTable,
    Course,
    $$CoursesTableFilterComposer,
    $$CoursesTableOrderingComposer,
    $$CoursesTableAnnotationComposer,
    $$CoursesTableCreateCompanionBuilder,
    $$CoursesTableUpdateCompanionBuilder,
    (Course, $$CoursesTableReferences),
    Course,
    PrefetchHooks Function({bool workspaceId})>;
typedef $$TrainersTableCreateCompanionBuilder = TrainersCompanion Function({
  Value<int> id,
  required int workspaceId,
  required String trainerId,
  required String name,
  Value<String?> specialty,
  Value<String?> city,
  Value<String?> trainerType,
  Value<int?> maxDaysPerMonth,
  Value<int?> maxConsecutiveDays,
  Value<double?> costPerDay,
  Value<String?> notes,
});
typedef $$TrainersTableUpdateCompanionBuilder = TrainersCompanion Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<String> trainerId,
  Value<String> name,
  Value<String?> specialty,
  Value<String?> city,
  Value<String?> trainerType,
  Value<int?> maxDaysPerMonth,
  Value<int?> maxConsecutiveDays,
  Value<double?> costPerDay,
  Value<String?> notes,
});

final class $$TrainersTableReferences
    extends BaseReferences<_$AppDatabase, $TrainersTable, Trainer> {
  $$TrainersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleWorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.scheduleWorkspaces.createAlias($_aliasNameGenerator(
          db.trainers.workspaceId, db.scheduleWorkspaces.id));

  $$ScheduleWorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id')!;

    final manager =
        $$ScheduleWorkspacesTableTableManager($_db, $_db.scheduleWorkspaces)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TrainerUnavailableDatesTable,
      List<TrainerUnavailableDate>> _trainerUnavailableDatesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.trainerUnavailableDates,
          aliasName: $_aliasNameGenerator(
              db.trainers.id, db.trainerUnavailableDates.trainerId));

  $$TrainerUnavailableDatesTableProcessedTableManager
      get trainerUnavailableDatesRefs {
    final manager = $$TrainerUnavailableDatesTableTableManager(
            $_db, $_db.trainerUnavailableDates)
        .filter((f) => f.trainerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_trainerUnavailableDatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TrainersTableFilterComposer
    extends Composer<_$AppDatabase, $TrainersTable> {
  $$TrainersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainerId => $composableBuilder(
      column: $table.trainerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialty => $composableBuilder(
      column: $table.specialty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainerType => $composableBuilder(
      column: $table.trainerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxDaysPerMonth => $composableBuilder(
      column: $table.maxDaysPerMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxConsecutiveDays => $composableBuilder(
      column: $table.maxConsecutiveDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPerDay => $composableBuilder(
      column: $table.costPerDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$ScheduleWorkspacesTableFilterComposer get workspaceId {
    final $$ScheduleWorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> trainerUnavailableDatesRefs(
      Expression<bool> Function($$TrainerUnavailableDatesTableFilterComposer f)
          f) {
    final $$TrainerUnavailableDatesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.trainerUnavailableDates,
            getReferencedColumn: (t) => t.trainerId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TrainerUnavailableDatesTableFilterComposer(
                  $db: $db,
                  $table: $db.trainerUnavailableDates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TrainersTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainersTable> {
  $$TrainersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainerId => $composableBuilder(
      column: $table.trainerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialty => $composableBuilder(
      column: $table.specialty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainerType => $composableBuilder(
      column: $table.trainerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxDaysPerMonth => $composableBuilder(
      column: $table.maxDaysPerMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxConsecutiveDays => $composableBuilder(
      column: $table.maxConsecutiveDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPerDay => $composableBuilder(
      column: $table.costPerDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$ScheduleWorkspacesTableOrderingComposer get workspaceId {
    final $$ScheduleWorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrainersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainersTable> {
  $$TrainersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trainerId =>
      $composableBuilder(column: $table.trainerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get trainerType => $composableBuilder(
      column: $table.trainerType, builder: (column) => column);

  GeneratedColumn<int> get maxDaysPerMonth => $composableBuilder(
      column: $table.maxDaysPerMonth, builder: (column) => column);

  GeneratedColumn<int> get maxConsecutiveDays => $composableBuilder(
      column: $table.maxConsecutiveDays, builder: (column) => column);

  GeneratedColumn<double> get costPerDay => $composableBuilder(
      column: $table.costPerDay, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ScheduleWorkspacesTableAnnotationComposer get workspaceId {
    final $$ScheduleWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workspaceId,
            referencedTable: $db.scheduleWorkspaces,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleWorkspacesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduleWorkspaces,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> trainerUnavailableDatesRefs<T extends Object>(
      Expression<T> Function($$TrainerUnavailableDatesTableAnnotationComposer a)
          f) {
    final $$TrainerUnavailableDatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.trainerUnavailableDates,
            getReferencedColumn: (t) => t.trainerId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TrainerUnavailableDatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.trainerUnavailableDates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TrainersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrainersTable,
    Trainer,
    $$TrainersTableFilterComposer,
    $$TrainersTableOrderingComposer,
    $$TrainersTableAnnotationComposer,
    $$TrainersTableCreateCompanionBuilder,
    $$TrainersTableUpdateCompanionBuilder,
    (Trainer, $$TrainersTableReferences),
    Trainer,
    PrefetchHooks Function(
        {bool workspaceId, bool trainerUnavailableDatesRefs})> {
  $$TrainersTableTableManager(_$AppDatabase db, $TrainersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workspaceId = const Value.absent(),
            Value<String> trainerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> specialty = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> trainerType = const Value.absent(),
            Value<int?> maxDaysPerMonth = const Value.absent(),
            Value<int?> maxConsecutiveDays = const Value.absent(),
            Value<double?> costPerDay = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              TrainersCompanion(
            id: id,
            workspaceId: workspaceId,
            trainerId: trainerId,
            name: name,
            specialty: specialty,
            city: city,
            trainerType: trainerType,
            maxDaysPerMonth: maxDaysPerMonth,
            maxConsecutiveDays: maxConsecutiveDays,
            costPerDay: costPerDay,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workspaceId,
            required String trainerId,
            required String name,
            Value<String?> specialty = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> trainerType = const Value.absent(),
            Value<int?> maxDaysPerMonth = const Value.absent(),
            Value<int?> maxConsecutiveDays = const Value.absent(),
            Value<double?> costPerDay = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              TrainersCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            trainerId: trainerId,
            name: name,
            specialty: specialty,
            city: city,
            trainerType: trainerType,
            maxDaysPerMonth: maxDaysPerMonth,
            maxConsecutiveDays: maxConsecutiveDays,
            costPerDay: costPerDay,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TrainersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {workspaceId = false, trainerUnavailableDatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trainerUnavailableDatesRefs) db.trainerUnavailableDates
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$TrainersTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$TrainersTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trainerUnavailableDatesRefs)
                    await $_getPrefetchedData<Trainer, $TrainersTable,
                            TrainerUnavailableDate>(
                        currentTable: table,
                        referencedTable: $$TrainersTableReferences
                            ._trainerUnavailableDatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TrainersTableReferences(db, table, p0)
                                .trainerUnavailableDatesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.trainerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TrainersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrainersTable,
    Trainer,
    $$TrainersTableFilterComposer,
    $$TrainersTableOrderingComposer,
    $$TrainersTableAnnotationComposer,
    $$TrainersTableCreateCompanionBuilder,
    $$TrainersTableUpdateCompanionBuilder,
    (Trainer, $$TrainersTableReferences),
    Trainer,
    PrefetchHooks Function(
        {bool workspaceId, bool trainerUnavailableDatesRefs})>;
typedef $$VenuesTableCreateCompanionBuilder = VenuesCompanion Function({
  Value<int> id,
  required int workspaceId,
  required String venueId,
  required String name,
  required int capacity,
  required String venueType,
  Value<String?> city,
  Value<DateTime?> availableFrom,
  Value<DateTime?> availableTo,
  Value<String?> equipmentNotes,
});
typedef $$VenuesTableUpdateCompanionBuilder = VenuesCompanion Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<String> venueId,
  Value<String> name,
  Value<int> capacity,
  Value<String> venueType,
  Value<String?> city,
  Value<DateTime?> availableFrom,
  Value<DateTime?> availableTo,
  Value<String?> equipmentNotes,
});

final class $$VenuesTableReferences
    extends BaseReferences<_$AppDatabase, $VenuesTable, Venue> {
  $$VenuesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleWorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.scheduleWorkspaces.createAlias($_aliasNameGenerator(
          db.venues.workspaceId, db.scheduleWorkspaces.id));

  $$ScheduleWorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id')!;

    final manager =
        $$ScheduleWorkspacesTableTableManager($_db, $_db.scheduleWorkspaces)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$VenueUnavailableDatesTable,
      List<VenueUnavailableDate>> _venueUnavailableDatesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.venueUnavailableDates,
          aliasName: $_aliasNameGenerator(
              db.venues.id, db.venueUnavailableDates.venueId));

  $$VenueUnavailableDatesTableProcessedTableManager
      get venueUnavailableDatesRefs {
    final manager = $$VenueUnavailableDatesTableTableManager(
            $_db, $_db.venueUnavailableDates)
        .filter((f) => f.venueId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_venueUnavailableDatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VenuesTableFilterComposer
    extends Composer<_$AppDatabase, $VenuesTable> {
  $$VenuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venueId => $composableBuilder(
      column: $table.venueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get capacity => $composableBuilder(
      column: $table.capacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venueType => $composableBuilder(
      column: $table.venueType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get availableFrom => $composableBuilder(
      column: $table.availableFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get availableTo => $composableBuilder(
      column: $table.availableTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipmentNotes => $composableBuilder(
      column: $table.equipmentNotes,
      builder: (column) => ColumnFilters(column));

  $$ScheduleWorkspacesTableFilterComposer get workspaceId {
    final $$ScheduleWorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> venueUnavailableDatesRefs(
      Expression<bool> Function($$VenueUnavailableDatesTableFilterComposer f)
          f) {
    final $$VenueUnavailableDatesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.venueUnavailableDates,
            getReferencedColumn: (t) => t.venueId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$VenueUnavailableDatesTableFilterComposer(
                  $db: $db,
                  $table: $db.venueUnavailableDates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$VenuesTableOrderingComposer
    extends Composer<_$AppDatabase, $VenuesTable> {
  $$VenuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venueId => $composableBuilder(
      column: $table.venueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get capacity => $composableBuilder(
      column: $table.capacity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venueType => $composableBuilder(
      column: $table.venueType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get availableFrom => $composableBuilder(
      column: $table.availableFrom,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get availableTo => $composableBuilder(
      column: $table.availableTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipmentNotes => $composableBuilder(
      column: $table.equipmentNotes,
      builder: (column) => ColumnOrderings(column));

  $$ScheduleWorkspacesTableOrderingComposer get workspaceId {
    final $$ScheduleWorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VenuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VenuesTable> {
  $$VenuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get venueId =>
      $composableBuilder(column: $table.venueId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get venueType =>
      $composableBuilder(column: $table.venueType, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<DateTime> get availableFrom => $composableBuilder(
      column: $table.availableFrom, builder: (column) => column);

  GeneratedColumn<DateTime> get availableTo => $composableBuilder(
      column: $table.availableTo, builder: (column) => column);

  GeneratedColumn<String> get equipmentNotes => $composableBuilder(
      column: $table.equipmentNotes, builder: (column) => column);

  $$ScheduleWorkspacesTableAnnotationComposer get workspaceId {
    final $$ScheduleWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workspaceId,
            referencedTable: $db.scheduleWorkspaces,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleWorkspacesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduleWorkspaces,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> venueUnavailableDatesRefs<T extends Object>(
      Expression<T> Function($$VenueUnavailableDatesTableAnnotationComposer a)
          f) {
    final $$VenueUnavailableDatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.venueUnavailableDates,
            getReferencedColumn: (t) => t.venueId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$VenueUnavailableDatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.venueUnavailableDates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$VenuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VenuesTable,
    Venue,
    $$VenuesTableFilterComposer,
    $$VenuesTableOrderingComposer,
    $$VenuesTableAnnotationComposer,
    $$VenuesTableCreateCompanionBuilder,
    $$VenuesTableUpdateCompanionBuilder,
    (Venue, $$VenuesTableReferences),
    Venue,
    PrefetchHooks Function(
        {bool workspaceId, bool venueUnavailableDatesRefs})> {
  $$VenuesTableTableManager(_$AppDatabase db, $VenuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VenuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VenuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VenuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workspaceId = const Value.absent(),
            Value<String> venueId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> capacity = const Value.absent(),
            Value<String> venueType = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<DateTime?> availableFrom = const Value.absent(),
            Value<DateTime?> availableTo = const Value.absent(),
            Value<String?> equipmentNotes = const Value.absent(),
          }) =>
              VenuesCompanion(
            id: id,
            workspaceId: workspaceId,
            venueId: venueId,
            name: name,
            capacity: capacity,
            venueType: venueType,
            city: city,
            availableFrom: availableFrom,
            availableTo: availableTo,
            equipmentNotes: equipmentNotes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workspaceId,
            required String venueId,
            required String name,
            required int capacity,
            required String venueType,
            Value<String?> city = const Value.absent(),
            Value<DateTime?> availableFrom = const Value.absent(),
            Value<DateTime?> availableTo = const Value.absent(),
            Value<String?> equipmentNotes = const Value.absent(),
          }) =>
              VenuesCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            venueId: venueId,
            name: name,
            capacity: capacity,
            venueType: venueType,
            city: city,
            availableFrom: availableFrom,
            availableTo: availableTo,
            equipmentNotes: equipmentNotes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VenuesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {workspaceId = false, venueUnavailableDatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (venueUnavailableDatesRefs) db.venueUnavailableDates
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$VenuesTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$VenuesTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (venueUnavailableDatesRefs)
                    await $_getPrefetchedData<Venue, $VenuesTable,
                            VenueUnavailableDate>(
                        currentTable: table,
                        referencedTable: $$VenuesTableReferences
                            ._venueUnavailableDatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VenuesTableReferences(db, table, p0)
                                .venueUnavailableDatesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.venueId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VenuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VenuesTable,
    Venue,
    $$VenuesTableFilterComposer,
    $$VenuesTableOrderingComposer,
    $$VenuesTableAnnotationComposer,
    $$VenuesTableCreateCompanionBuilder,
    $$VenuesTableUpdateCompanionBuilder,
    (Venue, $$VenuesTableReferences),
    Venue,
    PrefetchHooks Function({bool workspaceId, bool venueUnavailableDatesRefs})>;
typedef $$CalendarDaysTableCreateCompanionBuilder = CalendarDaysCompanion
    Function({
  Value<int> id,
  required int workspaceId,
  required DateTime date,
  required bool isWorkingDay,
  required bool isHoliday,
});
typedef $$CalendarDaysTableUpdateCompanionBuilder = CalendarDaysCompanion
    Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<DateTime> date,
  Value<bool> isWorkingDay,
  Value<bool> isHoliday,
});

final class $$CalendarDaysTableReferences
    extends BaseReferences<_$AppDatabase, $CalendarDaysTable, CalendarDay> {
  $$CalendarDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleWorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.scheduleWorkspaces.createAlias($_aliasNameGenerator(
          db.calendarDays.workspaceId, db.scheduleWorkspaces.id));

  $$ScheduleWorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id')!;

    final manager =
        $$ScheduleWorkspacesTableTableManager($_db, $_db.scheduleWorkspaces)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CalendarDaysTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarDaysTable> {
  $$CalendarDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWorkingDay => $composableBuilder(
      column: $table.isWorkingDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHoliday => $composableBuilder(
      column: $table.isHoliday, builder: (column) => ColumnFilters(column));

  $$ScheduleWorkspacesTableFilterComposer get workspaceId {
    final $$ScheduleWorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CalendarDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarDaysTable> {
  $$CalendarDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWorkingDay => $composableBuilder(
      column: $table.isWorkingDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHoliday => $composableBuilder(
      column: $table.isHoliday, builder: (column) => ColumnOrderings(column));

  $$ScheduleWorkspacesTableOrderingComposer get workspaceId {
    final $$ScheduleWorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CalendarDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarDaysTable> {
  $$CalendarDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isWorkingDay => $composableBuilder(
      column: $table.isWorkingDay, builder: (column) => column);

  GeneratedColumn<bool> get isHoliday =>
      $composableBuilder(column: $table.isHoliday, builder: (column) => column);

  $$ScheduleWorkspacesTableAnnotationComposer get workspaceId {
    final $$ScheduleWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workspaceId,
            referencedTable: $db.scheduleWorkspaces,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleWorkspacesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduleWorkspaces,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$CalendarDaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CalendarDaysTable,
    CalendarDay,
    $$CalendarDaysTableFilterComposer,
    $$CalendarDaysTableOrderingComposer,
    $$CalendarDaysTableAnnotationComposer,
    $$CalendarDaysTableCreateCompanionBuilder,
    $$CalendarDaysTableUpdateCompanionBuilder,
    (CalendarDay, $$CalendarDaysTableReferences),
    CalendarDay,
    PrefetchHooks Function({bool workspaceId})> {
  $$CalendarDaysTableTableManager(_$AppDatabase db, $CalendarDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workspaceId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> isWorkingDay = const Value.absent(),
            Value<bool> isHoliday = const Value.absent(),
          }) =>
              CalendarDaysCompanion(
            id: id,
            workspaceId: workspaceId,
            date: date,
            isWorkingDay: isWorkingDay,
            isHoliday: isHoliday,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workspaceId,
            required DateTime date,
            required bool isWorkingDay,
            required bool isHoliday,
          }) =>
              CalendarDaysCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            date: date,
            isWorkingDay: isWorkingDay,
            isHoliday: isHoliday,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CalendarDaysTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workspaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$CalendarDaysTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$CalendarDaysTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CalendarDaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CalendarDaysTable,
    CalendarDay,
    $$CalendarDaysTableFilterComposer,
    $$CalendarDaysTableOrderingComposer,
    $$CalendarDaysTableAnnotationComposer,
    $$CalendarDaysTableCreateCompanionBuilder,
    $$CalendarDaysTableUpdateCompanionBuilder,
    (CalendarDay, $$CalendarDaysTableReferences),
    CalendarDay,
    PrefetchHooks Function({bool workspaceId})>;
typedef $$AssignedCoursesTableCreateCompanionBuilder = AssignedCoursesCompanion
    Function({
  Value<int> id,
  required int workspaceId,
  required String assignedId,
  required String courseId,
  required String trainerId,
  Value<String> status,
});
typedef $$AssignedCoursesTableUpdateCompanionBuilder = AssignedCoursesCompanion
    Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<String> assignedId,
  Value<String> courseId,
  Value<String> trainerId,
  Value<String> status,
});

final class $$AssignedCoursesTableReferences extends BaseReferences<
    _$AppDatabase, $AssignedCoursesTable, AssignedCourse> {
  $$AssignedCoursesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleWorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.scheduleWorkspaces.createAlias($_aliasNameGenerator(
          db.assignedCourses.workspaceId, db.scheduleWorkspaces.id));

  $$ScheduleWorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id')!;

    final manager =
        $$ScheduleWorkspacesTableTableManager($_db, $_db.scheduleWorkspaces)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AssignedCoursesTableFilterComposer
    extends Composer<_$AppDatabase, $AssignedCoursesTable> {
  $$AssignedCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedId => $composableBuilder(
      column: $table.assignedId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainerId => $composableBuilder(
      column: $table.trainerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$ScheduleWorkspacesTableFilterComposer get workspaceId {
    final $$ScheduleWorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssignedCoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignedCoursesTable> {
  $$AssignedCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedId => $composableBuilder(
      column: $table.assignedId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainerId => $composableBuilder(
      column: $table.trainerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$ScheduleWorkspacesTableOrderingComposer get workspaceId {
    final $$ScheduleWorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssignedCoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignedCoursesTable> {
  $$AssignedCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assignedId => $composableBuilder(
      column: $table.assignedId, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get trainerId =>
      $composableBuilder(column: $table.trainerId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ScheduleWorkspacesTableAnnotationComposer get workspaceId {
    final $$ScheduleWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workspaceId,
            referencedTable: $db.scheduleWorkspaces,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleWorkspacesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduleWorkspaces,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$AssignedCoursesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssignedCoursesTable,
    AssignedCourse,
    $$AssignedCoursesTableFilterComposer,
    $$AssignedCoursesTableOrderingComposer,
    $$AssignedCoursesTableAnnotationComposer,
    $$AssignedCoursesTableCreateCompanionBuilder,
    $$AssignedCoursesTableUpdateCompanionBuilder,
    (AssignedCourse, $$AssignedCoursesTableReferences),
    AssignedCourse,
    PrefetchHooks Function({bool workspaceId})> {
  $$AssignedCoursesTableTableManager(
      _$AppDatabase db, $AssignedCoursesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignedCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignedCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignedCoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workspaceId = const Value.absent(),
            Value<String> assignedId = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<String> trainerId = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              AssignedCoursesCompanion(
            id: id,
            workspaceId: workspaceId,
            assignedId: assignedId,
            courseId: courseId,
            trainerId: trainerId,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workspaceId,
            required String assignedId,
            required String courseId,
            required String trainerId,
            Value<String> status = const Value.absent(),
          }) =>
              AssignedCoursesCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            assignedId: assignedId,
            courseId: courseId,
            trainerId: trainerId,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AssignedCoursesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workspaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$AssignedCoursesTableReferences._workspaceIdTable(db),
                    referencedColumn: $$AssignedCoursesTableReferences
                        ._workspaceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AssignedCoursesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssignedCoursesTable,
    AssignedCourse,
    $$AssignedCoursesTableFilterComposer,
    $$AssignedCoursesTableOrderingComposer,
    $$AssignedCoursesTableAnnotationComposer,
    $$AssignedCoursesTableCreateCompanionBuilder,
    $$AssignedCoursesTableUpdateCompanionBuilder,
    (AssignedCourse, $$AssignedCoursesTableReferences),
    AssignedCourse,
    PrefetchHooks Function({bool workspaceId})>;
typedef $$TrainerUnavailableDatesTableCreateCompanionBuilder
    = TrainerUnavailableDatesCompanion Function({
  Value<int> id,
  required int trainerId,
  required DateTime date,
});
typedef $$TrainerUnavailableDatesTableUpdateCompanionBuilder
    = TrainerUnavailableDatesCompanion Function({
  Value<int> id,
  Value<int> trainerId,
  Value<DateTime> date,
});

final class $$TrainerUnavailableDatesTableReferences extends BaseReferences<
    _$AppDatabase, $TrainerUnavailableDatesTable, TrainerUnavailableDate> {
  $$TrainerUnavailableDatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TrainersTable _trainerIdTable(_$AppDatabase db) =>
      db.trainers.createAlias($_aliasNameGenerator(
          db.trainerUnavailableDates.trainerId, db.trainers.id));

  $$TrainersTableProcessedTableManager get trainerId {
    final $_column = $_itemColumn<int>('trainer_id')!;

    final manager = $$TrainersTableTableManager($_db, $_db.trainers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trainerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TrainerUnavailableDatesTableFilterComposer
    extends Composer<_$AppDatabase, $TrainerUnavailableDatesTable> {
  $$TrainerUnavailableDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  $$TrainersTableFilterComposer get trainerId {
    final $$TrainersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trainerId,
        referencedTable: $db.trainers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrainersTableFilterComposer(
              $db: $db,
              $table: $db.trainers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrainerUnavailableDatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainerUnavailableDatesTable> {
  $$TrainerUnavailableDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  $$TrainersTableOrderingComposer get trainerId {
    final $$TrainersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trainerId,
        referencedTable: $db.trainers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrainersTableOrderingComposer(
              $db: $db,
              $table: $db.trainers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrainerUnavailableDatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainerUnavailableDatesTable> {
  $$TrainerUnavailableDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$TrainersTableAnnotationComposer get trainerId {
    final $$TrainersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trainerId,
        referencedTable: $db.trainers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrainersTableAnnotationComposer(
              $db: $db,
              $table: $db.trainers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrainerUnavailableDatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrainerUnavailableDatesTable,
    TrainerUnavailableDate,
    $$TrainerUnavailableDatesTableFilterComposer,
    $$TrainerUnavailableDatesTableOrderingComposer,
    $$TrainerUnavailableDatesTableAnnotationComposer,
    $$TrainerUnavailableDatesTableCreateCompanionBuilder,
    $$TrainerUnavailableDatesTableUpdateCompanionBuilder,
    (TrainerUnavailableDate, $$TrainerUnavailableDatesTableReferences),
    TrainerUnavailableDate,
    PrefetchHooks Function({bool trainerId})> {
  $$TrainerUnavailableDatesTableTableManager(
      _$AppDatabase db, $TrainerUnavailableDatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainerUnavailableDatesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainerUnavailableDatesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainerUnavailableDatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> trainerId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              TrainerUnavailableDatesCompanion(
            id: id,
            trainerId: trainerId,
            date: date,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int trainerId,
            required DateTime date,
          }) =>
              TrainerUnavailableDatesCompanion.insert(
            id: id,
            trainerId: trainerId,
            date: date,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TrainerUnavailableDatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({trainerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (trainerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.trainerId,
                    referencedTable: $$TrainerUnavailableDatesTableReferences
                        ._trainerIdTable(db),
                    referencedColumn: $$TrainerUnavailableDatesTableReferences
                        ._trainerIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TrainerUnavailableDatesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TrainerUnavailableDatesTable,
        TrainerUnavailableDate,
        $$TrainerUnavailableDatesTableFilterComposer,
        $$TrainerUnavailableDatesTableOrderingComposer,
        $$TrainerUnavailableDatesTableAnnotationComposer,
        $$TrainerUnavailableDatesTableCreateCompanionBuilder,
        $$TrainerUnavailableDatesTableUpdateCompanionBuilder,
        (TrainerUnavailableDate, $$TrainerUnavailableDatesTableReferences),
        TrainerUnavailableDate,
        PrefetchHooks Function({bool trainerId})>;
typedef $$VenueUnavailableDatesTableCreateCompanionBuilder
    = VenueUnavailableDatesCompanion Function({
  Value<int> id,
  required int venueId,
  required DateTime date,
});
typedef $$VenueUnavailableDatesTableUpdateCompanionBuilder
    = VenueUnavailableDatesCompanion Function({
  Value<int> id,
  Value<int> venueId,
  Value<DateTime> date,
});

final class $$VenueUnavailableDatesTableReferences extends BaseReferences<
    _$AppDatabase, $VenueUnavailableDatesTable, VenueUnavailableDate> {
  $$VenueUnavailableDatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $VenuesTable _venueIdTable(_$AppDatabase db) => db.venues.createAlias(
      $_aliasNameGenerator(db.venueUnavailableDates.venueId, db.venues.id));

  $$VenuesTableProcessedTableManager get venueId {
    final $_column = $_itemColumn<int>('venue_id')!;

    final manager = $$VenuesTableTableManager($_db, $_db.venues)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_venueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VenueUnavailableDatesTableFilterComposer
    extends Composer<_$AppDatabase, $VenueUnavailableDatesTable> {
  $$VenueUnavailableDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  $$VenuesTableFilterComposer get venueId {
    final $$VenuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.venueId,
        referencedTable: $db.venues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VenuesTableFilterComposer(
              $db: $db,
              $table: $db.venues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VenueUnavailableDatesTableOrderingComposer
    extends Composer<_$AppDatabase, $VenueUnavailableDatesTable> {
  $$VenueUnavailableDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  $$VenuesTableOrderingComposer get venueId {
    final $$VenuesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.venueId,
        referencedTable: $db.venues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VenuesTableOrderingComposer(
              $db: $db,
              $table: $db.venues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VenueUnavailableDatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VenueUnavailableDatesTable> {
  $$VenueUnavailableDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$VenuesTableAnnotationComposer get venueId {
    final $$VenuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.venueId,
        referencedTable: $db.venues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VenuesTableAnnotationComposer(
              $db: $db,
              $table: $db.venues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VenueUnavailableDatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VenueUnavailableDatesTable,
    VenueUnavailableDate,
    $$VenueUnavailableDatesTableFilterComposer,
    $$VenueUnavailableDatesTableOrderingComposer,
    $$VenueUnavailableDatesTableAnnotationComposer,
    $$VenueUnavailableDatesTableCreateCompanionBuilder,
    $$VenueUnavailableDatesTableUpdateCompanionBuilder,
    (VenueUnavailableDate, $$VenueUnavailableDatesTableReferences),
    VenueUnavailableDate,
    PrefetchHooks Function({bool venueId})> {
  $$VenueUnavailableDatesTableTableManager(
      _$AppDatabase db, $VenueUnavailableDatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VenueUnavailableDatesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$VenueUnavailableDatesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VenueUnavailableDatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> venueId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              VenueUnavailableDatesCompanion(
            id: id,
            venueId: venueId,
            date: date,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int venueId,
            required DateTime date,
          }) =>
              VenueUnavailableDatesCompanion.insert(
            id: id,
            venueId: venueId,
            date: date,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VenueUnavailableDatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({venueId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (venueId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.venueId,
                    referencedTable: $$VenueUnavailableDatesTableReferences
                        ._venueIdTable(db),
                    referencedColumn: $$VenueUnavailableDatesTableReferences
                        ._venueIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VenueUnavailableDatesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $VenueUnavailableDatesTable,
        VenueUnavailableDate,
        $$VenueUnavailableDatesTableFilterComposer,
        $$VenueUnavailableDatesTableOrderingComposer,
        $$VenueUnavailableDatesTableAnnotationComposer,
        $$VenueUnavailableDatesTableCreateCompanionBuilder,
        $$VenueUnavailableDatesTableUpdateCompanionBuilder,
        (VenueUnavailableDate, $$VenueUnavailableDatesTableReferences),
        VenueUnavailableDate,
        PrefetchHooks Function({bool venueId})>;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  required int workspaceId,
  required String assignedCourseId,
  Value<String?> venueId,
  required DateTime startDate,
  required DateTime endDate,
  Value<String> status,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<String> assignedCourseId,
  Value<String?> venueId,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> status,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleWorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.scheduleWorkspaces.createAlias($_aliasNameGenerator(
          db.schedules.workspaceId, db.scheduleWorkspaces.id));

  $$ScheduleWorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id')!;

    final manager =
        $$ScheduleWorkspacesTableTableManager($_db, $_db.scheduleWorkspaces)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedCourseId => $composableBuilder(
      column: $table.assignedCourseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venueId => $composableBuilder(
      column: $table.venueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$ScheduleWorkspacesTableFilterComposer get workspaceId {
    final $$ScheduleWorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedCourseId => $composableBuilder(
      column: $table.assignedCourseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venueId => $composableBuilder(
      column: $table.venueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$ScheduleWorkspacesTableOrderingComposer get workspaceId {
    final $$ScheduleWorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.scheduleWorkspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleWorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleWorkspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assignedCourseId => $composableBuilder(
      column: $table.assignedCourseId, builder: (column) => column);

  GeneratedColumn<String> get venueId =>
      $composableBuilder(column: $table.venueId, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ScheduleWorkspacesTableAnnotationComposer get workspaceId {
    final $$ScheduleWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.workspaceId,
            referencedTable: $db.scheduleWorkspaces,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleWorkspacesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduleWorkspaces,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$SchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool workspaceId})> {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workspaceId = const Value.absent(),
            Value<String> assignedCourseId = const Value.absent(),
            Value<String?> venueId = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SchedulesCompanion(
            id: id,
            workspaceId: workspaceId,
            assignedCourseId: assignedCourseId,
            venueId: venueId,
            startDate: startDate,
            endDate: endDate,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workspaceId,
            required String assignedCourseId,
            Value<String?> venueId = const Value.absent(),
            required DateTime startDate,
            required DateTime endDate,
            Value<String> status = const Value.absent(),
          }) =>
              SchedulesCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            assignedCourseId: assignedCourseId,
            venueId: venueId,
            startDate: startDate,
            endDate: endDate,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workspaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$SchedulesTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$SchedulesTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool workspaceId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScheduleWorkspacesTableTableManager get scheduleWorkspaces =>
      $$ScheduleWorkspacesTableTableManager(_db, _db.scheduleWorkspaces);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$TrainersTableTableManager get trainers =>
      $$TrainersTableTableManager(_db, _db.trainers);
  $$VenuesTableTableManager get venues =>
      $$VenuesTableTableManager(_db, _db.venues);
  $$CalendarDaysTableTableManager get calendarDays =>
      $$CalendarDaysTableTableManager(_db, _db.calendarDays);
  $$AssignedCoursesTableTableManager get assignedCourses =>
      $$AssignedCoursesTableTableManager(_db, _db.assignedCourses);
  $$TrainerUnavailableDatesTableTableManager get trainerUnavailableDates =>
      $$TrainerUnavailableDatesTableTableManager(
          _db, _db.trainerUnavailableDates);
  $$VenueUnavailableDatesTableTableManager get venueUnavailableDates =>
      $$VenueUnavailableDatesTableTableManager(_db, _db.venueUnavailableDates);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
}
