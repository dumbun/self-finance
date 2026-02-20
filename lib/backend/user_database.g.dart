// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// ignore_for_file: type=lint
class $UserTableTable extends UserTable
    with TableInfo<$UserTableTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'ID',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'USER_NAME',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userPinMeta = const VerificationMeta(
    'userPin',
  );
  @override
  late final GeneratedColumn<String> userPin = GeneratedColumn<String>(
    'USER_PIN',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userCurrencyMeta = const VerificationMeta(
    'userCurrency',
  );
  @override
  late final GeneratedColumn<String> userCurrency = GeneratedColumn<String>(
    'USER_CURRENCY',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profilePictureMeta = const VerificationMeta(
    'profilePicture',
  );
  @override
  late final GeneratedColumn<String> profilePicture = GeneratedColumn<String>(
    'USER_PROFILE_PICTURE',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userName,
    userPin,
    userCurrency,
    profilePicture,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'USER';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ID')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['ID']!, _idMeta));
    }
    if (data.containsKey('USER_NAME')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['USER_NAME']!, _userNameMeta),
      );
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('USER_PIN')) {
      context.handle(
        _userPinMeta,
        userPin.isAcceptableOrUnknown(data['USER_PIN']!, _userPinMeta),
      );
    } else if (isInserting) {
      context.missing(_userPinMeta);
    }
    if (data.containsKey('USER_CURRENCY')) {
      context.handle(
        _userCurrencyMeta,
        userCurrency.isAcceptableOrUnknown(
          data['USER_CURRENCY']!,
          _userCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userCurrencyMeta);
    }
    if (data.containsKey('USER_PROFILE_PICTURE')) {
      context.handle(
        _profilePictureMeta,
        profilePicture.isAcceptableOrUnknown(
          data['USER_PROFILE_PICTURE']!,
          _profilePictureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profilePictureMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ID'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}USER_NAME'],
      )!,
      userPin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}USER_PIN'],
      )!,
      userCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}USER_CURRENCY'],
      )!,
      profilePicture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}USER_PROFILE_PICTURE'],
      )!,
    );
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int id;
  final String userName;
  final String userPin;
  final String userCurrency;
  final String profilePicture;
  const UserRow({
    required this.id,
    required this.userName,
    required this.userPin,
    required this.userCurrency,
    required this.profilePicture,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ID'] = Variable<int>(id);
    map['USER_NAME'] = Variable<String>(userName);
    map['USER_PIN'] = Variable<String>(userPin);
    map['USER_CURRENCY'] = Variable<String>(userCurrency);
    map['USER_PROFILE_PICTURE'] = Variable<String>(profilePicture);
    return map;
  }

  UserTableCompanion toCompanion(bool nullToAbsent) {
    return UserTableCompanion(
      id: Value(id),
      userName: Value(userName),
      userPin: Value(userPin),
      userCurrency: Value(userCurrency),
      profilePicture: Value(profilePicture),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<int>(json['id']),
      userName: serializer.fromJson<String>(json['userName']),
      userPin: serializer.fromJson<String>(json['userPin']),
      userCurrency: serializer.fromJson<String>(json['userCurrency']),
      profilePicture: serializer.fromJson<String>(json['profilePicture']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userName': serializer.toJson<String>(userName),
      'userPin': serializer.toJson<String>(userPin),
      'userCurrency': serializer.toJson<String>(userCurrency),
      'profilePicture': serializer.toJson<String>(profilePicture),
    };
  }

  UserRow copyWith({
    int? id,
    String? userName,
    String? userPin,
    String? userCurrency,
    String? profilePicture,
  }) => UserRow(
    id: id ?? this.id,
    userName: userName ?? this.userName,
    userPin: userPin ?? this.userPin,
    userCurrency: userCurrency ?? this.userCurrency,
    profilePicture: profilePicture ?? this.profilePicture,
  );
  UserRow copyWithCompanion(UserTableCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      userName: data.userName.present ? data.userName.value : this.userName,
      userPin: data.userPin.present ? data.userPin.value : this.userPin,
      userCurrency: data.userCurrency.present
          ? data.userCurrency.value
          : this.userCurrency,
      profilePicture: data.profilePicture.present
          ? data.profilePicture.value
          : this.profilePicture,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('userPin: $userPin, ')
          ..write('userCurrency: $userCurrency, ')
          ..write('profilePicture: $profilePicture')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userName, userPin, userCurrency, profilePicture);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.userPin == this.userPin &&
          other.userCurrency == this.userCurrency &&
          other.profilePicture == this.profilePicture);
}

