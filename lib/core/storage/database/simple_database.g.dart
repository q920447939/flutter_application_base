// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_database.dart';

// ignore_for_file: type=lint
class $SimpleUsersTable extends SimpleUsers
    with TableInfo<$SimpleUsersTable, SimpleUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimpleUsersTable(this.attachedDatabase, [this._alias]);
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
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, email, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'simple_users';
  @override
  VerificationContext validateIntegrity(Insertable<SimpleUser> instance,
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
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SimpleUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimpleUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SimpleUsersTable createAlias(String alias) {
    return $SimpleUsersTable(attachedDatabase, alias);
  }
}

class SimpleUser extends DataClass implements Insertable<SimpleUser> {
  final int id;
  final String name;
  final String? email;
  final DateTime createdAt;
  const SimpleUser(
      {required this.id,
      required this.name,
      this.email,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SimpleUsersCompanion toCompanion(bool nullToAbsent) {
    return SimpleUsersCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      createdAt: Value(createdAt),
    );
  }

  factory SimpleUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimpleUser(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SimpleUser copyWith(
          {int? id,
          String? name,
          Value<String?> email = const Value.absent(),
          DateTime? createdAt}) =>
      SimpleUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        createdAt: createdAt ?? this.createdAt,
      );
  SimpleUser copyWithCompanion(SimpleUsersCompanion data) {
    return SimpleUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimpleUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimpleUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.createdAt == this.createdAt);
}

class SimpleUsersCompanion extends UpdateCompanion<SimpleUser> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<DateTime> createdAt;
  const SimpleUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SimpleUsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SimpleUser> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SimpleUsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<DateTime>? createdAt}) {
    return SimpleUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimpleUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$SimpleDatabase extends GeneratedDatabase {
  _$SimpleDatabase(QueryExecutor e) : super(e);
  _$SimpleDatabase.connect(DatabaseConnection c) : super.connect(c);
  $SimpleDatabaseManager get managers => $SimpleDatabaseManager(this);
  late final $SimpleUsersTable simpleUsers = $SimpleUsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [simpleUsers];
}

typedef $$SimpleUsersTableCreateCompanionBuilder = SimpleUsersCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> email,
  Value<DateTime> createdAt,
});
typedef $$SimpleUsersTableUpdateCompanionBuilder = SimpleUsersCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> email,
  Value<DateTime> createdAt,
});

class $$SimpleUsersTableFilterComposer
    extends Composer<_$SimpleDatabase, $SimpleUsersTable> {
  $$SimpleUsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SimpleUsersTableOrderingComposer
    extends Composer<_$SimpleDatabase, $SimpleUsersTable> {
  $$SimpleUsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SimpleUsersTableAnnotationComposer
    extends Composer<_$SimpleDatabase, $SimpleUsersTable> {
  $$SimpleUsersTableAnnotationComposer({
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SimpleUsersTableTableManager extends RootTableManager<
    _$SimpleDatabase,
    $SimpleUsersTable,
    SimpleUser,
    $$SimpleUsersTableFilterComposer,
    $$SimpleUsersTableOrderingComposer,
    $$SimpleUsersTableAnnotationComposer,
    $$SimpleUsersTableCreateCompanionBuilder,
    $$SimpleUsersTableUpdateCompanionBuilder,
    (
      SimpleUser,
      BaseReferences<_$SimpleDatabase, $SimpleUsersTable, SimpleUser>
    ),
    SimpleUser,
    PrefetchHooks Function()> {
  $$SimpleUsersTableTableManager(_$SimpleDatabase db, $SimpleUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimpleUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SimpleUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SimpleUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SimpleUsersCompanion(
            id: id,
            name: name,
            email: email,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> email = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SimpleUsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SimpleUsersTableProcessedTableManager = ProcessedTableManager<
    _$SimpleDatabase,
    $SimpleUsersTable,
    SimpleUser,
    $$SimpleUsersTableFilterComposer,
    $$SimpleUsersTableOrderingComposer,
    $$SimpleUsersTableAnnotationComposer,
    $$SimpleUsersTableCreateCompanionBuilder,
    $$SimpleUsersTableUpdateCompanionBuilder,
    (
      SimpleUser,
      BaseReferences<_$SimpleDatabase, $SimpleUsersTable, SimpleUser>
    ),
    SimpleUser,
    PrefetchHooks Function()>;

class $SimpleDatabaseManager {
  final _$SimpleDatabase _db;
  $SimpleDatabaseManager(this._db);
  $$SimpleUsersTableTableManager get simpleUsers =>
      $$SimpleUsersTableTableManager(_db, _db.simpleUsers);
}
