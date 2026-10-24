// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend.dart';

// ignore_for_file: type=lint
class $CustomersTableTable extends CustomersTable
    with TableInfo<$CustomersTableTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'User_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'Customer_ID',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'Customer_Name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gaurdianNameMeta = const VerificationMeta(
    'gaurdianName',
  );
  @override
  late final GeneratedColumn<String> gaurdianName = GeneratedColumn<String>(
    'Gaurdian_Name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerAddressMeta = const VerificationMeta(
    'customerAddress',
  );
  @override
  late final GeneratedColumn<String> customerAddress = GeneratedColumn<String>(
    'Customer_Address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNumberMeta = const VerificationMeta(
    'contactNumber',
  );
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
    'Contact_Number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _customerPhotoMeta = const VerificationMeta(
    'customerPhoto',
  );
  @override
  late final GeneratedColumn<String> customerPhoto = GeneratedColumn<String>(
    'Customer_Photo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proofPhotoMeta = const VerificationMeta(
    'proofPhoto',
  );
  @override
  late final GeneratedColumn<String> proofPhoto = GeneratedColumn<String>(
    'Proof_Photo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'Created_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedDateMeta = const VerificationMeta(
    'updatedDate',
  );
  @override
  late final GeneratedColumn<String> updatedDate = GeneratedColumn<String>(
    'Updated_Date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'Sync_ID',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'Updated_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'Deleted_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    customerId,
    customerName,
    gaurdianName,
    customerAddress,
    contactNumber,
    customerPhoto,
    proofPhoto,
    createdDate,
    updatedDate,
    syncId,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('User_ID')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['User_ID']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('Customer_ID')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['Customer_ID']!, _customerIdMeta),
      );
    }
    if (data.containsKey('Customer_Name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['Customer_Name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('Gaurdian_Name')) {
      context.handle(
        _gaurdianNameMeta,
        gaurdianName.isAcceptableOrUnknown(
          data['Gaurdian_Name']!,
          _gaurdianNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gaurdianNameMeta);
    }
    if (data.containsKey('Customer_Address')) {
      context.handle(
        _customerAddressMeta,
        customerAddress.isAcceptableOrUnknown(
          data['Customer_Address']!,
          _customerAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerAddressMeta);
    }
    if (data.containsKey('Contact_Number')) {
      context.handle(
        _contactNumberMeta,
        contactNumber.isAcceptableOrUnknown(
          data['Contact_Number']!,
          _contactNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactNumberMeta);
    }
    if (data.containsKey('Customer_Photo')) {
      context.handle(
        _customerPhotoMeta,
        customerPhoto.isAcceptableOrUnknown(
          data['Customer_Photo']!,
          _customerPhotoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerPhotoMeta);
    }
    if (data.containsKey('Proof_Photo')) {
      context.handle(
        _proofPhotoMeta,
        proofPhoto.isAcceptableOrUnknown(data['Proof_Photo']!, _proofPhotoMeta),
      );
    } else if (isInserting) {
      context.missing(_proofPhotoMeta);
    }
    if (data.containsKey('Created_Date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['Created_Date']!,
          _createdDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdDateMeta);
    }
    if (data.containsKey('Updated_Date')) {
      context.handle(
        _updatedDateMeta,
        updatedDate.isAcceptableOrUnknown(
          data['Updated_Date']!,
          _updatedDateMeta,
        ),
      );
    }
    if (data.containsKey('Sync_ID')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['Sync_ID']!, _syncIdMeta),
      );
    }
    if (data.containsKey('Updated_At')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['Updated_At']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('Deleted_At')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['Deleted_At']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {customerId};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}User_ID'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Customer_ID'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Customer_Name'],
      )!,
      gaurdianName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Gaurdian_Name'],
      )!,
      customerAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Customer_Address'],
      )!,
      contactNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Contact_Number'],
      )!,
      customerPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Customer_Photo'],
      )!,
      proofPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Proof_Photo'],
      )!,
      createdDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Created_Date'],
      )!,
      updatedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Updated_Date'],
      ),
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Sync_ID'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Updated_At'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Deleted_At'],
      ),
    );
  }

  @override
  $CustomersTableTable createAlias(String alias) {
    return $CustomersTableTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final int userId;
  final int customerId;
  final String customerName;
  final String gaurdianName;
  final String customerAddress;
  final String contactNumber;
  final String customerPhoto;
  final String proofPhoto;
  final DateTime createdDate;

  /// keeping as TEXT (your code uses ISO strings)
  final String? updatedDate;
  final String syncId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const CustomerRow({
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.gaurdianName,
    required this.customerAddress,
    required this.contactNumber,
    required this.customerPhoto,
    required this.proofPhoto,
    required this.createdDate,
    this.updatedDate,
    required this.syncId,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['User_ID'] = Variable<int>(userId);
    map['Customer_ID'] = Variable<int>(customerId);
    map['Customer_Name'] = Variable<String>(customerName);
    map['Gaurdian_Name'] = Variable<String>(gaurdianName);
    map['Customer_Address'] = Variable<String>(customerAddress);
    map['Contact_Number'] = Variable<String>(contactNumber);
    map['Customer_Photo'] = Variable<String>(customerPhoto);
    map['Proof_Photo'] = Variable<String>(proofPhoto);
    map['Created_Date'] = Variable<DateTime>(createdDate);
    if (!nullToAbsent || updatedDate != null) {
      map['Updated_Date'] = Variable<String>(updatedDate);
    }
    map['Sync_ID'] = Variable<String>(syncId);
    if (!nullToAbsent || updatedAt != null) {
      map['Updated_At'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CustomersTableCompanion toCompanion(bool nullToAbsent) {
    return CustomersTableCompanion(
      userId: Value(userId),
      customerId: Value(customerId),
      customerName: Value(customerName),
      gaurdianName: Value(gaurdianName),
      customerAddress: Value(customerAddress),
      contactNumber: Value(contactNumber),
      customerPhoto: Value(customerPhoto),
      proofPhoto: Value(proofPhoto),
      createdDate: Value(createdDate),
      updatedDate: updatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedDate),
      syncId: Value(syncId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      userId: serializer.fromJson<int>(json['userId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      gaurdianName: serializer.fromJson<String>(json['gaurdianName']),
      customerAddress: serializer.fromJson<String>(json['customerAddress']),
      contactNumber: serializer.fromJson<String>(json['contactNumber']),
      customerPhoto: serializer.fromJson<String>(json['customerPhoto']),
      proofPhoto: serializer.fromJson<String>(json['proofPhoto']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedDate: serializer.fromJson<String?>(json['updatedDate']),
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'customerId': serializer.toJson<int>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'gaurdianName': serializer.toJson<String>(gaurdianName),
      'customerAddress': serializer.toJson<String>(customerAddress),
      'contactNumber': serializer.toJson<String>(contactNumber),
      'customerPhoto': serializer.toJson<String>(customerPhoto),
      'proofPhoto': serializer.toJson<String>(proofPhoto),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedDate': serializer.toJson<String?>(updatedDate),
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CustomerRow copyWith({
    int? userId,
    int? customerId,
    String? customerName,
    String? gaurdianName,
    String? customerAddress,
    String? contactNumber,
    String? customerPhoto,
    String? proofPhoto,
    DateTime? createdDate,
    Value<String?> updatedDate = const Value.absent(),
    String? syncId,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CustomerRow(
    userId: userId ?? this.userId,
    customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    gaurdianName: gaurdianName ?? this.gaurdianName,
    customerAddress: customerAddress ?? this.customerAddress,
    contactNumber: contactNumber ?? this.contactNumber,
    customerPhoto: customerPhoto ?? this.customerPhoto,
    proofPhoto: proofPhoto ?? this.proofPhoto,
    createdDate: createdDate ?? this.createdDate,
    updatedDate: updatedDate.present ? updatedDate.value : this.updatedDate,
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CustomerRow copyWithCompanion(CustomersTableCompanion data) {
    return CustomerRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      gaurdianName: data.gaurdianName.present
          ? data.gaurdianName.value
          : this.gaurdianName,
      customerAddress: data.customerAddress.present
          ? data.customerAddress.value
          : this.customerAddress,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
      customerPhoto: data.customerPhoto.present
          ? data.customerPhoto.value
          : this.customerPhoto,
      proofPhoto: data.proofPhoto.present
          ? data.proofPhoto.value
          : this.proofPhoto,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedDate: data.updatedDate.present
          ? data.updatedDate.value
          : this.updatedDate,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('gaurdianName: $gaurdianName, ')
          ..write('customerAddress: $customerAddress, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('customerPhoto: $customerPhoto, ')
          ..write('proofPhoto: $proofPhoto, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    customerId,
    customerName,
    gaurdianName,
    customerAddress,
    contactNumber,
    customerPhoto,
    proofPhoto,
    createdDate,
    updatedDate,
    syncId,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.userId == this.userId &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.gaurdianName == this.gaurdianName &&
          other.customerAddress == this.customerAddress &&
          other.contactNumber == this.contactNumber &&
          other.customerPhoto == this.customerPhoto &&
          other.proofPhoto == this.proofPhoto &&
          other.createdDate == this.createdDate &&
          other.updatedDate == this.updatedDate &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CustomersTableCompanion extends UpdateCompanion<CustomerRow> {
  final Value<int> userId;
  final Value<int> customerId;
  final Value<String> customerName;
  final Value<String> gaurdianName;
  final Value<String> customerAddress;
  final Value<String> contactNumber;
  final Value<String> customerPhoto;
  final Value<String> proofPhoto;
  final Value<DateTime> createdDate;
  final Value<String?> updatedDate;
  final Value<String> syncId;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const CustomersTableCompanion({
    this.userId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.gaurdianName = const Value.absent(),
    this.customerAddress = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.customerPhoto = const Value.absent(),
    this.proofPhoto = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  CustomersTableCompanion.insert({
    required int userId,
    this.customerId = const Value.absent(),
    required String customerName,
    required String gaurdianName,
    required String customerAddress,
    required String contactNumber,
    required String customerPhoto,
    required String proofPhoto,
    required DateTime createdDate,
    this.updatedDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : userId = Value(userId),
       customerName = Value(customerName),
       gaurdianName = Value(gaurdianName),
       customerAddress = Value(customerAddress),
       contactNumber = Value(contactNumber),
       customerPhoto = Value(customerPhoto),
       proofPhoto = Value(proofPhoto),
       createdDate = Value(createdDate);
  static Insertable<CustomerRow> custom({
    Expression<int>? userId,
    Expression<int>? customerId,
    Expression<String>? customerName,
    Expression<String>? gaurdianName,
    Expression<String>? customerAddress,
    Expression<String>? contactNumber,
    Expression<String>? customerPhoto,
    Expression<String>? proofPhoto,
    Expression<DateTime>? createdDate,
    Expression<String>? updatedDate,
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'User_ID': userId,
      if (customerId != null) 'Customer_ID': customerId,
      if (customerName != null) 'Customer_Name': customerName,
      if (gaurdianName != null) 'Gaurdian_Name': gaurdianName,
      if (customerAddress != null) 'Customer_Address': customerAddress,
      if (contactNumber != null) 'Contact_Number': contactNumber,
      if (customerPhoto != null) 'Customer_Photo': customerPhoto,
      if (proofPhoto != null) 'Proof_Photo': proofPhoto,
      if (createdDate != null) 'Created_Date': createdDate,
      if (updatedDate != null) 'Updated_Date': updatedDate,
      if (syncId != null) 'Sync_ID': syncId,
      if (updatedAt != null) 'Updated_At': updatedAt,
      if (deletedAt != null) 'Deleted_At': deletedAt,
    });
  }

  CustomersTableCompanion copyWith({
    Value<int>? userId,
    Value<int>? customerId,
    Value<String>? customerName,
    Value<String>? gaurdianName,
    Value<String>? customerAddress,
    Value<String>? contactNumber,
    Value<String>? customerPhoto,
    Value<String>? proofPhoto,
    Value<DateTime>? createdDate,
    Value<String?>? updatedDate,
    Value<String>? syncId,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return CustomersTableCompanion(
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      gaurdianName: gaurdianName ?? this.gaurdianName,
      customerAddress: customerAddress ?? this.customerAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      proofPhoto: proofPhoto ?? this.proofPhoto,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['User_ID'] = Variable<int>(userId.value);
    }
    if (customerId.present) {
      map['Customer_ID'] = Variable<int>(customerId.value);
    }
    if (customerName.present) {
      map['Customer_Name'] = Variable<String>(customerName.value);
    }
    if (gaurdianName.present) {
      map['Gaurdian_Name'] = Variable<String>(gaurdianName.value);
    }
    if (customerAddress.present) {
      map['Customer_Address'] = Variable<String>(customerAddress.value);
    }
    if (contactNumber.present) {
      map['Contact_Number'] = Variable<String>(contactNumber.value);
    }
    if (customerPhoto.present) {
      map['Customer_Photo'] = Variable<String>(customerPhoto.value);
    }
    if (proofPhoto.present) {
      map['Proof_Photo'] = Variable<String>(proofPhoto.value);
    }
    if (createdDate.present) {
      map['Created_Date'] = Variable<DateTime>(createdDate.value);
    }
    if (updatedDate.present) {
      map['Updated_Date'] = Variable<String>(updatedDate.value);
    }
    if (syncId.present) {
      map['Sync_ID'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['Updated_At'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableCompanion(')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('gaurdianName: $gaurdianName, ')
          ..write('customerAddress: $customerAddress, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('customerPhoto: $customerPhoto, ')
          ..write('proofPhoto: $proofPhoto, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $ItemsTableTable extends ItemsTable
    with TableInfo<$ItemsTableTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'Item_ID',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'Customer_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Customers (Customer_ID) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'Item_Name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemDescriptionMeta = const VerificationMeta(
    'itemDescription',
  );
  @override
  late final GeneratedColumn<String> itemDescription = GeneratedColumn<String>(
    'Item_Description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pawnedDateMeta = const VerificationMeta(
    'pawnedDate',
  );
  @override
  late final GeneratedColumn<DateTime> pawnedDate = GeneratedColumn<DateTime>(
    'Pawned_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'Expiry_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pawnAmountMeta = const VerificationMeta(
    'pawnAmount',
  );
  @override
  late final GeneratedColumn<double> pawnAmount = GeneratedColumn<double>(
    'Pawn_Amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemStatusMeta = const VerificationMeta(
    'itemStatus',
  );
  @override
  late final GeneratedColumn<String> itemStatus = GeneratedColumn<String>(
    'Item_Status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemPhotoMeta = const VerificationMeta(
    'itemPhoto',
  );
  @override
  late final GeneratedColumn<String> itemPhoto = GeneratedColumn<String>(
    'Item_Photo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'Created_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedDateMeta = const VerificationMeta(
    'updatedDate',
  );
  @override
  late final GeneratedColumn<String> updatedDate = GeneratedColumn<String>(
    'Updated_Date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'Sync_ID',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'Updated_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'Deleted_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    customerId,
    itemName,
    itemDescription,
    pawnedDate,
    expiryDate,
    pawnAmount,
    itemStatus,
    itemPhoto,
    createdDate,
    updatedDate,
    syncId,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('Item_ID')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['Item_ID']!, _itemIdMeta),
      );
    }
    if (data.containsKey('Customer_ID')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['Customer_ID']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('Item_Name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['Item_Name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('Item_Description')) {
      context.handle(
        _itemDescriptionMeta,
        itemDescription.isAcceptableOrUnknown(
          data['Item_Description']!,
          _itemDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_itemDescriptionMeta);
    }
    if (data.containsKey('Pawned_Date')) {
      context.handle(
        _pawnedDateMeta,
        pawnedDate.isAcceptableOrUnknown(data['Pawned_Date']!, _pawnedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_pawnedDateMeta);
    }
    if (data.containsKey('Expiry_Date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['Expiry_Date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('Pawn_Amount')) {
      context.handle(
        _pawnAmountMeta,
        pawnAmount.isAcceptableOrUnknown(data['Pawn_Amount']!, _pawnAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_pawnAmountMeta);
    }
    if (data.containsKey('Item_Status')) {
      context.handle(
        _itemStatusMeta,
        itemStatus.isAcceptableOrUnknown(data['Item_Status']!, _itemStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_itemStatusMeta);
    }
    if (data.containsKey('Item_Photo')) {
      context.handle(
        _itemPhotoMeta,
        itemPhoto.isAcceptableOrUnknown(data['Item_Photo']!, _itemPhotoMeta),
      );
    } else if (isInserting) {
      context.missing(_itemPhotoMeta);
    }
    if (data.containsKey('Created_Date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['Created_Date']!,
          _createdDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdDateMeta);
    }
    if (data.containsKey('Updated_Date')) {
      context.handle(
        _updatedDateMeta,
        updatedDate.isAcceptableOrUnknown(
          data['Updated_Date']!,
          _updatedDateMeta,
        ),
      );
    }
    if (data.containsKey('Sync_ID')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['Sync_ID']!, _syncIdMeta),
      );
    }
    if (data.containsKey('Updated_At')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['Updated_At']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('Deleted_At')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['Deleted_At']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Item_ID'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Customer_ID'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Item_Name'],
      )!,
      itemDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Item_Description'],
      )!,
      pawnedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Pawned_Date'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Expiry_Date'],
      )!,
      pawnAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}Pawn_Amount'],
      )!,
      itemStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Item_Status'],
      )!,
      itemPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Item_Photo'],
      )!,
      createdDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Created_Date'],
      )!,
      updatedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Updated_Date'],
      ),
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Sync_ID'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Updated_At'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Deleted_At'],
      ),
    );
  }

  @override
  $ItemsTableTable createAlias(String alias) {
    return $ItemsTableTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final int itemId;
  final int customerId;
  final String itemName;
  final String itemDescription;
  final DateTime pawnedDate;
  final DateTime expiryDate;
  final double pawnAmount;
  final String itemStatus;
  final String itemPhoto;
  final DateTime createdDate;

  /// keeping as TEXT (your code uses ISO strings)
  final String? updatedDate;
  final String syncId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const ItemRow({
    required this.itemId,
    required this.customerId,
    required this.itemName,
    required this.itemDescription,
    required this.pawnedDate,
    required this.expiryDate,
    required this.pawnAmount,
    required this.itemStatus,
    required this.itemPhoto,
    required this.createdDate,
    this.updatedDate,
    required this.syncId,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['Item_ID'] = Variable<int>(itemId);
    map['Customer_ID'] = Variable<int>(customerId);
    map['Item_Name'] = Variable<String>(itemName);
    map['Item_Description'] = Variable<String>(itemDescription);
    map['Pawned_Date'] = Variable<DateTime>(pawnedDate);
    map['Expiry_Date'] = Variable<DateTime>(expiryDate);
    map['Pawn_Amount'] = Variable<double>(pawnAmount);
    map['Item_Status'] = Variable<String>(itemStatus);
    map['Item_Photo'] = Variable<String>(itemPhoto);
    map['Created_Date'] = Variable<DateTime>(createdDate);
    if (!nullToAbsent || updatedDate != null) {
      map['Updated_Date'] = Variable<String>(updatedDate);
    }
    map['Sync_ID'] = Variable<String>(syncId);
    if (!nullToAbsent || updatedAt != null) {
      map['Updated_At'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ItemsTableCompanion(
      itemId: Value(itemId),
      customerId: Value(customerId),
      itemName: Value(itemName),
      itemDescription: Value(itemDescription),
      pawnedDate: Value(pawnedDate),
      expiryDate: Value(expiryDate),
      pawnAmount: Value(pawnAmount),
      itemStatus: Value(itemStatus),
      itemPhoto: Value(itemPhoto),
      createdDate: Value(createdDate),
      updatedDate: updatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedDate),
      syncId: Value(syncId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      itemId: serializer.fromJson<int>(json['itemId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      itemDescription: serializer.fromJson<String>(json['itemDescription']),
      pawnedDate: serializer.fromJson<DateTime>(json['pawnedDate']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      pawnAmount: serializer.fromJson<double>(json['pawnAmount']),
      itemStatus: serializer.fromJson<String>(json['itemStatus']),
      itemPhoto: serializer.fromJson<String>(json['itemPhoto']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedDate: serializer.fromJson<String?>(json['updatedDate']),
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<int>(itemId),
      'customerId': serializer.toJson<int>(customerId),
      'itemName': serializer.toJson<String>(itemName),
      'itemDescription': serializer.toJson<String>(itemDescription),
      'pawnedDate': serializer.toJson<DateTime>(pawnedDate),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'pawnAmount': serializer.toJson<double>(pawnAmount),
      'itemStatus': serializer.toJson<String>(itemStatus),
      'itemPhoto': serializer.toJson<String>(itemPhoto),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedDate': serializer.toJson<String?>(updatedDate),
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ItemRow copyWith({
    int? itemId,
    int? customerId,
    String? itemName,
    String? itemDescription,
    DateTime? pawnedDate,
    DateTime? expiryDate,
    double? pawnAmount,
    String? itemStatus,
    String? itemPhoto,
    DateTime? createdDate,
    Value<String?> updatedDate = const Value.absent(),
    String? syncId,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ItemRow(
    itemId: itemId ?? this.itemId,
    customerId: customerId ?? this.customerId,
    itemName: itemName ?? this.itemName,
    itemDescription: itemDescription ?? this.itemDescription,
    pawnedDate: pawnedDate ?? this.pawnedDate,
    expiryDate: expiryDate ?? this.expiryDate,
    pawnAmount: pawnAmount ?? this.pawnAmount,
    itemStatus: itemStatus ?? this.itemStatus,
    itemPhoto: itemPhoto ?? this.itemPhoto,
    createdDate: createdDate ?? this.createdDate,
    updatedDate: updatedDate.present ? updatedDate.value : this.updatedDate,
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ItemRow copyWithCompanion(ItemsTableCompanion data) {
    return ItemRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemDescription: data.itemDescription.present
          ? data.itemDescription.value
          : this.itemDescription,
      pawnedDate: data.pawnedDate.present
          ? data.pawnedDate.value
          : this.pawnedDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      pawnAmount: data.pawnAmount.present
          ? data.pawnAmount.value
          : this.pawnAmount,
      itemStatus: data.itemStatus.present
          ? data.itemStatus.value
          : this.itemStatus,
      itemPhoto: data.itemPhoto.present ? data.itemPhoto.value : this.itemPhoto,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedDate: data.updatedDate.present
          ? data.updatedDate.value
          : this.updatedDate,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('itemId: $itemId, ')
          ..write('customerId: $customerId, ')
          ..write('itemName: $itemName, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('pawnedDate: $pawnedDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('pawnAmount: $pawnAmount, ')
          ..write('itemStatus: $itemStatus, ')
          ..write('itemPhoto: $itemPhoto, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    customerId,
    itemName,
    itemDescription,
    pawnedDate,
    expiryDate,
    pawnAmount,
    itemStatus,
    itemPhoto,
    createdDate,
    updatedDate,
    syncId,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.itemId == this.itemId &&
          other.customerId == this.customerId &&
          other.itemName == this.itemName &&
          other.itemDescription == this.itemDescription &&
          other.pawnedDate == this.pawnedDate &&
          other.expiryDate == this.expiryDate &&
          other.pawnAmount == this.pawnAmount &&
          other.itemStatus == this.itemStatus &&
          other.itemPhoto == this.itemPhoto &&
          other.createdDate == this.createdDate &&
          other.updatedDate == this.updatedDate &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ItemsTableCompanion extends UpdateCompanion<ItemRow> {
  final Value<int> itemId;
  final Value<int> customerId;
  final Value<String> itemName;
  final Value<String> itemDescription;
  final Value<DateTime> pawnedDate;
  final Value<DateTime> expiryDate;
  final Value<double> pawnAmount;
  final Value<String> itemStatus;
  final Value<String> itemPhoto;
  final Value<DateTime> createdDate;
  final Value<String?> updatedDate;
  final Value<String> syncId;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const ItemsTableCompanion({
    this.itemId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemDescription = const Value.absent(),
    this.pawnedDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.pawnAmount = const Value.absent(),
    this.itemStatus = const Value.absent(),
    this.itemPhoto = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ItemsTableCompanion.insert({
    this.itemId = const Value.absent(),
    required int customerId,
    required String itemName,
    required String itemDescription,
    required DateTime pawnedDate,
    required DateTime expiryDate,
    required double pawnAmount,
    required String itemStatus,
    required String itemPhoto,
    required DateTime createdDate,
    this.updatedDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : customerId = Value(customerId),
       itemName = Value(itemName),
       itemDescription = Value(itemDescription),
       pawnedDate = Value(pawnedDate),
       expiryDate = Value(expiryDate),
       pawnAmount = Value(pawnAmount),
       itemStatus = Value(itemStatus),
       itemPhoto = Value(itemPhoto),
       createdDate = Value(createdDate);
  static Insertable<ItemRow> custom({
    Expression<int>? itemId,
    Expression<int>? customerId,
    Expression<String>? itemName,
    Expression<String>? itemDescription,
    Expression<DateTime>? pawnedDate,
    Expression<DateTime>? expiryDate,
    Expression<double>? pawnAmount,
    Expression<String>? itemStatus,
    Expression<String>? itemPhoto,
    Expression<DateTime>? createdDate,
    Expression<String>? updatedDate,
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'Item_ID': itemId,
      if (customerId != null) 'Customer_ID': customerId,
      if (itemName != null) 'Item_Name': itemName,
      if (itemDescription != null) 'Item_Description': itemDescription,
      if (pawnedDate != null) 'Pawned_Date': pawnedDate,
      if (expiryDate != null) 'Expiry_Date': expiryDate,
      if (pawnAmount != null) 'Pawn_Amount': pawnAmount,
      if (itemStatus != null) 'Item_Status': itemStatus,
      if (itemPhoto != null) 'Item_Photo': itemPhoto,
      if (createdDate != null) 'Created_Date': createdDate,
      if (updatedDate != null) 'Updated_Date': updatedDate,
      if (syncId != null) 'Sync_ID': syncId,
      if (updatedAt != null) 'Updated_At': updatedAt,
      if (deletedAt != null) 'Deleted_At': deletedAt,
    });
  }

  ItemsTableCompanion copyWith({
    Value<int>? itemId,
    Value<int>? customerId,
    Value<String>? itemName,
    Value<String>? itemDescription,
    Value<DateTime>? pawnedDate,
    Value<DateTime>? expiryDate,
    Value<double>? pawnAmount,
    Value<String>? itemStatus,
    Value<String>? itemPhoto,
    Value<DateTime>? createdDate,
    Value<String?>? updatedDate,
    Value<String>? syncId,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ItemsTableCompanion(
      itemId: itemId ?? this.itemId,
      customerId: customerId ?? this.customerId,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      pawnedDate: pawnedDate ?? this.pawnedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      pawnAmount: pawnAmount ?? this.pawnAmount,
      itemStatus: itemStatus ?? this.itemStatus,
      itemPhoto: itemPhoto ?? this.itemPhoto,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['Item_ID'] = Variable<int>(itemId.value);
    }
    if (customerId.present) {
      map['Customer_ID'] = Variable<int>(customerId.value);
    }
    if (itemName.present) {
      map['Item_Name'] = Variable<String>(itemName.value);
    }
    if (itemDescription.present) {
      map['Item_Description'] = Variable<String>(itemDescription.value);
    }
    if (pawnedDate.present) {
      map['Pawned_Date'] = Variable<DateTime>(pawnedDate.value);
    }
    if (expiryDate.present) {
      map['Expiry_Date'] = Variable<DateTime>(expiryDate.value);
    }
    if (pawnAmount.present) {
      map['Pawn_Amount'] = Variable<double>(pawnAmount.value);
    }
    if (itemStatus.present) {
      map['Item_Status'] = Variable<String>(itemStatus.value);
    }
    if (itemPhoto.present) {
      map['Item_Photo'] = Variable<String>(itemPhoto.value);
    }
    if (createdDate.present) {
      map['Created_Date'] = Variable<DateTime>(createdDate.value);
    }
    if (updatedDate.present) {
      map['Updated_Date'] = Variable<String>(updatedDate.value);
    }
    if (syncId.present) {
      map['Sync_ID'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['Updated_At'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsTableCompanion(')
          ..write('itemId: $itemId, ')
          ..write('customerId: $customerId, ')
          ..write('itemName: $itemName, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('pawnedDate: $pawnedDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('pawnAmount: $pawnAmount, ')
          ..write('itemStatus: $itemStatus, ')
          ..write('itemPhoto: $itemPhoto, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'Transaction_ID',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'Customer_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Customers (Customer_ID) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'Item_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Items (Item_ID) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'Transaction_Date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'Transaction_Type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'Amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'Interest_Rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestAmountMeta = const VerificationMeta(
    'interestAmount',
  );
  @override
  late final GeneratedColumn<double> interestAmount = GeneratedColumn<double>(
    'Interest_Amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingAmountMeta = const VerificationMeta(
    'remainingAmount',
  );
  @override
  late final GeneratedColumn<double> remainingAmount = GeneratedColumn<double>(
    'Remaining_Amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'Signature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'Created_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedDateMeta = const VerificationMeta(
    'updatedDate',
  );
  @override
  late final GeneratedColumn<String> updatedDate = GeneratedColumn<String>(
    'Updated_Date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'Sync_ID',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'Updated_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'Deleted_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    transactionId,
    customerId,
    itemId,
    transactionDate,
    transactionType,
    amount,
    interestRate,
    interestAmount,
    remainingAmount,
    signature,
    createdDate,
    updatedDate,
    syncId,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('Transaction_ID')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['Transaction_ID']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('Customer_ID')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['Customer_ID']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('Item_ID')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['Item_ID']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('Transaction_Date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['Transaction_Date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('Transaction_Type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['Transaction_Type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('Amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['Amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('Interest_Rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['Interest_Rate']!,
          _interestRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestRateMeta);
    }
    if (data.containsKey('Interest_Amount')) {
      context.handle(
        _interestAmountMeta,
        interestAmount.isAcceptableOrUnknown(
          data['Interest_Amount']!,
          _interestAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestAmountMeta);
    }
    if (data.containsKey('Remaining_Amount')) {
      context.handle(
        _remainingAmountMeta,
        remainingAmount.isAcceptableOrUnknown(
          data['Remaining_Amount']!,
          _remainingAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingAmountMeta);
    }
    if (data.containsKey('Signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['Signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('Created_Date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['Created_Date']!,
          _createdDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdDateMeta);
    }
    if (data.containsKey('Updated_Date')) {
      context.handle(
        _updatedDateMeta,
        updatedDate.isAcceptableOrUnknown(
          data['Updated_Date']!,
          _updatedDateMeta,
        ),
      );
    }
    if (data.containsKey('Sync_ID')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['Sync_ID']!, _syncIdMeta),
      );
    }
    if (data.containsKey('Updated_At')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['Updated_At']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('Deleted_At')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['Deleted_At']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Transaction_ID'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Customer_ID'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Item_ID'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Transaction_Date'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Transaction_Type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}Amount'],
      )!,
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}Interest_Rate'],
      )!,
      interestAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}Interest_Amount'],
      )!,
      remainingAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}Remaining_Amount'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Signature'],
      )!,
      createdDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Created_Date'],
      )!,
      updatedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Updated_Date'],
      ),
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Sync_ID'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Updated_At'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Deleted_At'],
      ),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final int transactionId;
  final int customerId;
  final int itemId;
  final DateTime transactionDate;
  final String transactionType;
  final double amount;
  final double interestRate;
  final double interestAmount;
  final double remainingAmount;
  final String signature;
  final DateTime createdDate;

  /// keeping as TEXT (your code uses ISO strings)
  final String? updatedDate;
  final String syncId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const TransactionRow({
    required this.transactionId,
    required this.customerId,
    required this.itemId,
    required this.transactionDate,
    required this.transactionType,
    required this.amount,
    required this.interestRate,
    required this.interestAmount,
    required this.remainingAmount,
    required this.signature,
    required this.createdDate,
    this.updatedDate,
    required this.syncId,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['Transaction_ID'] = Variable<int>(transactionId);
    map['Customer_ID'] = Variable<int>(customerId);
    map['Item_ID'] = Variable<int>(itemId);
    map['Transaction_Date'] = Variable<DateTime>(transactionDate);
    map['Transaction_Type'] = Variable<String>(transactionType);
    map['Amount'] = Variable<double>(amount);
    map['Interest_Rate'] = Variable<double>(interestRate);
    map['Interest_Amount'] = Variable<double>(interestAmount);
    map['Remaining_Amount'] = Variable<double>(remainingAmount);
    map['Signature'] = Variable<String>(signature);
    map['Created_Date'] = Variable<DateTime>(createdDate);
    if (!nullToAbsent || updatedDate != null) {
      map['Updated_Date'] = Variable<String>(updatedDate);
    }
    map['Sync_ID'] = Variable<String>(syncId);
    if (!nullToAbsent || updatedAt != null) {
      map['Updated_At'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      transactionId: Value(transactionId),
      customerId: Value(customerId),
      itemId: Value(itemId),
      transactionDate: Value(transactionDate),
      transactionType: Value(transactionType),
      amount: Value(amount),
      interestRate: Value(interestRate),
      interestAmount: Value(interestAmount),
      remainingAmount: Value(remainingAmount),
      signature: Value(signature),
      createdDate: Value(createdDate),
      updatedDate: updatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedDate),
      syncId: Value(syncId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      transactionId: serializer.fromJson<int>(json['transactionId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      amount: serializer.fromJson<double>(json['amount']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      interestAmount: serializer.fromJson<double>(json['interestAmount']),
      remainingAmount: serializer.fromJson<double>(json['remainingAmount']),
      signature: serializer.fromJson<String>(json['signature']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      updatedDate: serializer.fromJson<String?>(json['updatedDate']),
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<int>(transactionId),
      'customerId': serializer.toJson<int>(customerId),
      'itemId': serializer.toJson<int>(itemId),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'transactionType': serializer.toJson<String>(transactionType),
      'amount': serializer.toJson<double>(amount),
      'interestRate': serializer.toJson<double>(interestRate),
      'interestAmount': serializer.toJson<double>(interestAmount),
      'remainingAmount': serializer.toJson<double>(remainingAmount),
      'signature': serializer.toJson<String>(signature),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'updatedDate': serializer.toJson<String?>(updatedDate),
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TransactionRow copyWith({
    int? transactionId,
    int? customerId,
    int? itemId,
    DateTime? transactionDate,
    String? transactionType,
    double? amount,
    double? interestRate,
    double? interestAmount,
    double? remainingAmount,
    String? signature,
    DateTime? createdDate,
    Value<String?> updatedDate = const Value.absent(),
    String? syncId,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TransactionRow(
    transactionId: transactionId ?? this.transactionId,
    customerId: customerId ?? this.customerId,
    itemId: itemId ?? this.itemId,
    transactionDate: transactionDate ?? this.transactionDate,
    transactionType: transactionType ?? this.transactionType,
    amount: amount ?? this.amount,
    interestRate: interestRate ?? this.interestRate,
    interestAmount: interestAmount ?? this.interestAmount,
    remainingAmount: remainingAmount ?? this.remainingAmount,
    signature: signature ?? this.signature,
    createdDate: createdDate ?? this.createdDate,
    updatedDate: updatedDate.present ? updatedDate.value : this.updatedDate,
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TransactionRow copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      interestAmount: data.interestAmount.present
          ? data.interestAmount.value
          : this.interestAmount,
      remainingAmount: data.remainingAmount.present
          ? data.remainingAmount.value
          : this.remainingAmount,
      signature: data.signature.present ? data.signature.value : this.signature,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      updatedDate: data.updatedDate.present
          ? data.updatedDate.value
          : this.updatedDate,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('transactionId: $transactionId, ')
          ..write('customerId: $customerId, ')
          ..write('itemId: $itemId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('interestRate: $interestRate, ')
          ..write('interestAmount: $interestAmount, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('signature: $signature, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    transactionId,
    customerId,
    itemId,
    transactionDate,
    transactionType,
    amount,
    interestRate,
    interestAmount,
    remainingAmount,
    signature,
    createdDate,
    updatedDate,
    syncId,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.transactionId == this.transactionId &&
          other.customerId == this.customerId &&
          other.itemId == this.itemId &&
          other.transactionDate == this.transactionDate &&
          other.transactionType == this.transactionType &&
          other.amount == this.amount &&
          other.interestRate == this.interestRate &&
          other.interestAmount == this.interestAmount &&
          other.remainingAmount == this.remainingAmount &&
          other.signature == this.signature &&
          other.createdDate == this.createdDate &&
          other.updatedDate == this.updatedDate &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TransactionsTableCompanion extends UpdateCompanion<TransactionRow> {
  final Value<int> transactionId;
  final Value<int> customerId;
  final Value<int> itemId;
  final Value<DateTime> transactionDate;
  final Value<String> transactionType;
  final Value<double> amount;
  final Value<double> interestRate;
  final Value<double> interestAmount;
  final Value<double> remainingAmount;
  final Value<String> signature;
  final Value<DateTime> createdDate;
  final Value<String?> updatedDate;
  final Value<String> syncId;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const TransactionsTableCompanion({
    this.transactionId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.interestAmount = const Value.absent(),
    this.remainingAmount = const Value.absent(),
    this.signature = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.updatedDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    this.transactionId = const Value.absent(),
    required int customerId,
    required int itemId,
    required DateTime transactionDate,
    required String transactionType,
    required double amount,
    required double interestRate,
    required double interestAmount,
    required double remainingAmount,
    required String signature,
    required DateTime createdDate,
    this.updatedDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : customerId = Value(customerId),
       itemId = Value(itemId),
       transactionDate = Value(transactionDate),
       transactionType = Value(transactionType),
       amount = Value(amount),
       interestRate = Value(interestRate),
       interestAmount = Value(interestAmount),
       remainingAmount = Value(remainingAmount),
       signature = Value(signature),
       createdDate = Value(createdDate);
  static Insertable<TransactionRow> custom({
    Expression<int>? transactionId,
    Expression<int>? customerId,
    Expression<int>? itemId,
    Expression<DateTime>? transactionDate,
    Expression<String>? transactionType,
    Expression<double>? amount,
    Expression<double>? interestRate,
    Expression<double>? interestAmount,
    Expression<double>? remainingAmount,
    Expression<String>? signature,
    Expression<DateTime>? createdDate,
    Expression<String>? updatedDate,
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'Transaction_ID': transactionId,
      if (customerId != null) 'Customer_ID': customerId,
      if (itemId != null) 'Item_ID': itemId,
      if (transactionDate != null) 'Transaction_Date': transactionDate,
      if (transactionType != null) 'Transaction_Type': transactionType,
      if (amount != null) 'Amount': amount,
      if (interestRate != null) 'Interest_Rate': interestRate,
      if (interestAmount != null) 'Interest_Amount': interestAmount,
      if (remainingAmount != null) 'Remaining_Amount': remainingAmount,
      if (signature != null) 'Signature': signature,
      if (createdDate != null) 'Created_Date': createdDate,
      if (updatedDate != null) 'Updated_Date': updatedDate,
      if (syncId != null) 'Sync_ID': syncId,
      if (updatedAt != null) 'Updated_At': updatedAt,
      if (deletedAt != null) 'Deleted_At': deletedAt,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<int>? transactionId,
    Value<int>? customerId,
    Value<int>? itemId,
    Value<DateTime>? transactionDate,
    Value<String>? transactionType,
    Value<double>? amount,
    Value<double>? interestRate,
    Value<double>? interestAmount,
    Value<double>? remainingAmount,
    Value<String>? signature,
    Value<DateTime>? createdDate,
    Value<String?>? updatedDate,
    Value<String>? syncId,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return TransactionsTableCompanion(
      transactionId: transactionId ?? this.transactionId,
      customerId: customerId ?? this.customerId,
      itemId: itemId ?? this.itemId,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      interestRate: interestRate ?? this.interestRate,
      interestAmount: interestAmount ?? this.interestAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      signature: signature ?? this.signature,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['Transaction_ID'] = Variable<int>(transactionId.value);
    }
    if (customerId.present) {
      map['Customer_ID'] = Variable<int>(customerId.value);
    }
    if (itemId.present) {
      map['Item_ID'] = Variable<int>(itemId.value);
    }
    if (transactionDate.present) {
      map['Transaction_Date'] = Variable<DateTime>(transactionDate.value);
    }
    if (transactionType.present) {
      map['Transaction_Type'] = Variable<String>(transactionType.value);
    }
    if (amount.present) {
      map['Amount'] = Variable<double>(amount.value);
    }
    if (interestRate.present) {
      map['Interest_Rate'] = Variable<double>(interestRate.value);
    }
    if (interestAmount.present) {
      map['Interest_Amount'] = Variable<double>(interestAmount.value);
    }
    if (remainingAmount.present) {
      map['Remaining_Amount'] = Variable<double>(remainingAmount.value);
    }
    if (signature.present) {
      map['Signature'] = Variable<String>(signature.value);
    }
    if (createdDate.present) {
      map['Created_Date'] = Variable<DateTime>(createdDate.value);
    }
    if (updatedDate.present) {
      map['Updated_Date'] = Variable<String>(updatedDate.value);
    }
    if (syncId.present) {
      map['Sync_ID'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['Updated_At'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('customerId: $customerId, ')
          ..write('itemId: $itemId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('interestRate: $interestRate, ')
          ..write('interestAmount: $interestAmount, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('signature: $signature, ')
          ..write('createdDate: $createdDate, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<int> paymentId = GeneratedColumn<int>(
    'Payment_ID',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'Transaction_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Transactions (Transaction_ID) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'Payment_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'Amount_Paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'Payment_Type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'Created_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'Sync_ID',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'Updated_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'Deleted_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    paymentId,
    transactionId,
    paymentDate,
    amountPaid,
    paymentType,
    createdDate,
    syncId,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('Payment_ID')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['Payment_ID']!, _paymentIdMeta),
      );
    }
    if (data.containsKey('Transaction_ID')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['Transaction_ID']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('Payment_Date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['Payment_Date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('Amount_Paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['Amount_Paid']!, _amountPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_amountPaidMeta);
    }
    if (data.containsKey('Payment_Type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['Payment_Type']!,
          _paymentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentTypeMeta);
    }
    if (data.containsKey('Created_Date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['Created_Date']!,
          _createdDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdDateMeta);
    }
    if (data.containsKey('Sync_ID')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['Sync_ID']!, _syncIdMeta),
      );
    }
    if (data.containsKey('Updated_At')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['Updated_At']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('Deleted_At')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['Deleted_At']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {paymentId};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Payment_ID'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Transaction_ID'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Payment_Date'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}Amount_Paid'],
      )!,
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Payment_Type'],
      )!,
      createdDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Created_Date'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Sync_ID'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Updated_At'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Deleted_At'],
      ),
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final int paymentId;
  final int transactionId;
  final DateTime paymentDate;
  final double amountPaid;
  final String paymentType;
  final DateTime createdDate;
  final String syncId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const PaymentRow({
    required this.paymentId,
    required this.transactionId,
    required this.paymentDate,
    required this.amountPaid,
    required this.paymentType,
    required this.createdDate,
    required this.syncId,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['Payment_ID'] = Variable<int>(paymentId);
    map['Transaction_ID'] = Variable<int>(transactionId);
    map['Payment_Date'] = Variable<DateTime>(paymentDate);
    map['Amount_Paid'] = Variable<double>(amountPaid);
    map['Payment_Type'] = Variable<String>(paymentType);
    map['Created_Date'] = Variable<DateTime>(createdDate);
    map['Sync_ID'] = Variable<String>(syncId);
    if (!nullToAbsent || updatedAt != null) {
      map['Updated_At'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      paymentId: Value(paymentId),
      transactionId: Value(transactionId),
      paymentDate: Value(paymentDate),
      amountPaid: Value(amountPaid),
      paymentType: Value(paymentType),
      createdDate: Value(createdDate),
      syncId: Value(syncId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      paymentId: serializer.fromJson<int>(json['paymentId']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'paymentId': serializer.toJson<int>(paymentId),
      'transactionId': serializer.toJson<int>(transactionId),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'paymentType': serializer.toJson<String>(paymentType),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PaymentRow copyWith({
    int? paymentId,
    int? transactionId,
    DateTime? paymentDate,
    double? amountPaid,
    String? paymentType,
    DateTime? createdDate,
    String? syncId,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PaymentRow(
    paymentId: paymentId ?? this.paymentId,
    transactionId: transactionId ?? this.transactionId,
    paymentDate: paymentDate ?? this.paymentDate,
    amountPaid: amountPaid ?? this.amountPaid,
    paymentType: paymentType ?? this.paymentType,
    createdDate: createdDate ?? this.createdDate,
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PaymentRow copyWithCompanion(PaymentsTableCompanion data) {
    return PaymentRow(
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('paymentId: $paymentId, ')
          ..write('transactionId: $transactionId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paymentType: $paymentType, ')
          ..write('createdDate: $createdDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    paymentId,
    transactionId,
    paymentDate,
    amountPaid,
    paymentType,
    createdDate,
    syncId,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.paymentId == this.paymentId &&
          other.transactionId == this.transactionId &&
          other.paymentDate == this.paymentDate &&
          other.amountPaid == this.amountPaid &&
          other.paymentType == this.paymentType &&
          other.createdDate == this.createdDate &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentRow> {
  final Value<int> paymentId;
  final Value<int> transactionId;
  final Value<DateTime> paymentDate;
  final Value<double> amountPaid;
  final Value<String> paymentType;
  final Value<DateTime> createdDate;
  final Value<String> syncId;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const PaymentsTableCompanion({
    this.paymentId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    this.paymentId = const Value.absent(),
    required int transactionId,
    required DateTime paymentDate,
    required double amountPaid,
    required String paymentType,
    required DateTime createdDate,
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : transactionId = Value(transactionId),
       paymentDate = Value(paymentDate),
       amountPaid = Value(amountPaid),
       paymentType = Value(paymentType),
       createdDate = Value(createdDate);
  static Insertable<PaymentRow> custom({
    Expression<int>? paymentId,
    Expression<int>? transactionId,
    Expression<DateTime>? paymentDate,
    Expression<double>? amountPaid,
    Expression<String>? paymentType,
    Expression<DateTime>? createdDate,
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (paymentId != null) 'Payment_ID': paymentId,
      if (transactionId != null) 'Transaction_ID': transactionId,
      if (paymentDate != null) 'Payment_Date': paymentDate,
      if (amountPaid != null) 'Amount_Paid': amountPaid,
      if (paymentType != null) 'Payment_Type': paymentType,
      if (createdDate != null) 'Created_Date': createdDate,
      if (syncId != null) 'Sync_ID': syncId,
      if (updatedAt != null) 'Updated_At': updatedAt,
      if (deletedAt != null) 'Deleted_At': deletedAt,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<int>? paymentId,
    Value<int>? transactionId,
    Value<DateTime>? paymentDate,
    Value<double>? amountPaid,
    Value<String>? paymentType,
    Value<DateTime>? createdDate,
    Value<String>? syncId,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return PaymentsTableCompanion(
      paymentId: paymentId ?? this.paymentId,
      transactionId: transactionId ?? this.transactionId,
      paymentDate: paymentDate ?? this.paymentDate,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentType: paymentType ?? this.paymentType,
      createdDate: createdDate ?? this.createdDate,
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (paymentId.present) {
      map['Payment_ID'] = Variable<int>(paymentId.value);
    }
    if (transactionId.present) {
      map['Transaction_ID'] = Variable<int>(transactionId.value);
    }
    if (paymentDate.present) {
      map['Payment_Date'] = Variable<DateTime>(paymentDate.value);
    }
    if (amountPaid.present) {
      map['Amount_Paid'] = Variable<double>(amountPaid.value);
    }
    if (paymentType.present) {
      map['Payment_Type'] = Variable<String>(paymentType.value);
    }
    if (createdDate.present) {
      map['Created_Date'] = Variable<DateTime>(createdDate.value);
    }
    if (syncId.present) {
      map['Sync_ID'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['Updated_At'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('paymentId: $paymentId, ')
          ..write('transactionId: $transactionId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paymentType: $paymentType, ')
          ..write('createdDate: $createdDate, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $HistoryTableTable extends HistoryTable
    with TableInfo<$HistoryTableTable, HistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _historyIdMeta = const VerificationMeta(
    'historyId',
  );
  @override
  late final GeneratedColumn<int> historyId = GeneratedColumn<int>(
    'History_ID',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'User_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'Customer_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Customers (Customer_ID) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'Customer_Name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNumberMeta = const VerificationMeta(
    'contactNumber',
  );
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
    'Contact_Number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'Item_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'Transaction_ID',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'Amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'Event_Date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'Event_Type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'Sync_ID',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'Updated_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'Deleted_At',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    historyId,
    userId,
    customerId,
    customerName,
    contactNumber,
    itemId,
    transactionId,
    amount,
    eventDate,
    eventType,
    syncId,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'History';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('History_ID')) {
      context.handle(
        _historyIdMeta,
        historyId.isAcceptableOrUnknown(data['History_ID']!, _historyIdMeta),
      );
    }
    if (data.containsKey('User_ID')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['User_ID']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('Customer_ID')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['Customer_ID']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('Customer_Name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['Customer_Name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('Contact_Number')) {
      context.handle(
        _contactNumberMeta,
        contactNumber.isAcceptableOrUnknown(
          data['Contact_Number']!,
          _contactNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactNumberMeta);
    }
    if (data.containsKey('Item_ID')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['Item_ID']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('Transaction_ID')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['Transaction_ID']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('Amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['Amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('Event_Date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['Event_Date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('Event_Type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['Event_Type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('Sync_ID')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['Sync_ID']!, _syncIdMeta),
      );
    }
    if (data.containsKey('Updated_At')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['Updated_At']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('Deleted_At')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['Deleted_At']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {historyId};
  @override
  HistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryRow(
      historyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}History_ID'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}User_ID'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Customer_ID'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Customer_Name'],
      )!,
      contactNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Contact_Number'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Item_ID'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Transaction_ID'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}Amount'],
      )!,
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Event_Date'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Event_Type'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Sync_ID'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Updated_At'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Deleted_At'],
      ),
    );
  }

  @override
  $HistoryTableTable createAlias(String alias) {
    return $HistoryTableTable(attachedDatabase, alias);
  }
}

class HistoryRow extends DataClass implements Insertable<HistoryRow> {
  final int historyId;
  final int userId;
  final int customerId;
  final String customerName;
  final String contactNumber;
  final int itemId;
  final int transactionId;
  final double amount;
  final DateTime eventDate;
  final String eventType;
  final String syncId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const HistoryRow({
    required this.historyId,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.contactNumber,
    required this.itemId,
    required this.transactionId,
    required this.amount,
    required this.eventDate,
    required this.eventType,
    required this.syncId,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['History_ID'] = Variable<int>(historyId);
    map['User_ID'] = Variable<int>(userId);
    map['Customer_ID'] = Variable<int>(customerId);
    map['Customer_Name'] = Variable<String>(customerName);
    map['Contact_Number'] = Variable<String>(contactNumber);
    map['Item_ID'] = Variable<int>(itemId);
    map['Transaction_ID'] = Variable<int>(transactionId);
    map['Amount'] = Variable<double>(amount);
    map['Event_Date'] = Variable<DateTime>(eventDate);
    map['Event_Type'] = Variable<String>(eventType);
    map['Sync_ID'] = Variable<String>(syncId);
    if (!nullToAbsent || updatedAt != null) {
      map['Updated_At'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  HistoryTableCompanion toCompanion(bool nullToAbsent) {
    return HistoryTableCompanion(
      historyId: Value(historyId),
      userId: Value(userId),
      customerId: Value(customerId),
      customerName: Value(customerName),
      contactNumber: Value(contactNumber),
      itemId: Value(itemId),
      transactionId: Value(transactionId),
      amount: Value(amount),
      eventDate: Value(eventDate),
      eventType: Value(eventType),
      syncId: Value(syncId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory HistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryRow(
      historyId: serializer.fromJson<int>(json['historyId']),
      userId: serializer.fromJson<int>(json['userId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      contactNumber: serializer.fromJson<String>(json['contactNumber']),
      itemId: serializer.fromJson<int>(json['itemId']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      amount: serializer.fromJson<double>(json['amount']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      eventType: serializer.fromJson<String>(json['eventType']),
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'historyId': serializer.toJson<int>(historyId),
      'userId': serializer.toJson<int>(userId),
      'customerId': serializer.toJson<int>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'contactNumber': serializer.toJson<String>(contactNumber),
      'itemId': serializer.toJson<int>(itemId),
      'transactionId': serializer.toJson<int>(transactionId),
      'amount': serializer.toJson<double>(amount),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'eventType': serializer.toJson<String>(eventType),
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  HistoryRow copyWith({
    int? historyId,
    int? userId,
    int? customerId,
    String? customerName,
    String? contactNumber,
    int? itemId,
    int? transactionId,
    double? amount,
    DateTime? eventDate,
    String? eventType,
    String? syncId,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => HistoryRow(
    historyId: historyId ?? this.historyId,
    userId: userId ?? this.userId,
    customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    contactNumber: contactNumber ?? this.contactNumber,
    itemId: itemId ?? this.itemId,
    transactionId: transactionId ?? this.transactionId,
    amount: amount ?? this.amount,
    eventDate: eventDate ?? this.eventDate,
    eventType: eventType ?? this.eventType,
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  HistoryRow copyWithCompanion(HistoryTableCompanion data) {
    return HistoryRow(
      historyId: data.historyId.present ? data.historyId.value : this.historyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      amount: data.amount.present ? data.amount.value : this.amount,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryRow(')
          ..write('historyId: $historyId, ')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('itemId: $itemId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amount: $amount, ')
          ..write('eventDate: $eventDate, ')
          ..write('eventType: $eventType, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    historyId,
    userId,
    customerId,
    customerName,
    contactNumber,
    itemId,
    transactionId,
    amount,
    eventDate,
    eventType,
    syncId,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryRow &&
          other.historyId == this.historyId &&
          other.userId == this.userId &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.contactNumber == this.contactNumber &&
          other.itemId == this.itemId &&
          other.transactionId == this.transactionId &&
          other.amount == this.amount &&
          other.eventDate == this.eventDate &&
          other.eventType == this.eventType &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class HistoryTableCompanion extends UpdateCompanion<HistoryRow> {
  final Value<int> historyId;
  final Value<int> userId;
  final Value<int> customerId;
  final Value<String> customerName;
  final Value<String> contactNumber;
  final Value<int> itemId;
  final Value<int> transactionId;
  final Value<double> amount;
  final Value<DateTime> eventDate;
  final Value<String> eventType;
  final Value<String> syncId;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const HistoryTableCompanion({
    this.historyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.itemId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.amount = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.eventType = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  HistoryTableCompanion.insert({
    this.historyId = const Value.absent(),
    required int userId,
    required int customerId,
    required String customerName,
    required String contactNumber,
    required int itemId,
    required int transactionId,
    required double amount,
    required DateTime eventDate,
    required String eventType,
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : userId = Value(userId),
       customerId = Value(customerId),
       customerName = Value(customerName),
       contactNumber = Value(contactNumber),
       itemId = Value(itemId),
       transactionId = Value(transactionId),
       amount = Value(amount),
       eventDate = Value(eventDate),
       eventType = Value(eventType);
  static Insertable<HistoryRow> custom({
    Expression<int>? historyId,
    Expression<int>? userId,
    Expression<int>? customerId,
    Expression<String>? customerName,
    Expression<String>? contactNumber,
    Expression<int>? itemId,
    Expression<int>? transactionId,
    Expression<double>? amount,
    Expression<DateTime>? eventDate,
    Expression<String>? eventType,
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (historyId != null) 'History_ID': historyId,
      if (userId != null) 'User_ID': userId,
      if (customerId != null) 'Customer_ID': customerId,
      if (customerName != null) 'Customer_Name': customerName,
      if (contactNumber != null) 'Contact_Number': contactNumber,
      if (itemId != null) 'Item_ID': itemId,
      if (transactionId != null) 'Transaction_ID': transactionId,
      if (amount != null) 'Amount': amount,
      if (eventDate != null) 'Event_Date': eventDate,
      if (eventType != null) 'Event_Type': eventType,
      if (syncId != null) 'Sync_ID': syncId,
      if (updatedAt != null) 'Updated_At': updatedAt,
      if (deletedAt != null) 'Deleted_At': deletedAt,
    });
  }

  HistoryTableCompanion copyWith({
    Value<int>? historyId,
    Value<int>? userId,
    Value<int>? customerId,
    Value<String>? customerName,
    Value<String>? contactNumber,
    Value<int>? itemId,
    Value<int>? transactionId,
    Value<double>? amount,
    Value<DateTime>? eventDate,
    Value<String>? eventType,
    Value<String>? syncId,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return HistoryTableCompanion(
      historyId: historyId ?? this.historyId,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      contactNumber: contactNumber ?? this.contactNumber,
      itemId: itemId ?? this.itemId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      eventDate: eventDate ?? this.eventDate,
      eventType: eventType ?? this.eventType,
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (historyId.present) {
      map['History_ID'] = Variable<int>(historyId.value);
    }
    if (userId.present) {
      map['User_ID'] = Variable<int>(userId.value);
    }
    if (customerId.present) {
      map['Customer_ID'] = Variable<int>(customerId.value);
    }
    if (customerName.present) {
      map['Customer_Name'] = Variable<String>(customerName.value);
    }
    if (contactNumber.present) {
      map['Contact_Number'] = Variable<String>(contactNumber.value);
    }
    if (itemId.present) {
      map['Item_ID'] = Variable<int>(itemId.value);
    }
    if (transactionId.present) {
      map['Transaction_ID'] = Variable<int>(transactionId.value);
    }
    if (amount.present) {
      map['Amount'] = Variable<double>(amount.value);
    }
    if (eventDate.present) {
      map['Event_Date'] = Variable<DateTime>(eventDate.value);
    }
    if (eventType.present) {
      map['Event_Type'] = Variable<String>(eventType.value);
    }
    if (syncId.present) {
      map['Sync_ID'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['Updated_At'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['Deleted_At'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableCompanion(')
          ..write('historyId: $historyId, ')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('itemId: $itemId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amount: $amount, ')
          ..write('eventDate: $eventDate, ')
          ..write('eventType: $eventType, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTableTable extends SyncOutboxTable
    with TableInfo<$SyncOutboxTableTable, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outboxIdMeta = const VerificationMeta(
    'outboxId',
  );
  @override
  late final GeneratedColumn<int> outboxId = GeneratedColumn<int>(
    'Outbox_ID',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'Entity_Type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entitySyncIdMeta = const VerificationMeta(
    'entitySyncId',
  );
  @override
  late final GeneratedColumn<String> entitySyncId = GeneratedColumn<String>(
    'Entity_Sync_ID',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'Operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'Created_At',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'Retry_Count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'Last_Error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    outboxId,
    entityType,
    entitySyncId,
    operation,
    createdAt,
    retryCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Sync_Outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('Outbox_ID')) {
      context.handle(
        _outboxIdMeta,
        outboxId.isAcceptableOrUnknown(data['Outbox_ID']!, _outboxIdMeta),
      );
    }
    if (data.containsKey('Entity_Type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['Entity_Type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('Entity_Sync_ID')) {
      context.handle(
        _entitySyncIdMeta,
        entitySyncId.isAcceptableOrUnknown(
          data['Entity_Sync_ID']!,
          _entitySyncIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitySyncIdMeta);
    }
    if (data.containsKey('Operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['Operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('Created_At')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['Created_At']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('Retry_Count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['Retry_Count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('Last_Error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['Last_Error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outboxId};
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      outboxId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Outbox_ID'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Entity_Type'],
      )!,
      entitySyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Entity_Sync_ID'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Operation'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}Created_At'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Retry_Count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}Last_Error'],
      ),
    );
  }

  @override
  $SyncOutboxTableTable createAlias(String alias) {
    return $SyncOutboxTableTable(attachedDatabase, alias);
  }
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  final int outboxId;
  final String entityType;
  final String entitySyncId;
  final String operation;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  const SyncOutboxRow({
    required this.outboxId,
    required this.entityType,
    required this.entitySyncId,
    required this.operation,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['Outbox_ID'] = Variable<int>(outboxId);
    map['Entity_Type'] = Variable<String>(entityType);
    map['Entity_Sync_ID'] = Variable<String>(entitySyncId);
    map['Operation'] = Variable<String>(operation);
    map['Created_At'] = Variable<DateTime>(createdAt);
    map['Retry_Count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['Last_Error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxTableCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxTableCompanion(
      outboxId: Value(outboxId),
      entityType: Value(entityType),
      entitySyncId: Value(entitySyncId),
      operation: Value(operation),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      outboxId: serializer.fromJson<int>(json['outboxId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entitySyncId: serializer.fromJson<String>(json['entitySyncId']),
      operation: serializer.fromJson<String>(json['operation']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outboxId': serializer.toJson<int>(outboxId),
      'entityType': serializer.toJson<String>(entityType),
      'entitySyncId': serializer.toJson<String>(entitySyncId),
      'operation': serializer.toJson<String>(operation),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxRow copyWith({
    int? outboxId,
    String? entityType,
    String? entitySyncId,
    String? operation,
    DateTime? createdAt,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxRow(
    outboxId: outboxId ?? this.outboxId,
    entityType: entityType ?? this.entityType,
    entitySyncId: entitySyncId ?? this.entitySyncId,
    operation: operation ?? this.operation,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxRow copyWithCompanion(SyncOutboxTableCompanion data) {
    return SyncOutboxRow(
      outboxId: data.outboxId.present ? data.outboxId.value : this.outboxId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entitySyncId: data.entitySyncId.present
          ? data.entitySyncId.value
          : this.entitySyncId,
      operation: data.operation.present ? data.operation.value : this.operation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('outboxId: $outboxId, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('operation: $operation, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    outboxId,
    entityType,
    entitySyncId,
    operation,
    createdAt,
    retryCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.outboxId == this.outboxId &&
          other.entityType == this.entityType &&
          other.entitySyncId == this.entitySyncId &&
          other.operation == this.operation &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncOutboxTableCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<int> outboxId;
  final Value<String> entityType;
  final Value<String> entitySyncId;
  final Value<String> operation;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const SyncOutboxTableCompanion({
    this.outboxId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entitySyncId = const Value.absent(),
    this.operation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncOutboxTableCompanion.insert({
    this.outboxId = const Value.absent(),
    required String entityType,
    required String entitySyncId,
    required String operation,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : entityType = Value(entityType),
       entitySyncId = Value(entitySyncId),
       operation = Value(operation),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxRow> custom({
    Expression<int>? outboxId,
    Expression<String>? entityType,
    Expression<String>? entitySyncId,
    Expression<String>? operation,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (outboxId != null) 'Outbox_ID': outboxId,
      if (entityType != null) 'Entity_Type': entityType,
      if (entitySyncId != null) 'Entity_Sync_ID': entitySyncId,
      if (operation != null) 'Operation': operation,
      if (createdAt != null) 'Created_At': createdAt,
      if (retryCount != null) 'Retry_Count': retryCount,
      if (lastError != null) 'Last_Error': lastError,
    });
  }

  SyncOutboxTableCompanion copyWith({
    Value<int>? outboxId,
    Value<String>? entityType,
    Value<String>? entitySyncId,
    Value<String>? operation,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<String?>? lastError,
  }) {
    return SyncOutboxTableCompanion(
      outboxId: outboxId ?? this.outboxId,
      entityType: entityType ?? this.entityType,
      entitySyncId: entitySyncId ?? this.entitySyncId,
      operation: operation ?? this.operation,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outboxId.present) {
      map['Outbox_ID'] = Variable<int>(outboxId.value);
    }
    if (entityType.present) {
      map['Entity_Type'] = Variable<String>(entityType.value);
    }
    if (entitySyncId.present) {
      map['Entity_Sync_ID'] = Variable<String>(entitySyncId.value);
    }
    if (operation.present) {
      map['Operation'] = Variable<String>(operation.value);
    }
    if (createdAt.present) {
      map['Created_At'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['Retry_Count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['Last_Error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxTableCompanion(')
          ..write('outboxId: $outboxId, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('operation: $operation, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$ItDataDatabase extends GeneratedDatabase {
  _$ItDataDatabase(QueryExecutor e) : super(e);
  $ItDataDatabaseManager get managers => $ItDataDatabaseManager(this);
  late final $CustomersTableTable customersTable = $CustomersTableTable(this);
  late final $ItemsTableTable itemsTable = $ItemsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $HistoryTableTable historyTable = $HistoryTableTable(this);
  late final $SyncOutboxTableTable syncOutboxTable = $SyncOutboxTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customersTable,
    itemsTable,
    transactionsTable,
    paymentsTable,
    historyTable,
    syncOutboxTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'Customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('Items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'Customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('Transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'Items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('Transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'Transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('Payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'Customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('History', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CustomersTableTableCreateCompanionBuilder =
    CustomersTableCompanion Function({
      required int userId,
      Value<int> customerId,
      required String customerName,
      required String gaurdianName,
      required String customerAddress,
      required String contactNumber,
      required String customerPhoto,
      required String proofPhoto,
      required DateTime createdDate,
      Value<String?> updatedDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$CustomersTableTableUpdateCompanionBuilder =
    CustomersTableCompanion Function({
      Value<int> userId,
      Value<int> customerId,
      Value<String> customerName,
      Value<String> gaurdianName,
      Value<String> customerAddress,
      Value<String> contactNumber,
      Value<String> customerPhoto,
      Value<String> proofPhoto,
      Value<DateTime> createdDate,
      Value<String?> updatedDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$CustomersTableTableReferences
    extends
        BaseReferences<_$ItDataDatabase, $CustomersTableTable, CustomerRow> {
  $$CustomersTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ItemsTableTable, List<ItemRow>>
  _itemsTableRefsTable(_$ItDataDatabase db) => MultiTypedResultKey.fromTable(
    db.itemsTable,
    aliasName: $_aliasNameGenerator(
      db.customersTable.customerId,
      db.itemsTable.customerId,
    ),
  );

  $$ItemsTableTableProcessedTableManager get itemsTableRefs {
    final manager = $$ItemsTableTableTableManager($_db, $_db.itemsTable).filter(
      (f) =>
          f.customerId.customerId.sqlEquals($_itemColumn<int>('Customer_ID')!),
    );

    final cache = $_typedResult.readTableOrNull(_itemsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTableTable, List<TransactionRow>>
  _transactionsTableRefsTable(_$ItDataDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionsTable,
        aliasName: $_aliasNameGenerator(
          db.customersTable.customerId,
          db.transactionsTable.customerId,
        ),
      );

  $$TransactionsTableTableProcessedTableManager get transactionsTableRefs {
    final manager =
        $$TransactionsTableTableTableManager(
          $_db,
          $_db.transactionsTable,
        ).filter(
          (f) => f.customerId.customerId.sqlEquals(
            $_itemColumn<int>('Customer_ID')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _transactionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HistoryTableTable, List<HistoryRow>>
  _historyTableRefsTable(_$ItDataDatabase db) => MultiTypedResultKey.fromTable(
    db.historyTable,
    aliasName: $_aliasNameGenerator(
      db.customersTable.customerId,
      db.historyTable.customerId,
    ),
  );

  $$HistoryTableTableProcessedTableManager get historyTableRefs {
    final manager = $$HistoryTableTableTableManager($_db, $_db.historyTable)
        .filter(
          (f) => f.customerId.customerId.sqlEquals(
            $_itemColumn<int>('Customer_ID')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_historyTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableTableFilterComposer
    extends Composer<_$ItDataDatabase, $CustomersTableTable> {
  $$CustomersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gaurdianName => $composableBuilder(
    column: $table.gaurdianName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerAddress => $composableBuilder(
    column: $table.customerAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhoto => $composableBuilder(
    column: $table.customerPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proofPhoto => $composableBuilder(
    column: $table.proofPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemsTableRefs(
    Expression<bool> Function($$ItemsTableTableFilterComposer f) f,
  ) {
    final $$ItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.itemsTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.itemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsTableRefs(
    Expression<bool> Function($$TransactionsTableTableFilterComposer f) f,
  ) {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.transactionsTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableTableFilterComposer(
            $db: $db,
            $table: $db.transactionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> historyTableRefs(
    Expression<bool> Function($$HistoryTableTableFilterComposer f) f,
  ) {
    final $$HistoryTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.historyTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryTableTableFilterComposer(
            $db: $db,
            $table: $db.historyTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableOrderingComposer
    extends Composer<_$ItDataDatabase, $CustomersTableTable> {
  $$CustomersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gaurdianName => $composableBuilder(
    column: $table.gaurdianName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerAddress => $composableBuilder(
    column: $table.customerAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhoto => $composableBuilder(
    column: $table.customerPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proofPhoto => $composableBuilder(
    column: $table.proofPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableTableAnnotationComposer
    extends Composer<_$ItDataDatabase, $CustomersTableTable> {
  $$CustomersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gaurdianName => $composableBuilder(
    column: $table.gaurdianName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerAddress => $composableBuilder(
    column: $table.customerAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhoto => $composableBuilder(
    column: $table.customerPhoto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proofPhoto => $composableBuilder(
    column: $table.proofPhoto,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> itemsTableRefs<T extends Object>(
    Expression<T> Function($$ItemsTableTableAnnotationComposer a) f,
  ) {
    final $$ItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.itemsTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.itemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsTableRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.customerId,
          referencedTable: $db.transactionsTable,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> historyTableRefs<T extends Object>(
    Expression<T> Function($$HistoryTableTableAnnotationComposer a) f,
  ) {
    final $$HistoryTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.historyTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryTableTableAnnotationComposer(
            $db: $db,
            $table: $db.historyTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableTableManager
    extends
        RootTableManager<
          _$ItDataDatabase,
          $CustomersTableTable,
          CustomerRow,
          $$CustomersTableTableFilterComposer,
          $$CustomersTableTableOrderingComposer,
          $$CustomersTableTableAnnotationComposer,
          $$CustomersTableTableCreateCompanionBuilder,
          $$CustomersTableTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomersTableTableReferences),
          CustomerRow,
          PrefetchHooks Function({
            bool itemsTableRefs,
            bool transactionsTableRefs,
            bool historyTableRefs,
          })
        > {
  $$CustomersTableTableTableManager(
    _$ItDataDatabase db,
    $CustomersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> gaurdianName = const Value.absent(),
                Value<String> customerAddress = const Value.absent(),
                Value<String> contactNumber = const Value.absent(),
                Value<String> customerPhoto = const Value.absent(),
                Value<String> proofPhoto = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<String?> updatedDate = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CustomersTableCompanion(
                userId: userId,
                customerId: customerId,
                customerName: customerName,
                gaurdianName: gaurdianName,
                customerAddress: customerAddress,
                contactNumber: contactNumber,
                customerPhoto: customerPhoto,
                proofPhoto: proofPhoto,
                createdDate: createdDate,
                updatedDate: updatedDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                required int userId,
                Value<int> customerId = const Value.absent(),
                required String customerName,
                required String gaurdianName,
                required String customerAddress,
                required String contactNumber,
                required String customerPhoto,
                required String proofPhoto,
                required DateTime createdDate,
                Value<String?> updatedDate = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CustomersTableCompanion.insert(
                userId: userId,
                customerId: customerId,
                customerName: customerName,
                gaurdianName: gaurdianName,
                customerAddress: customerAddress,
                contactNumber: contactNumber,
                customerPhoto: customerPhoto,
                proofPhoto: proofPhoto,
                createdDate: createdDate,
                updatedDate: updatedDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                itemsTableRefs = false,
                transactionsTableRefs = false,
                historyTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (itemsTableRefs) db.itemsTable,
                    if (transactionsTableRefs) db.transactionsTable,
                    if (historyTableRefs) db.historyTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (itemsTableRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTableTable,
                          ItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableTableReferences
                              ._itemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).itemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.customerId,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsTableRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTableTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableTableReferences
                              ._transactionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.customerId,
                              ),
                          typedResults: items,
                        ),
                      if (historyTableRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTableTable,
                          HistoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableTableReferences
                              ._historyTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).historyTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.customerId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ItDataDatabase,
      $CustomersTableTable,
      CustomerRow,
      $$CustomersTableTableFilterComposer,
      $$CustomersTableTableOrderingComposer,
      $$CustomersTableTableAnnotationComposer,
      $$CustomersTableTableCreateCompanionBuilder,
      $$CustomersTableTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomersTableTableReferences),
      CustomerRow,
      PrefetchHooks Function({
        bool itemsTableRefs,
        bool transactionsTableRefs,
        bool historyTableRefs,
      })
    >;
typedef $$ItemsTableTableCreateCompanionBuilder =
    ItemsTableCompanion Function({
      Value<int> itemId,
      required int customerId,
      required String itemName,
      required String itemDescription,
      required DateTime pawnedDate,
      required DateTime expiryDate,
      required double pawnAmount,
      required String itemStatus,
      required String itemPhoto,
      required DateTime createdDate,
      Value<String?> updatedDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$ItemsTableTableUpdateCompanionBuilder =
    ItemsTableCompanion Function({
      Value<int> itemId,
      Value<int> customerId,
      Value<String> itemName,
      Value<String> itemDescription,
      Value<DateTime> pawnedDate,
      Value<DateTime> expiryDate,
      Value<double> pawnAmount,
      Value<String> itemStatus,
      Value<String> itemPhoto,
      Value<DateTime> createdDate,
      Value<String?> updatedDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$ItemsTableTableReferences
    extends BaseReferences<_$ItDataDatabase, $ItemsTableTable, ItemRow> {
  $$ItemsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTableTable _customerIdTable(_$ItDataDatabase db) =>
      db.customersTable.createAlias(
        $_aliasNameGenerator(
          db.itemsTable.customerId,
          db.customersTable.customerId,
        ),
      );

  $$CustomersTableTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('Customer_ID')!;

    final manager = $$CustomersTableTableTableManager(
      $_db,
      $_db.customersTable,
    ).filter((f) => f.customerId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTableTable, List<TransactionRow>>
  _transactionsTableRefsTable(_$ItDataDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionsTable,
        aliasName: $_aliasNameGenerator(
          db.itemsTable.itemId,
          db.transactionsTable.itemId,
        ),
      );

  $$TransactionsTableTableProcessedTableManager get transactionsTableRefs {
    final manager = $$TransactionsTableTableTableManager(
      $_db,
      $_db.transactionsTable,
    ).filter((f) => f.itemId.itemId.sqlEquals($_itemColumn<int>('Item_ID')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableTableFilterComposer
    extends Composer<_$ItDataDatabase, $ItemsTableTable> {
  $$ItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pawnedDate => $composableBuilder(
    column: $table.pawnedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pawnAmount => $composableBuilder(
    column: $table.pawnAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemStatus => $composableBuilder(
    column: $table.itemStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemPhoto => $composableBuilder(
    column: $table.itemPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableTableFilterComposer get customerId {
    final $$CustomersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableFilterComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsTableRefs(
    Expression<bool> Function($$TransactionsTableTableFilterComposer f) f,
  ) {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.transactionsTable,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableTableFilterComposer(
            $db: $db,
            $table: $db.transactionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableOrderingComposer
    extends Composer<_$ItDataDatabase, $ItemsTableTable> {
  $$ItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pawnedDate => $composableBuilder(
    column: $table.pawnedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pawnAmount => $composableBuilder(
    column: $table.pawnAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemStatus => $composableBuilder(
    column: $table.itemStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemPhoto => $composableBuilder(
    column: $table.itemPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableTableOrderingComposer get customerId {
    final $$CustomersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableOrderingComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableTableAnnotationComposer
    extends Composer<_$ItDataDatabase, $ItemsTableTable> {
  $$ItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pawnedDate => $composableBuilder(
    column: $table.pawnedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pawnAmount => $composableBuilder(
    column: $table.pawnAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemStatus => $composableBuilder(
    column: $table.itemStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemPhoto =>
      $composableBuilder(column: $table.itemPhoto, builder: (column) => column);

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CustomersTableTableAnnotationComposer get customerId {
    final $$CustomersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsTableRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.itemId,
          referencedTable: $db.transactionsTable,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ItemsTableTableTableManager
    extends
        RootTableManager<
          _$ItDataDatabase,
          $ItemsTableTable,
          ItemRow,
          $$ItemsTableTableFilterComposer,
          $$ItemsTableTableOrderingComposer,
          $$ItemsTableTableAnnotationComposer,
          $$ItemsTableTableCreateCompanionBuilder,
          $$ItemsTableTableUpdateCompanionBuilder,
          (ItemRow, $$ItemsTableTableReferences),
          ItemRow,
          PrefetchHooks Function({bool customerId, bool transactionsTableRefs})
        > {
  $$ItemsTableTableTableManager(_$ItDataDatabase db, $ItemsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> itemId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<String> itemDescription = const Value.absent(),
                Value<DateTime> pawnedDate = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<double> pawnAmount = const Value.absent(),
                Value<String> itemStatus = const Value.absent(),
                Value<String> itemPhoto = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<String?> updatedDate = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ItemsTableCompanion(
                itemId: itemId,
                customerId: customerId,
                itemName: itemName,
                itemDescription: itemDescription,
                pawnedDate: pawnedDate,
                expiryDate: expiryDate,
                pawnAmount: pawnAmount,
                itemStatus: itemStatus,
                itemPhoto: itemPhoto,
                createdDate: createdDate,
                updatedDate: updatedDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> itemId = const Value.absent(),
                required int customerId,
                required String itemName,
                required String itemDescription,
                required DateTime pawnedDate,
                required DateTime expiryDate,
                required double pawnAmount,
                required String itemStatus,
                required String itemPhoto,
                required DateTime createdDate,
                Value<String?> updatedDate = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ItemsTableCompanion.insert(
                itemId: itemId,
                customerId: customerId,
                itemName: itemName,
                itemDescription: itemDescription,
                pawnedDate: pawnedDate,
                expiryDate: expiryDate,
                pawnAmount: pawnAmount,
                itemStatus: itemStatus,
                itemPhoto: itemPhoto,
                createdDate: createdDate,
                updatedDate: updatedDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, transactionsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsTableRefs) db.transactionsTable,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$ItemsTableTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn:
                                        $$ItemsTableTableReferences
                                            ._customerIdTable(db)
                                            .customerId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsTableRefs)
                        await $_getPrefetchedData<
                          ItemRow,
                          $ItemsTableTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableTableReferences
                              ._transactionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.itemId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ItDataDatabase,
      $ItemsTableTable,
      ItemRow,
      $$ItemsTableTableFilterComposer,
      $$ItemsTableTableOrderingComposer,
      $$ItemsTableTableAnnotationComposer,
      $$ItemsTableTableCreateCompanionBuilder,
      $$ItemsTableTableUpdateCompanionBuilder,
      (ItemRow, $$ItemsTableTableReferences),
      ItemRow,
      PrefetchHooks Function({bool customerId, bool transactionsTableRefs})
    >;
typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<int> transactionId,
      required int customerId,
      required int itemId,
      required DateTime transactionDate,
      required String transactionType,
      required double amount,
      required double interestRate,
      required double interestAmount,
      required double remainingAmount,
      required String signature,
      required DateTime createdDate,
      Value<String?> updatedDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<int> transactionId,
      Value<int> customerId,
      Value<int> itemId,
      Value<DateTime> transactionDate,
      Value<String> transactionType,
      Value<double> amount,
      Value<double> interestRate,
      Value<double> interestAmount,
      Value<double> remainingAmount,
      Value<String> signature,
      Value<DateTime> createdDate,
      Value<String?> updatedDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$TransactionsTableTableReferences
    extends
        BaseReferences<
          _$ItDataDatabase,
          $TransactionsTableTable,
          TransactionRow
        > {
  $$TransactionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTableTable _customerIdTable(_$ItDataDatabase db) =>
      db.customersTable.createAlias(
        $_aliasNameGenerator(
          db.transactionsTable.customerId,
          db.customersTable.customerId,
        ),
      );

  $$CustomersTableTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('Customer_ID')!;

    final manager = $$CustomersTableTableTableManager(
      $_db,
      $_db.customersTable,
    ).filter((f) => f.customerId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTableTable _itemIdTable(_$ItDataDatabase db) =>
      db.itemsTable.createAlias(
        $_aliasNameGenerator(db.transactionsTable.itemId, db.itemsTable.itemId),
      );

  $$ItemsTableTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('Item_ID')!;

    final manager = $$ItemsTableTableTableManager(
      $_db,
      $_db.itemsTable,
    ).filter((f) => f.itemId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTableTable, List<PaymentRow>>
  _paymentsTableRefsTable(_$ItDataDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsTable,
    aliasName: $_aliasNameGenerator(
      db.transactionsTable.transactionId,
      db.paymentsTable.transactionId,
    ),
  );

  $$PaymentsTableTableProcessedTableManager get paymentsTableRefs {
    final manager = $$PaymentsTableTableTableManager($_db, $_db.paymentsTable)
        .filter(
          (f) => f.transactionId.transactionId.sqlEquals(
            $_itemColumn<int>('Transaction_ID')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_paymentsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableTableFilterComposer
    extends Composer<_$ItDataDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestAmount => $composableBuilder(
    column: $table.interestAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableTableFilterComposer get customerId {
    final $$CustomersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableFilterComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableTableFilterComposer get itemId {
    final $$ItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.itemsTable,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.itemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsTableRefs(
    Expression<bool> Function($$PaymentsTableTableFilterComposer f) f,
  ) {
    final $$PaymentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableFilterComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$ItDataDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestAmount => $composableBuilder(
    column: $table.interestAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableTableOrderingComposer get customerId {
    final $$CustomersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableOrderingComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableTableOrderingComposer get itemId {
    final $$ItemsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.itemsTable,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableTableOrderingComposer(
            $db: $db,
            $table: $db.itemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$ItDataDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestAmount => $composableBuilder(
    column: $table.interestAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CustomersTableTableAnnotationComposer get customerId {
    final $$CustomersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableTableAnnotationComposer get itemId {
    final $$ItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.itemsTable,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.itemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsTableRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$ItDataDatabase,
          $TransactionsTableTable,
          TransactionRow,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableTableReferences),
          TransactionRow,
          PrefetchHooks Function({
            bool customerId,
            bool itemId,
            bool paymentsTableRefs,
          })
        > {
  $$TransactionsTableTableTableManager(
    _$ItDataDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> transactionId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> interestRate = const Value.absent(),
                Value<double> interestAmount = const Value.absent(),
                Value<double> remainingAmount = const Value.absent(),
                Value<String> signature = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<String?> updatedDate = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TransactionsTableCompanion(
                transactionId: transactionId,
                customerId: customerId,
                itemId: itemId,
                transactionDate: transactionDate,
                transactionType: transactionType,
                amount: amount,
                interestRate: interestRate,
                interestAmount: interestAmount,
                remainingAmount: remainingAmount,
                signature: signature,
                createdDate: createdDate,
                updatedDate: updatedDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> transactionId = const Value.absent(),
                required int customerId,
                required int itemId,
                required DateTime transactionDate,
                required String transactionType,
                required double amount,
                required double interestRate,
                required double interestAmount,
                required double remainingAmount,
                required String signature,
                required DateTime createdDate,
                Value<String?> updatedDate = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TransactionsTableCompanion.insert(
                transactionId: transactionId,
                customerId: customerId,
                itemId: itemId,
                transactionDate: transactionDate,
                transactionType: transactionType,
                amount: amount,
                interestRate: interestRate,
                interestAmount: interestAmount,
                remainingAmount: remainingAmount,
                signature: signature,
                createdDate: createdDate,
                updatedDate: updatedDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                itemId = false,
                paymentsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsTableRefs) db.paymentsTable,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable:
                                        $$TransactionsTableTableReferences
                                            ._customerIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableTableReferences
                                            ._customerIdTable(db)
                                            .customerId,
                                  )
                                  as T;
                        }
                        if (itemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.itemId,
                                    referencedTable:
                                        $$TransactionsTableTableReferences
                                            ._itemIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableTableReferences
                                            ._itemIdTable(db)
                                            .itemId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsTableRefs)
                        await $_getPrefetchedData<
                          TransactionRow,
                          $TransactionsTableTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableTableReferences
                              ._paymentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.transactionId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ItDataDatabase,
      $TransactionsTableTable,
      TransactionRow,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableTableReferences),
      TransactionRow,
      PrefetchHooks Function({
        bool customerId,
        bool itemId,
        bool paymentsTableRefs,
      })
    >;
typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<int> paymentId,
      required int transactionId,
      required DateTime paymentDate,
      required double amountPaid,
      required String paymentType,
      required DateTime createdDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<int> paymentId,
      Value<int> transactionId,
      Value<DateTime> paymentDate,
      Value<double> amountPaid,
      Value<String> paymentType,
      Value<DateTime> createdDate,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$PaymentsTableTableReferences
    extends BaseReferences<_$ItDataDatabase, $PaymentsTableTable, PaymentRow> {
  $$PaymentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTableTable _transactionIdTable(_$ItDataDatabase db) =>
      db.transactionsTable.createAlias(
        $_aliasNameGenerator(
          db.paymentsTable.transactionId,
          db.transactionsTable.transactionId,
        ),
      );

  $$TransactionsTableTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('Transaction_ID')!;

    final manager = $$TransactionsTableTableTableManager(
      $_db,
      $_db.transactionsTable,
    ).filter((f) => f.transactionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableTableFilterComposer
    extends Composer<_$ItDataDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableTableFilterComposer get transactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactionsTable,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableTableFilterComposer(
            $db: $db,
            $table: $db.transactionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$ItDataDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableTableOrderingComposer get transactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactionsTable,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableTableOrderingComposer(
            $db: $db,
            $table: $db.transactionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$ItDataDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TransactionsTableTableAnnotationComposer get transactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.transactionId,
          referencedTable: $db.transactionsTable,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$ItDataDatabase,
          $PaymentsTableTable,
          PaymentRow,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool transactionId})
        > {
  $$PaymentsTableTableTableManager(
    _$ItDataDatabase db,
    $PaymentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> paymentId = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => PaymentsTableCompanion(
                paymentId: paymentId,
                transactionId: transactionId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                paymentType: paymentType,
                createdDate: createdDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> paymentId = const Value.absent(),
                required int transactionId,
                required DateTime paymentDate,
                required double amountPaid,
                required String paymentType,
                required DateTime createdDate,
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                paymentId: paymentId,
                transactionId: transactionId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                paymentType: paymentType,
                createdDate: createdDate,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable: $$PaymentsTableTableReferences
                                    ._transactionIdTable(db),
                                referencedColumn: $$PaymentsTableTableReferences
                                    ._transactionIdTable(db)
                                    .transactionId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ItDataDatabase,
      $PaymentsTableTable,
      PaymentRow,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$HistoryTableTableCreateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<int> historyId,
      required int userId,
      required int customerId,
      required String customerName,
      required String contactNumber,
      required int itemId,
      required int transactionId,
      required double amount,
      required DateTime eventDate,
      required String eventType,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$HistoryTableTableUpdateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<int> historyId,
      Value<int> userId,
      Value<int> customerId,
      Value<String> customerName,
      Value<String> contactNumber,
      Value<int> itemId,
      Value<int> transactionId,
      Value<double> amount,
      Value<DateTime> eventDate,
      Value<String> eventType,
      Value<String> syncId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$HistoryTableTableReferences
    extends BaseReferences<_$ItDataDatabase, $HistoryTableTable, HistoryRow> {
  $$HistoryTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTableTable _customerIdTable(_$ItDataDatabase db) =>
      db.customersTable.createAlias(
        $_aliasNameGenerator(
          db.historyTable.customerId,
          db.customersTable.customerId,
        ),
      );

  $$CustomersTableTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('Customer_ID')!;

    final manager = $$CustomersTableTableTableManager(
      $_db,
      $_db.customersTable,
    ).filter((f) => f.customerId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistoryTableTableFilterComposer
    extends Composer<_$ItDataDatabase, $HistoryTableTable> {
  $$HistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get historyId => $composableBuilder(
    column: $table.historyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableTableFilterComposer get customerId {
    final $$CustomersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableFilterComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryTableTableOrderingComposer
    extends Composer<_$ItDataDatabase, $HistoryTableTable> {
  $$HistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get historyId => $composableBuilder(
    column: $table.historyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableTableOrderingComposer get customerId {
    final $$CustomersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableOrderingComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryTableTableAnnotationComposer
    extends Composer<_$ItDataDatabase, $HistoryTableTable> {
  $$HistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get historyId =>
      $composableBuilder(column: $table.historyId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CustomersTableTableAnnotationComposer get customerId {
    final $$CustomersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryTableTableTableManager
    extends
        RootTableManager<
          _$ItDataDatabase,
          $HistoryTableTable,
          HistoryRow,
          $$HistoryTableTableFilterComposer,
          $$HistoryTableTableOrderingComposer,
          $$HistoryTableTableAnnotationComposer,
          $$HistoryTableTableCreateCompanionBuilder,
          $$HistoryTableTableUpdateCompanionBuilder,
          (HistoryRow, $$HistoryTableTableReferences),
          HistoryRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$HistoryTableTableTableManager(_$ItDataDatabase db, $HistoryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> historyId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> contactNumber = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => HistoryTableCompanion(
                historyId: historyId,
                userId: userId,
                customerId: customerId,
                customerName: customerName,
                contactNumber: contactNumber,
                itemId: itemId,
                transactionId: transactionId,
                amount: amount,
                eventDate: eventDate,
                eventType: eventType,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> historyId = const Value.absent(),
                required int userId,
                required int customerId,
                required String customerName,
                required String contactNumber,
                required int itemId,
                required int transactionId,
                required double amount,
                required DateTime eventDate,
                required String eventType,
                Value<String> syncId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => HistoryTableCompanion.insert(
                historyId: historyId,
                userId: userId,
                customerId: customerId,
                customerName: customerName,
                contactNumber: contactNumber,
                itemId: itemId,
                transactionId: transactionId,
                amount: amount,
                eventDate: eventDate,
                eventType: eventType,
                syncId: syncId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HistoryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$HistoryTableTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$HistoryTableTableReferences
                                    ._customerIdTable(db)
                                    .customerId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ItDataDatabase,
      $HistoryTableTable,
      HistoryRow,
      $$HistoryTableTableFilterComposer,
      $$HistoryTableTableOrderingComposer,
      $$HistoryTableTableAnnotationComposer,
      $$HistoryTableTableCreateCompanionBuilder,
      $$HistoryTableTableUpdateCompanionBuilder,
      (HistoryRow, $$HistoryTableTableReferences),
      HistoryRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$SyncOutboxTableTableCreateCompanionBuilder =
    SyncOutboxTableCompanion Function({
      Value<int> outboxId,
      required String entityType,
      required String entitySyncId,
      required String operation,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
    });
typedef $$SyncOutboxTableTableUpdateCompanionBuilder =
    SyncOutboxTableCompanion Function({
      Value<int> outboxId,
      Value<String> entityType,
      Value<String> entitySyncId,
      Value<String> operation,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
    });

class $$SyncOutboxTableTableFilterComposer
    extends Composer<_$ItDataDatabase, $SyncOutboxTableTable> {
  $$SyncOutboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get outboxId => $composableBuilder(
    column: $table.outboxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableTableOrderingComposer
    extends Composer<_$ItDataDatabase, $SyncOutboxTableTable> {
  $$SyncOutboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get outboxId => $composableBuilder(
    column: $table.outboxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableTableAnnotationComposer
    extends Composer<_$ItDataDatabase, $SyncOutboxTableTable> {
  $$SyncOutboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get outboxId =>
      $composableBuilder(column: $table.outboxId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableTableManager
    extends
        RootTableManager<
          _$ItDataDatabase,
          $SyncOutboxTableTable,
          SyncOutboxRow,
          $$SyncOutboxTableTableFilterComposer,
          $$SyncOutboxTableTableOrderingComposer,
          $$SyncOutboxTableTableAnnotationComposer,
          $$SyncOutboxTableTableCreateCompanionBuilder,
          $$SyncOutboxTableTableUpdateCompanionBuilder,
          (
            SyncOutboxRow,
            BaseReferences<
              _$ItDataDatabase,
              $SyncOutboxTableTable,
              SyncOutboxRow
            >,
          ),
          SyncOutboxRow,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableTableManager(
    _$ItDataDatabase db,
    $SyncOutboxTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> outboxId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entitySyncId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncOutboxTableCompanion(
                outboxId: outboxId,
                entityType: entityType,
                entitySyncId: entitySyncId,
                operation: operation,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> outboxId = const Value.absent(),
                required String entityType,
                required String entitySyncId,
                required String operation,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncOutboxTableCompanion.insert(
                outboxId: outboxId,
                entityType: entityType,
                entitySyncId: entitySyncId,
                operation: operation,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ItDataDatabase,
      $SyncOutboxTableTable,
      SyncOutboxRow,
      $$SyncOutboxTableTableFilterComposer,
      $$SyncOutboxTableTableOrderingComposer,
      $$SyncOutboxTableTableAnnotationComposer,
      $$SyncOutboxTableTableCreateCompanionBuilder,
      $$SyncOutboxTableTableUpdateCompanionBuilder,
      (
        SyncOutboxRow,
        BaseReferences<_$ItDataDatabase, $SyncOutboxTableTable, SyncOutboxRow>,
      ),
      SyncOutboxRow,
      PrefetchHooks Function()
    >;

class $ItDataDatabaseManager {
  final _$ItDataDatabase _db;
  $ItDataDatabaseManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(_db, _db.customersTable);
  $$ItemsTableTableTableManager get itemsTable =>
      $$ItemsTableTableTableManager(_db, _db.itemsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db, _db.historyTable);
  $$SyncOutboxTableTableTableManager get syncOutboxTable =>
      $$SyncOutboxTableTableTableManager(_db, _db.syncOutboxTable);
}