class UserTableCompanion extends UpdateCompanion<UserRow> {
  final Value<int> id;
  final Value<String> userName;
  final Value<String> userPin;
  final Value<String> userCurrency;
  final Value<String> profilePicture;
  const UserTableCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.userPin = const Value.absent(),
    this.userCurrency = const Value.absent(),
    this.profilePicture = const Value.absent(),
  });
  UserTableCompanion.insert({
    this.id = const Value.absent(),
    required String userName,
    required String userPin,
    required String userCurrency,
    required String profilePicture,
  }) : userName = Value(userName),
       userPin = Value(userPin),
       userCurrency = Value(userCurrency),
       profilePicture = Value(profilePicture);
  static Insertable<UserRow> custom({
    Expression<int>? id,
    Expression<String>? userName,
    Expression<String>? userPin,
    Expression<String>? userCurrency,
    Expression<String>? profilePicture,
  }) {
    return RawValuesInsertable({
      if (id != null) 'ID': id,
      if (userName != null) 'USER_NAME': userName,
      if (userPin != null) 'USER_PIN': userPin,
      if (userCurrency != null) 'USER_CURRENCY': userCurrency,
      if (profilePicture != null) 'USER_PROFILE_PICTURE': profilePicture,
    });
  }

  UserTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userName,
    Value<String>? userPin,
    Value<String>? userCurrency,
    Value<String>? profilePicture,
  }) {
    return UserTableCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userPin: userPin ?? this.userPin,
      userCurrency: userCurrency ?? this.userCurrency,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['ID'] = Variable<int>(id.value);
    }
    if (userName.present) {
      map['USER_NAME'] = Variable<String>(userName.value);
    }
    if (userPin.present) {
      map['USER_PIN'] = Variable<String>(userPin.value);
    }
    if (userCurrency.present) {
      map['USER_CURRENCY'] = Variable<String>(userCurrency.value);
    }
    if (profilePicture.present) {
      map['USER_PROFILE_PICTURE'] = Variable<String>(profilePicture.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTableCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('userPin: $userPin, ')
          ..write('userCurrency: $userCurrency, ')
          ..write('profilePicture: $profilePicture')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $UserTableTable userTable = $UserTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userTable];
}

typedef $$UserTableTableCreateCompanionBuilder =
    UserTableCompanion Function({
      Value<int> id,
      required String userName,
      required String userPin,
      required String userCurrency,
      required String profilePicture,
    });
typedef $$UserTableTableUpdateCompanionBuilder =
    UserTableCompanion Function({
      Value<int> id,
      Value<String> userName,
      Value<String> userPin,
      Value<String> userCurrency,
      Value<String> profilePicture,
    });

class $$UserTableTableFilterComposer
    extends Composer<_$UserDatabase, $UserTableTable> {
  $$UserTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userPin => $composableBuilder(
    column: $table.userPin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userCurrency => $composableBuilder(
    column: $table.userCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePicture => $composableBuilder(
    column: $table.profilePicture,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserTableTableOrderingComposer
    extends Composer<_$UserDatabase, $UserTableTable> {
  $$UserTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userPin => $composableBuilder(
    column: $table.userPin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userCurrency => $composableBuilder(
    column: $table.userCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePicture => $composableBuilder(
    column: $table.profilePicture,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserTableTableAnnotationComposer
    extends Composer<_$UserDatabase, $UserTableTable> {
  $$UserTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get userPin =>
      $composableBuilder(column: $table.userPin, builder: (column) => column);

  GeneratedColumn<String> get userCurrency => $composableBuilder(
    column: $table.userCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profilePicture => $composableBuilder(
    column: $table.profilePicture,
    builder: (column) => column,
  );
}

class $$UserTableTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $UserTableTable,
          UserRow,
          $$UserTableTableFilterComposer,
          $$UserTableTableOrderingComposer,
          $$UserTableTableAnnotationComposer,
          $$UserTableTableCreateCompanionBuilder,
          $$UserTableTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$UserDatabase, $UserTableTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UserTableTableTableManager(_$UserDatabase db, $UserTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<String> userPin = const Value.absent(),
                Value<String> userCurrency = const Value.absent(),
                Value<String> profilePicture = const Value.absent(),
              }) => UserTableCompanion(
                id: id,
                userName: userName,
                userPin: userPin,
                userCurrency: userCurrency,
                profilePicture: profilePicture,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userName,
                required String userPin,
                required String userCurrency,
                required String profilePicture,
              }) => UserTableCompanion.insert(
                id: id,
                userName: userName,
                userPin: userPin,
                userCurrency: userCurrency,
                profilePicture: profilePicture,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserTableTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $UserTableTable,
      UserRow,
      $$UserTableTableFilterComposer,
      $$UserTableTableOrderingComposer,
      $$UserTableTableAnnotationComposer,
      $$UserTableTableCreateCompanionBuilder,
      $$UserTableTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$UserDatabase, $UserTableTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$UserTableTableTableManager get userTable =>
      $$UserTableTableTableManager(_db, _db.userTable);
}
