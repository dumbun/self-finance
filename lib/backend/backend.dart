import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/threads/threads.dart';
import 'package:self_finance/models/trx_with_customer_model.dart';

import 'db_paths.dart';

part 'backend.g.dart';

// =============================================================================
// TABLES
// =============================================================================

@DataClassName('CustomerRow')
class CustomersTable extends Table {
  @override
  String get tableName => 'Customers';

  IntColumn get userId => integer().named('User_ID')();

  IntColumn get customerId => integer().named('Customer_ID').autoIncrement()();

  TextColumn get customerName => text().named('Customer_Name')();

  TextColumn get gaurdianName => text().named('Gaurdian_Name')();

  TextColumn get customerAddress => text().named('Customer_Address')();

  TextColumn get contactNumber => text().named('Contact_Number').unique()();

  TextColumn get customerPhoto => text().named('Customer_Photo')();

  TextColumn get proofPhoto => text().named('Proof_Photo')();

  DateTimeColumn get createdDate => dateTime().named('Created_Date')();

  /// keeping as TEXT (your code uses ISO strings)
  TextColumn get updatedDate => text().named('Updated_Date').nullable()();
}

@DataClassName('ItemRow')
class ItemsTable extends Table {
  @override
  String get tableName => 'Items';

  IntColumn get itemId => integer().named('Item_ID').autoIncrement()();

  IntColumn get customerId => integer()
      .named('Customer_ID')
      .references(CustomersTable, #customerId, onDelete: KeyAction.cascade)();

  TextColumn get itemName => text().named('Item_Name')();

  TextColumn get itemDescription => text().named('Item_Description')();

  DateTimeColumn get pawnedDate => dateTime().named('Pawned_Date')();

  DateTimeColumn get expiryDate => dateTime().named('Expiry_Date')();

  RealColumn get pawnAmount => real().named('Pawn_Amount')();

  TextColumn get itemStatus => text().named('Item_Status')();

  TextColumn get itemPhoto => text().named('Item_Photo')();

  DateTimeColumn get createdDate => dateTime().named('Created_Date')();

  /// keeping as TEXT (your code uses ISO strings)
  TextColumn get updatedDate => text().named('Updated_Date').nullable()();
}

@DataClassName('TransactionRow')
class TransactionsTable extends Table {
  @override
  String get tableName => 'Transactions';

  IntColumn get transactionId =>
      integer().named('Transaction_ID').autoIncrement()();

  IntColumn get customerId => integer()
      .named('Customer_ID')
      .references(CustomersTable, #customerId, onDelete: KeyAction.cascade)();

  IntColumn get itemId => integer()
      .named('Item_ID')
      .references(ItemsTable, #itemId, onDelete: KeyAction.cascade)();

  DateTimeColumn get transactionDate => dateTime().named('Transaction_Date')();

  TextColumn get transactionType => text().named('Transaction_Type')();

  RealColumn get amount => real().named('Amount')();

  RealColumn get interestRate => real().named('Interest_Rate')();

  RealColumn get interestAmount => real().named('Interest_Amount')();

  RealColumn get remainingAmount => real().named('Remaining_Amount')();

  TextColumn get signature => text().named('Signature')();

  DateTimeColumn get createdDate => dateTime().named('Created_Date')();

  /// keeping as TEXT (your code uses ISO strings)
  TextColumn get updatedDate => text().named('Updated_Date').nullable()();
}

@DataClassName('PaymentRow')
class PaymentsTable extends Table {
  @override
  String get tableName => 'Payments';

  IntColumn get paymentId => integer().named('Payment_ID').autoIncrement()();

  IntColumn get transactionId => integer()
      .named('Transaction_ID')
      .references(
        TransactionsTable,
        #transactionId,
        onDelete: KeyAction.cascade,
      )();

  DateTimeColumn get paymentDate => dateTime().named('Payment_Date')();

  RealColumn get amountPaid => real().named('Amount_Paid')();

  TextColumn get paymentType => text().named('Payment_Type')();

  DateTimeColumn get createdDate => dateTime().named('Created_Date')();
}

@DataClassName('HistoryRow')
class HistoryTable extends Table {
  @override
  String get tableName => 'History';

  IntColumn get historyId => integer().named('History_ID').autoIncrement()();

  IntColumn get userId => integer().named('User_ID')();

  IntColumn get customerId => integer()
      .named('Customer_ID')
      .references(CustomersTable, #customerId, onDelete: KeyAction.cascade)();

  TextColumn get customerName => text().named('Customer_Name')();

  TextColumn get contactNumber => text().named('Contact_Number')();

  IntColumn get itemId => integer().named('Item_ID')();

  IntColumn get transactionId => integer().named('Transaction_ID')();

  RealColumn get amount => real().named('Amount')();

  DateTimeColumn get eventDate => dateTime().named('Event_Date')();

  TextColumn get eventType => text().named('Event_Type')();
}

// =============================================================================
// DATABASE
// =============================================================================

@DriftDatabase(
  tables: [
    CustomersTable,
    ItemsTable,
    TransactionsTable,
    PaymentsTable,
    HistoryTable,
  ],
)
class ItDataDatabase extends _$ItDataDatabase {
  ItDataDatabase(super.e);

  factory ItDataDatabase.defaults() {
    return ItDataDatabase(
      driftDatabase(
        name: 'itdata',
        native: DriftNativeOptions(
          databasePath: () async =>
              (await legacySqfliteDbFile('itdata.db')).path,
          shareAcrossIsolates: true,
        ),
      ),
    );
  }

  @override
  int get schemaVersion => 4;

  Future<File> get dbFile async => legacySqfliteDbFile('itdata.db');

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _ensureIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await _coerceLegacyTextDatesOnOpen();
      }
      await _ensureIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA cache_size = 10000');
      await _ensureIndexes();
    },
  );

  Future<void> _ensureIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customer_contact ON Customers(Contact_Number)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_customer ON Items(Customer_ID)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_status ON Items(Item_Status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_customer ON Transactions(Customer_ID)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_item ON Transactions(Item_ID)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_type ON Transactions(Transaction_Type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_payments_transaction ON Payments(Transaction_ID)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_history_customer ON History(Customer_ID)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_history_date ON History(Event_Date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_date ON Transactions(Transaction_Date)',
    );
  }

  Future<void> _coerceLegacyTextDatesOnOpen() async {
    // If any of these columns still contain TEXT dates, convert them once.
    // This runs fast and will no-op after conversion.

    try {
      // Quick check: if Transactions.Transaction_Date is TEXT, we definitely need conversion.
      final check = await customSelect('''
      SELECT 1 AS x
      FROM Transactions
      WHERE Transaction_Date IS NOT NULL
        AND typeof(Transaction_Date) = 'text'
      LIMIT 1
      ''').getSingleOrNull();

      if (check == null) {
        // Still convert other columns if needed (in case Transaction_Date was already ok)
        // But to keep it simple, do a broader check:
        final any = await customSelect('''
        SELECT 1 AS x
        WHERE EXISTS(SELECT 1 FROM Customers WHERE typeof(Created_Date)='text' LIMIT 1)
           OR EXISTS(SELECT 1 FROM Items WHERE typeof(Pawned_Date)='text' LIMIT 1)
           OR EXISTS(SELECT 1 FROM Items WHERE typeof(Expiry_Date)='text' LIMIT 1)
           OR EXISTS(SELECT 1 FROM Items WHERE typeof(Created_Date)='text' LIMIT 1)
           OR EXISTS(SELECT 1 FROM Transactions WHERE typeof(Created_Date)='text' LIMIT 1)
           OR EXISTS(SELECT 1 FROM Payments WHERE typeof(Payment_Date)='text' LIMIT 1)
           OR EXISTS(SELECT 1 FROM Payments WHERE typeof(Created_Date)='text' LIMIT 1)
           OR EXISTS(SELECT 1 FROM History WHERE typeof(Event_Date)='text' LIMIT 1)
        LIMIT 1
        ''').getSingleOrNull();

        if (any == null) return;
      }

      await transaction(() async {
        // Customers
        await _convertTextDateColumn(
          table: 'Customers',
          pk: 'Customer_ID',
          column: 'Created_Date',
        );

        // Items
        await _convertTextDateColumn(
          table: 'Items',
          pk: 'Item_ID',
          column: 'Pawned_Date',
        );
        await _convertTextDateColumn(
          table: 'Items',
          pk: 'Item_ID',
          column: 'Expiry_Date',
        );
        await _convertTextDateColumn(
          table: 'Items',
          pk: 'Item_ID',
          column: 'Created_Date',
        );

        // Transactions
        await _convertTextDateColumn(
          table: 'Transactions',
          pk: 'Transaction_ID',
          column: 'Transaction_Date',
        );
        await _convertTextDateColumn(
          table: 'Transactions',
          pk: 'Transaction_ID',
          column: 'Created_Date',
        );

        // Payments
        await _convertTextDateColumn(
          table: 'Payments',
          pk: 'Payment_ID',
          column: 'Payment_Date',
        );
        await _convertTextDateColumn(
          table: 'Payments',
          pk: 'Payment_ID',
          column: 'Created_Date',
        );

        // History
        await _convertTextDateColumn(
          table: 'History',
          pk: 'History_ID',
          column: 'Event_Date',
        );
      });
    } catch (_) {
      // If tables don't exist yet (fresh install) or any edge case, ignore.
    }
  }

  Future<void> _convertTextDateColumn({
    required String table,
    required String pk,
    required String column,
  }) async {
    final rows = await customSelect('''
    SELECT $pk AS id, $column AS d
    FROM $table
    WHERE $column IS NOT NULL
      AND typeof($column) = 'text'
    ''').get();

    if (rows.isEmpty) return;

    for (final r in rows) {
      final id = (r.data['id'] as num).toInt();
      final raw = r.data['d'];

      final parsed = _parseLegacyDate(raw);

      // Store as real drift DateTime (binds as INTEGER millis)
      await customUpdate(
        'UPDATE $table SET $column = ? WHERE $pk = ?',
        variables: [Variable<DateTime>(parsed), Variable<int>(id)],
      );
    }
  }

  DateTime _parseLegacyDate(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);

    // If it was already stored as int/num, keep it
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());

    final s = v.toString().trim();
    if (s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

    // 1) ISO (2026-01-30...)
    try {
      final d = DateTime.parse(s);
      return DateTime(d.year, d.month, d.day);
    } catch (_) {}

    final formats = <DateFormat>[
      DateFormat('dd-MM-yyyy'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('yyyy-MM-dd HH:mm:ss.SSS'),

      // ISO with milliseconds:
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS"),

      // ISO with microseconds (sometimes):
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS"),
    ];

    for (final f in formats) {
      try {
        final d = f.parseStrict(s);
        return DateTime(d.year, d.month, d.day);
      } catch (_) {}
    }
    // Fallback
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

// =============================================================================
// combineLatest2
// =============================================================================

Stream<R> _combineLatest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A av, B bv) combiner,
) {
  late final StreamController<R> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;

  A? lastA;
  B? lastB;
  var hasA = false;
  var hasB = false;

  void tryEmit() {
    if (hasA && hasB) {
      controller.add(combiner(lastA as A, lastB as B));
    }
  }

  controller = StreamController<R>.broadcast(
    onListen: () {
      subA = a.listen((av) {
        lastA = av;
        hasA = true;
        tryEmit();
      }, onError: controller.addError);

      subB = b.listen((bv) {
        lastB = bv;
        hasB = true;
        tryEmit();
      }, onError: controller.addError);
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );

  return controller.stream;
}

// =============================================================================
// BACKEND
// =============================================================================

class BackEnd {
  static ItDataDatabase? _db;

  static Future<ItDataDatabase> db() async {
    _db ??= ItDataDatabase.defaults();
    return _db!;
  }

  // ---------- Date helpers (date-only ranges) ----------
  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _dayEnd(DateTime d) =>
      _dayStart(d).add(const Duration(days: 1));

  static DateTime _monthStart(DateTime d) => DateTime(d.year, d.month);
  static DateTime _monthEnd(DateTime d) => DateTime(d.year, d.month + 1);

  // ===========================================================================
  // CUSTOMERS
  // ===========================================================================

  static Future<int> createNewCustomer(Customer customer) async {
    if (customer.name.trim().isEmpty) {
      throw ArgumentError('Customer name cannot be empty');
    }
    if (customer.number.trim().length < 10) {
      throw ArgumentError('Invalid contact number');
    }

    try {
      final d = await db();
      return await d
          .into(d.customersTable)
          .insert(
            CustomersTableCompanion.insert(
              userId: customer.userID,
              customerName: customer.name.trim(),
              gaurdianName: customer.guardianName.trim(),
              customerAddress: customer.address.trim(),
              contactNumber: customer.number.trim(),
              customerPhoto: customer.photo,
              proofPhoto: customer.proof,
              createdDate: customer.createdDate,
            ),
          );
    } on SqliteException {
      rethrow;
    }
  }

  static Future<List<Customer>> fetchAllCustomerData() async {
    final ItDataDatabase d = await db();
    final List<CustomerRow> rows = await (d.select(
      d.customersTable,
    )..orderBy([(t) => OrderingTerm.asc(t.customerName)])).get();

    if (rows.length < 500) {
      return Threads.computeAllCustomersDetails(rows);
    }
    return await compute(Threads.computeAllCustomersDetails, rows);
  }

  static Future<List<String>> fetchAllCustomerNumbers() async {
    final d = await db();
    final rows =
        await (d.selectOnly(d.customersTable)
              ..addColumns([d.customersTable.contactNumber])
              ..orderBy([OrderingTerm.asc(d.customersTable.contactNumber)]))
            .get();

    return rows.map((r) => r.read(d.customersTable.contactNumber)!).toList();
  }

  static Future<List<Customer>> fetchSingleContactDetails({
    required int id,
  }) async {
    final d = await db();
    final row =
        await (d.select(d.customersTable)
              ..where((t) => t.customerId.equals(id))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return [];

    return [
      Customer(
        id: row.customerId,
        userID: row.userId,
        name: row.customerName,
        guardianName: row.gaurdianName,
        address: row.customerAddress,
        number: row.contactNumber,
        photo: row.customerPhoto,
        proof: row.proofPhoto,
        createdDate: row.createdDate,
      ),
    ];
  }

  static Future<void> deleteTheCustomer({required int customerID}) async {
    final d = await db();
    await d.transaction(() async {
      await (d.delete(
        d.customersTable,
      )..where((t) => t.customerId.equals(customerID))).go();
    });
  }

  static Future<int> updateCustomerDetails({
    required int customerId,
    required String newCustomerName,
    required String newGuardianName,
    required String newCustomerAddress,
    required String newContactNumber,
    required String newCustomerPhoto,
    required String newProofPhoto,
    required DateTime newCreatedDate,
  }) async {
    if (newCustomerName.trim().isEmpty) {
      throw ArgumentError('Customer name cannot be empty');
    }
    if (newContactNumber.trim().length < 10) {
      throw ArgumentError('Invalid contact number');
    }

    final d = await db();
    return await d.transaction(() async {
      final count =
          await (d.update(
            d.customersTable,
          )..where((t) => t.customerId.equals(customerId))).write(
            CustomersTableCompanion(
              customerName: Value(newCustomerName.trim()),
              gaurdianName: Value(newGuardianName.trim()),
              customerAddress: Value(newCustomerAddress.trim()),
              contactNumber: Value(newContactNumber.trim()),
              customerPhoto: Value(newCustomerPhoto),
              proofPhoto: Value(newProofPhoto),
              createdDate: Value(newCreatedDate),
              updatedDate: Value(DateTime.now().toIso8601String()),
            ),
          );

      await (d.update(
        d.historyTable,
      )..where((t) => t.customerId.equals(customerId))).write(
        HistoryTableCompanion(
          customerName: Value(newCustomerName.trim()),
          contactNumber: Value(newContactNumber.trim()),
        ),
      );

      return count;
    });
  }

  // ===========================================================================
  // ITEMS
  // ===========================================================================

  static Future<int> createNewItem(Items item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Item name cannot be empty');
    }
    if (item.pawnAmount <= 0) {
      throw ArgumentError('Pawn amount must be greater than 0');
    }

    final d = await db();
    return await d
        .into(d.itemsTable)
        .insert(
          ItemsTableCompanion.insert(
            customerId: item.customerid,
            itemName: item.name.trim(),
            itemDescription: item.description.trim(),
            pawnedDate: item.pawnedDate,
            expiryDate: item.expiryDate,
            pawnAmount: item.pawnAmount,
            itemStatus: item.status,
            itemPhoto: item.photo,
            createdDate: item.createdDate,
          ),
        );
  }

  static Future<List<Items>> fetchRequriedItem({required int itemId}) async {
    final d = await db();
    final row =
        await (d.select(d.itemsTable)
              ..where((t) => t.itemId.equals(itemId))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return [];
    return [
      Items(
        id: row.itemId,
        customerid: row.customerId,
        name: row.itemName,
        description: row.itemDescription,
        pawnedDate: row.pawnedDate,
        expiryDate: row.expiryDate,
        pawnAmount: row.pawnAmount,
        status: row.itemStatus,
        photo: row.itemPhoto,
        createdDate: row.createdDate,
      ),
    ];
  }

  // ===========================================================================
  // TRANSACTIONS
  // ===========================================================================

  static Future<int> createNewTransaction(Trx transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError('Transaction amount must be greater than 0');
    }
    if (transaction.intrestRate < 0) {
      throw ArgumentError('Interest rate cannot be negative');
    }

    final d = await db();
    return await d
        .into(d.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            customerId: transaction.customerId,
            itemId: transaction.itemId,
            transactionDate: transaction.transacrtionDate,
            transactionType: transaction.transacrtionType,
            amount: transaction.amount,
            interestRate: transaction.intrestRate,
            interestAmount: transaction.intrestAmount,
            remainingAmount: transaction.remainingAmount,
            signature: transaction.signature,
            createdDate: transaction.createdDate,
          ),
        );
  }

  static Future<int> createNewTransactionAtomic({
    required Items item,
    required Trx Function(int itemId) transactionBuilder,
    required UserHistory Function(int itemId, int transactionId) historyBuilder,
  }) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Item name cannot be empty');
    }
    if (item.pawnAmount <= 0) {
      throw ArgumentError('Pawn amount must be greater than 0');
    }

    final d = await db();
    return await d.transaction(() async {
      final itemId = await d
          .into(d.itemsTable)
          .insert(
            ItemsTableCompanion.insert(
              customerId: item.customerid,
              itemName: item.name.trim(),
              itemDescription: item.description.trim(),
              pawnedDate: item.pawnedDate,
              expiryDate: item.expiryDate,
              pawnAmount: item.pawnAmount,
              itemStatus: item.status,
              itemPhoto: item.photo,
              createdDate: item.createdDate,
            ),
          );

      final transaction = transactionBuilder(itemId);
      if (transaction.amount <= 0) {
        throw ArgumentError('Transaction amount must be greater than 0');
      }
      if (transaction.intrestRate < 0) {
        throw ArgumentError('Interest rate cannot be negative');
      }

      final transactionId = await d
          .into(d.transactionsTable)
          .insert(
            TransactionsTableCompanion.insert(
              customerId: transaction.customerId,
              itemId: itemId,
              transactionDate: transaction.transacrtionDate,
              transactionType: transaction.transacrtionType,
              amount: transaction.amount,
              interestRate: transaction.intrestRate,
              interestAmount: transaction.intrestAmount,
              remainingAmount: transaction.remainingAmount,
              signature: transaction.signature,
              createdDate: transaction.createdDate,
            ),
          );

      final history = historyBuilder(itemId, transactionId);
      await d
          .into(d.historyTable)
          .insert(
            HistoryTableCompanion.insert(
              userId: history.userID,
              customerId: history.customerID,
              customerName: history.customerName,
              contactNumber: history.customerNumber,
              itemId: itemId,
              transactionId: transactionId,
              amount: history.amount,
              eventDate: history.eventDate,
              eventType: history.eventType,
            ),
          );

      return transactionId;
    });
  }

  static Future<List<Trx>> fetchAllTransactions() async {
    final d = await db();
    final rows = await (d.select(
      d.transactionsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.transactionId)])).get();

    return rows.map(_trxFromRow).toList();
  }

  static Future<List<Trx>> fetchRequriedTransaction({
    required int transacrtionId,
  }) async {
    final d = await db();
    final row =
        await (d.select(d.transactionsTable)
              ..where((t) => t.transactionId.equals(transacrtionId))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return [];
    return [_trxFromRow(row)];
  }

  static Future<int> updateTransactionAsPaid({
    required int id,
    required double intrestAmount,
  }) async {
    final d = await db();
    return (d.update(
      d.transactionsTable,
    )..where((t) => t.transactionId.equals(id))).write(
      TransactionsTableCompanion(
        transactionType: const Value('Inactive'),
        interestAmount: Value(intrestAmount),
        updatedDate: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  static Future<void> markTransactionAsPaidAtomic({
    required Payment payment,
    required int transactionId,
    required double interestAmount,
    required UserHistory history,
  }) async {
    if (payment.amountpaid <= 0) {
      throw ArgumentError('Payment amount must be greater than 0');
    }

    final d = await db();
    await d.transaction(() async {
      await d
          .into(d.paymentsTable)
          .insert(
            PaymentsTableCompanion.insert(
              transactionId: payment.transactionId,
              paymentDate: payment.paymentDate,
              amountPaid: payment.amountpaid,
              paymentType: payment.type,
              createdDate: payment.createdDate,
            ),
          );

      await (d.update(
        d.transactionsTable,
      )..where((t) => t.transactionId.equals(transactionId))).write(
        TransactionsTableCompanion(
          transactionType: const Value('Inactive'),
          interestAmount: Value(interestAmount),
          updatedDate: Value(DateTime.now().toIso8601String()),
        ),
      );

      await d
          .into(d.historyTable)
          .insert(
            HistoryTableCompanion.insert(
              userId: history.userID,
              customerId: history.customerID,
              customerName: history.customerName,
              contactNumber: history.customerNumber,
              itemId: history.itemID,
              transactionId: history.transactionID,
              amount: history.amount,
              eventDate: history.eventDate,
              eventType: history.eventType,
            ),
          );
    });
  }

  static Future<Map<String, int>> deleteTransaction({
    required int transactionId,
  }) async {
    if (transactionId <= 0) {
      throw ArgumentError.value(
        transactionId,
        'transactionId',
        'transactionId must be a positive integer',
      );
    }

    final d = await db();

    try {
      return await d.transaction(() async {
        final trxRow =
            await (d.select(d.transactionsTable)
                  ..where((t) => t.transactionId.equals(transactionId))
                  ..limit(1))
                .getSingleOrNull();

        if (trxRow == null) {
          throw Exception('Transaction not found: $transactionId');
        }

        if (trxRow.signature.isNotEmpty) {
          final f = File(trxRow.signature);
          if (await f.exists()) await f.delete();
        }

        final historyDeleted = await (d.delete(
          d.historyTable,
        )..where((h) => h.transactionId.equals(transactionId))).go();

        final txnDeleted = await (d.delete(
          d.transactionsTable,
        )..where((t) => t.transactionId.equals(transactionId))).go();

        final itemRow =
            await (d.select(d.itemsTable)
                  ..where((i) => i.itemId.equals(trxRow.itemId))
                  ..limit(1))
                .getSingleOrNull();

        int itemDeleted = 0;
        if (itemRow != null) {
          if (itemRow.itemPhoto.isNotEmpty) {
            final f = File(itemRow.itemPhoto);
            if (await f.exists()) await f.delete();
          }
          itemDeleted = await (d.delete(
            d.itemsTable,
          )..where((i) => i.itemId.equals(trxRow.itemId))).go();
        }

        return {
          'historyDeleted': historyDeleted,
          'transactionDeleted': txnDeleted,
          'itemDeleted': itemDeleted,
        };
      });
    } on SqliteException catch (e) {
      throw Exception('Database error while deleting transaction: $e');
    }
  }

  // ===========================================================================
  // PAYMENTS
  // ===========================================================================

  static Future<List<Payment>> fetchRequriedPaymentsOfTransaction({
    required int transactionId,
  }) async {
    final d = await db();
    final rows =
        await (d.select(d.paymentsTable)
              ..where((t) => t.transactionId.equals(transactionId))
              ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
            .get();

    return rows
        .map(
          (r) => Payment(
            id: r.paymentId,
            transactionId: r.transactionId,
            paymentDate: r.paymentDate,
            amountpaid: r.amountPaid,
            type: r.paymentType,
            createdDate: r.createdDate,
          ),
        )
        .toList();
  }

  static Future<int> addPayment({required Payment payment}) async {
    if (payment.amountpaid <= 0) {
      throw ArgumentError('Payment amount must be greater than 0');
    }

    final d = await db();
    return await d
        .into(d.paymentsTable)
        .insert(
          PaymentsTableCompanion.insert(
            transactionId: payment.transactionId,
            paymentDate: payment.paymentDate,
            amountPaid: payment.amountpaid,
            paymentType: payment.type,
            createdDate: payment.createdDate,
          ),
        );
  }

  // ===========================================================================
  // HISTORY
  // ===========================================================================

  static Future<int> createNewHistory(UserHistory history) async {
    final d = await db();
    return await d
        .into(d.historyTable)
        .insert(
          HistoryTableCompanion.insert(
            userId: history.userID,
            customerId: history.customerID,
            customerName: history.customerName,
            contactNumber: history.customerNumber,
            itemId: history.itemID,
            transactionId: history.transactionID,
            amount: history.amount,
            eventDate: history.eventDate,
            eventType: history.eventType,
          ),
        );
  }

  // ===========================================================================
  // STREAMS (reactive)
  // ===========================================================================

  // CUSTOMERS streams
  static Stream<List<Contact>> watchAllCustomerNumbersWithNames() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final Stream<List<TypedResult>> q =
          (d.selectOnly(d.customersTable)
                ..addColumns([
                  d.customersTable.customerId,
                  d.customersTable.customerName,
                  d.customersTable.contactNumber,
                ])
                ..orderBy([OrderingTerm.asc(d.customersTable.customerName)]))
              .watch();

      return q.asyncMap((rows) {
        final raw = rows
            .map(
              (r) => (
                r.read(d.customersTable.customerId) ?? 0,
                r.read(d.customersTable.customerName) ?? '',
                r.read(d.customersTable.contactNumber) ?? '',
              ),
            )
            .toList();

        if (raw.length < 500) {
          return Threads.mapRowsToContacts(raw);
        }

        return compute(Threads.mapRowsToContacts, raw);
      });
    });
  }

  static Stream<Customer?> watchSingleCustomer({required int id}) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.customersTable)
                ..where((t) => t.customerId.equals(id))
                ..limit(1))
              .watchSingle();

      return q.map((CustomerRow r) {
        return Customer(
          id: r.customerId,
          userID: r.userId,
          name: r.customerName,
          guardianName: r.gaurdianName,
          address: r.customerAddress,
          number: r.contactNumber,
          photo: r.customerPhoto,
          proof: r.proofPhoto,
          createdDate: r.createdDate,
        );
      });
    });
  }

  // ITEMS streams
  static Stream<Items?> watchRequriedItem({required int itemId}) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.itemsTable)
                ..where((t) => t.itemId.equals(itemId))
                ..limit(1))
              .watch();

      return q.map((rows) {
        if (rows.isEmpty) return null;
        final r = rows.first;
        return Items(
          id: r.itemId,
          customerid: r.customerId,
          name: r.itemName,
          description: r.itemDescription,
          pawnedDate: r.pawnedDate,
          expiryDate: r.expiryDate,
          pawnAmount: r.pawnAmount,
          status: r.itemStatus,
          photo: r.itemPhoto,
          createdDate: r.createdDate,
        );
      });
    });
  }

  static Stream<List<Trx>> watchAllTransactions() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final Stream<List<TransactionRow>> q = (d.select(
        d.transactionsTable,
      )..orderBy([(t) => OrderingTerm.desc(t.transactionId)])).watch();

      return q.asyncMap((rows) {
        // Isolate hop only pays off once there's real work to hand off.
        if (rows.length < 1000) {
          return Future.value(Threads.computeAllTransactions(rows));
        }
        return compute(Threads.computeAllTransactions, rows);
      });
    });
  }

  // /// Returns a joined stream of transactions + their customer's name & photo
  // /// in a single SQL query — eliminates N+1 per-row subscriptions in the list UI.
  // static Stream<List<TrxWithCustomer>> watchTransactionsWithCustomer() {
  //   return Stream.fromFuture(db()).asyncExpand((d) {
  //     final t = d.transactionsTable;
  //     final c = d.customersTable;

  //     final q = (d.select(t).join([
  //       leftOuterJoin(c, c.customerId.equalsExp(t.customerId)),
  //     ])..orderBy([OrderingTerm.desc(t.transactionId)])).watch();

  //     return q.map((List<TypedResult> rows) {
  //       return rows.map((TypedResult row) {
  //         final TransactionRow txn = row.readTable(t);
  //         final CustomerRow? cust = row.readTableOrNull(c);
  //         return TrxWithCustomer(
  //           id: txn.transactionId,
  //           customerId: txn.customerId,
  //           itemId: txn.itemId,
  //           transactionDate: txn.transactionDate,
  //           transactionType: txn.transactionType,
  //           amount: txn.amount,
  //           interestRate: txn.interestRate,
  //           interestAmount: txn.interestAmount,
  //           remainingAmount: txn.remainingAmount,
  //           signature: txn.signature,
  //           createdDate: txn.createdDate,
  //           customerName: cust?.customerName ?? '',
  //           customerPhoto: cust?.customerPhoto ?? '',
  //         );
  //       }).toList();
  //     });
  //   });
  // }

  // ===========================================================================
  // PAGINATED TRANSACTIONS (keyset / cursor)
  // ===========================================================================
  /// Fetches ONE page of transactions (newest transaction ID first).
  ///
  /// How the cursor works:
  ///   * First page  -> pass no [beforeTransactionId].
  ///   * Next pages  -> pass the ID of the LAST row of the previous page.
  ///                    Only rows with a smaller ID are returned.
  ///
  /// Optional filters (all combined with AND):
  ///   * [searchQuery] : exact transaction ID, OR customer name contains,
  ///                     OR amount contains.
  ///   * [dateQuery]   : transactions made on that calendar day.
  ///   * [ageMonths]   : transactions older than 1, 3, 6 or 12 months.
  static Future<List<TrxWithCustomer>> fetchTransactionsPage({
    int? beforeTransactionId,
    String searchQuery = '',
    DateTime? dateQuery,
    int? ageMonths,
    int limit = 30,
  }) async {
    // ---- 1. Validate input -------------------------------------------------
    if (limit <= 0) {
      throw ArgumentError('limit must be greater than 0');
    }
    if (ageMonths != null && ![1, 3, 6, 12].contains(ageMonths)) {
      throw ArgumentError('Months must be one of: 1, 3, 6, or 12');
    }

    // ---- 2. Set up tables and the JOIN ------------------------------------
    final ItDataDatabase d = await db();
    final $TransactionsTableTable t = d.transactionsTable;
    final $CustomersTableTable c = d.customersTable;

    final joined = d.select(t).join([
      leftOuterJoin(c, c.customerId.equalsExp(t.customerId)),
    ]);

    // ---- 3. Build the WHERE conditions ------------------------------------
    final List<Expression<bool>> conditions = [];

    // 3a. Cursor: only rows older than the last loaded one.
    if (beforeTransactionId != null) {
      conditions.add(t.transactionId.isSmallerThanValue(beforeTransactionId));
    }

    // 3b. Search by ID / customer name / amount.
    final String query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      final String pattern = '%$query%';
      final int? idQuery = int.tryParse(query);

      // Exact ID match (same behaviour as the old stream version).
      final Expression<bool> idMatch = idQuery != null
          ? t.transactionId.equals(idQuery)
          : const Constant<bool>(false);

      final Expression<bool> nameMatch = c.customerName.like(pattern);
      final Expression<bool> amountMatch = t.amount.cast<String>().like(
        pattern,
      );

      conditions.add(idMatch | nameMatch | amountMatch);
    }

    // 3c. Single-day filter.
    if (dateQuery != null) {
      conditions.add(
        t.transactionDate.isBiggerOrEqualValue(_dayStart(dateQuery)) &
            t.transactionDate.isSmallerThanValue(_dayEnd(dateQuery)),
      );
    }

    // 3d. "Older than N months" filter.
    if (ageMonths != null) {
      final DateTime now = DateTime.now();
      final DateTime cutoff = DateTime(
        now.year,
        now.month - ageMonths,
        now.day,
      );
      conditions.add(t.transactionDate.isSmallerThanValue(cutoff));
    }

    // Combine everything with AND and apply once.
    if (conditions.isNotEmpty) {
      joined.where(conditions.reduce((a, b) => a & b));
    }

    // ---- 4. Order + LIMIT --------------------------------------------------
    joined
      ..orderBy([OrderingTerm.desc(t.transactionId)])
      ..limit(limit);

    // ---- 5. Run the query and map rows ------------------------------------
    final List<TypedResult> rows = await joined.get();

    return rows.map((row) {
      final TransactionRow txn = row.readTable(t);
      final CustomerRow? cust = row.readTableOrNull(c);
      return TrxWithCustomer(
        id: txn.transactionId,
        customerId: txn.customerId,
        itemId: txn.itemId,
        transactionDate: txn.transactionDate,
        transactionType: txn.transactionType,
        amount: txn.amount,
        interestRate: txn.interestRate,
        interestAmount: txn.interestAmount,
        remainingAmount: txn.remainingAmount,
        signature: txn.signature,
        createdDate: txn.createdDate,
        customerName: cust?.customerName ?? '',
        customerPhoto: cust?.customerPhoto ?? '',
      );
    }).toList();
  }

  static Stream<List<Trx>> watchRequriedCustomerTransactions({
    required int customerId,
  }) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.transactionsTable)
                ..where((t) => t.customerId.equals(customerId))
                ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
              .watch();

      return q.map((rows) => rows.map(_trxFromRow).toList());
    });
  }

  static Stream<Trx?> watchRequriedTransaction({required int transactionId}) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.transactionsTable)
                ..where((t) => t.transactionId.equals(transactionId))
                ..limit(1))
              .watch();

      return q.map((rows) => rows.isEmpty ? null : _trxFromRow(rows.first));
    });
  }

  static Stream<List<Trx>> watchTransactionsByDate({
    required DateTime inputDate,
  }) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final start = _dayStart(inputDate);
      final end = _dayEnd(inputDate);

      final q =
          (d.select(d.transactionsTable)
                ..where(
                  (t) =>
                      t.transactionDate.isBiggerOrEqualValue(start) &
                      t.transactionDate.isSmallerThanValue(end),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
              .watch();

      return q.map((rows) => rows.map(_trxFromRow).toList());
    });
  }

  static Stream<List<Trx>> watchTransactionsByAge({required int months}) {
    if (![1, 3, 6, 12].contains(months)) {
      throw ArgumentError('Months must be one of: 1, 3, 6, or 12');
    }

    return Stream.fromFuture(db()).asyncExpand((d) {
      final now = DateTime.now();
      final cutoff = DateTime(now.year, now.month - months, now.day);

      final q =
          (d.select(d.transactionsTable)
                ..where((t) => t.transactionDate.isSmallerThanValue(cutoff))
                ..orderBy([
                  (t) => OrderingTerm.desc(t.transactionDate),
                  (t) => OrderingTerm.desc(t.transactionId),
                ]))
              .watch();

      return q.map((rows) => rows.map(_trxFromRow).toList());
    });
  }

  /// Joined variant of [watchTransactionsByDate] — returns [TrxWithCustomer].
  static Stream<List<TrxWithCustomer>> watchTransactionsByDateWithCustomer({
    required DateTime inputDate,
  }) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final start = _dayStart(inputDate);
      final end = _dayEnd(inputDate);
      final t = d.transactionsTable;
      final c = d.customersTable;

      final q =
          (d.select(t).join([
                  leftOuterJoin(c, c.customerId.equalsExp(t.customerId)),
                ])
                ..where(
                  t.transactionDate.isBiggerOrEqualValue(start) &
                      t.transactionDate.isSmallerThanValue(end),
                )
                ..orderBy([OrderingTerm.desc(t.createdDate)]))
              .watch();

      return q.map(
        (rows) => rows.map((row) {
          final txn = row.readTable(t);
          final cust = row.readTableOrNull(c);
          return TrxWithCustomer(
            id: txn.transactionId,
            customerId: txn.customerId,
            itemId: txn.itemId,
            transactionDate: txn.transactionDate,
            transactionType: txn.transactionType,
            amount: txn.amount,
            interestRate: txn.interestRate,
            interestAmount: txn.interestAmount,
            remainingAmount: txn.remainingAmount,
            signature: txn.signature,
            createdDate: txn.createdDate,
            customerName: cust?.customerName ?? '',
            customerPhoto: cust?.customerPhoto ?? '',
          );
        }).toList(),
      );
    });
  }

  /// Joined variant of [watchTransactionsByAge] — returns [TrxWithCustomer].
  static Stream<List<TrxWithCustomer>> watchTransactionsByAgeWithCustomer({
    required int months,
  }) {
    if (![1, 3, 6, 12].contains(months)) {
      throw ArgumentError('Months must be one of: 1, 3, 6, or 12');
    }

    return Stream.fromFuture(db()).asyncExpand((d) {
      final now = DateTime.now();
      final cutoff = DateTime(now.year, now.month - months, now.day);
      final t = d.transactionsTable;
      final c = d.customersTable;

      final q =
          (d.select(t).join([
                  leftOuterJoin(c, c.customerId.equalsExp(t.customerId)),
                ])
                ..where(t.transactionDate.isSmallerThanValue(cutoff))
                ..orderBy([
                  OrderingTerm.desc(t.transactionDate),
                  OrderingTerm.desc(t.transactionId),
                ]))
              .watch();

      return q.map(
        (rows) => rows.map((row) {
          final txn = row.readTable(t);
          final cust = row.readTableOrNull(c);
          return TrxWithCustomer(
            id: txn.transactionId,
            customerId: txn.customerId,
            itemId: txn.itemId,
            transactionDate: txn.transactionDate,
            transactionType: txn.transactionType,
            amount: txn.amount,
            interestRate: txn.interestRate,
            interestAmount: txn.interestAmount,
            remainingAmount: txn.remainingAmount,
            signature: txn.signature,
            createdDate: txn.createdDate,
            customerName: cust?.customerName ?? '',
            customerPhoto: cust?.customerPhoto ?? '',
          );
        }).toList(),
      );
    });
  }

  // PAYMENTS streams
  static Stream<List<Payment>> watchRequriedPaymentsOfTransaction({
    required int transactionId,
  }) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.paymentsTable)
                ..where((t) => t.transactionId.equals(transactionId))
                ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
              .watch();

      return q.map(
        (rows) => rows
            .map(
              (r) => Payment(
                id: r.paymentId,
                transactionId: r.transactionId,
                paymentDate: r.paymentDate,
                amountpaid: r.amountPaid,
                type: r.paymentType,
                createdDate: r.createdDate,
              ),
            )
            .toList(),
      );
    });
  }

  // HISTORY streams
  static Stream<List<UserHistory>> watchAllUserHistory() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q = (d.select(
        d.historyTable,
      )..orderBy([(t) => OrderingTerm.desc(t.eventDate)])).watch();

      return q.map(
        (rows) => rows
            .map(
              (r) => UserHistory(
                id: r.historyId,
                userID: r.userId,
                customerID: r.customerId,
                customerName: r.customerName,
                customerNumber: r.contactNumber,
                itemID: r.itemId,
                transactionID: r.transactionId,
                amount: r.amount,
                eventDate: r.eventDate,
                eventType: r.eventType,
              ),
            )
            .toList(),
      );
    });
  }

  // ===========================================================================
  // ANALYTICS (streams)
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Outstanding calculation cache & helpers — the LoanCalculator loop is
  // CPU-bound. To ensure optimal performance:
  // 1. Results are cached and only recalculated when active loans actually
  //    change (amount, rate, transactionDate, or list membership) or when the
  //    calendar date changes (since interest accrues daily).
  // 2. Unrelated stream ticks (e.g. customer changes, payments, or duplicate
  //    notifications from _combineLatest2) hit the cache with zero overhead.
  // 3. For small datasets (<20 loans), calculation runs inline to avoid isolate
  //    spawning latency (~2ms). For larger datasets (>=20 loans), it is
  //    offloaded to a background isolate via compute() to keep UI frame rates
  //    fluid (60/120fps).
  // ---------------------------------------------------------------------------

  static List<TransactionRow>? _cachedActiveLoans;
  static double _cachedOutstanding = 0.0;
  static DateTime? _cachedCalcDate;

  /// Checks whether two lists of active [TransactionRow]s have identical
  /// properties affecting [LoanCalculator] results.
  static bool _areActiveLoansEqual(
    List<TransactionRow>? a,
    List<TransactionRow> b,
  ) {
    if (a == null) return false;
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final ra = a[i];
      final rb = b[i];
      if (ra.transactionId != rb.transactionId ||
          ra.amount != rb.amount ||
          ra.interestRate != rb.interestRate ||
          ra.transactionDate != rb.transactionDate) {
        return false;
      }
    }
    return true;
  }

  /// Converts active [TransactionRow]s into serialisable maps for compute().
  static List<Map<String, Object>> _buildLoanPayloads(
    List<TransactionRow> rows,
  ) {
    return rows
        .map(
          (r) => <String, Object>{
            'amount': r.amount,
            'rate': r.interestRate,
            // millisecondsSinceEpoch is a plain int — safe across isolates
            'dateMs': r.transactionDate.millisecondsSinceEpoch,
          },
        )
        .toList();
  }

  /// Runs inside the background isolate — must be a static method.
  static double _computeOutstanding(List<Map<String, Object>> payloads) {
    double total = 0.0;
    for (final p in payloads) {
      final l = LoanCalculator(
        takenAmount: p['amount']! as double,
        rateOfInterest: p['rate']! as double,
        takenDate: DateTime.fromMillisecondsSinceEpoch(p['dateMs']! as int),
      );
      total += l.totalAmount;
    }
    return total;
  }

  static Stream<Map<String, num>> watchAnalyticsData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final base = d
          .customSelect(
            '''
        SELECT
          (SELECT COUNT(*) FROM Customers)  AS totalCustomers,

          (SELECT COUNT(*)
             FROM Transactions
             WHERE Transaction_Type = ?)   AS activeLoans,

          (SELECT COALESCE(SUM(Interest_Amount), 0)
             FROM Transactions
             WHERE Transaction_Type = ?)  AS interestEarned,

          (SELECT COALESCE(SUM(Amount), 0)
             FROM Transactions) AS totalDisbursed,

          (SELECT COALESCE(SUM(Amount_Paid), 0)
             FROM Payments)  AS paymentsReceived
        ''',
            variables: const [
              Variable<String>('Active'),
              Variable<String>('Inactive'), // ✅ earned when closed
            ],
            readsFrom: {d.customersTable, d.transactionsTable, d.paymentsTable},
          )
          .watch();

      final activeTxns = (d.select(
        d.transactionsTable,
      )..where((t) => t.transactionType.equals('Active'))).watch();

      // Combine both streams and use asyncMap so we can await the compute()
      // future when recalculation is necessary.
      return _combineLatest2(
        base,
        activeTxns,
        (baseRows, activeRows) => (baseRows, activeRows),
      ).asyncMap(((List<QueryRow>, List<TransactionRow>) pair) async {
        final (baseRows, activeRows) = pair;
        final row = baseRows.first.data;

        final today = AppDateUtils.dateOnly(DateTime.now());
        final double totalOutstanding;

        if (activeRows.isEmpty) {
          totalOutstanding = 0.0;
          _cachedActiveLoans = activeRows;
          _cachedOutstanding = 0.0;
          _cachedCalcDate = today;
        } else if (_cachedCalcDate == today &&
            _areActiveLoansEqual(_cachedActiveLoans, activeRows)) {
          // Re-use cached result — avoid re-running LoanCalculator on every DB tick
          // when active transactions haven't changed (e.g. customer/payment changes
          // or duplicate stream events).
          totalOutstanding = _cachedOutstanding;
        } else {
          // Threshold: spin up an isolate only when there is real work to justify
          // the ~2 ms isolate-spawn overhead.
          if (activeRows.length < 20) {
            // Small dataset — run inline on the main isolate.
            totalOutstanding = _computeOutstanding(
              _buildLoanPayloads(activeRows),
            );
          } else {
            // Large dataset — offload to a background isolate so the UI stays
            // smooth regardless of how many active loans exist.
            totalOutstanding = await compute(
              _computeOutstanding,
              _buildLoanPayloads(activeRows),
            );
          }
          _cachedActiveLoans = activeRows;
          _cachedOutstanding = totalOutstanding;
          _cachedCalcDate = today;
        }

        return <String, num>{
          'totalCustomers': (row['totalCustomers'] as num?) ?? 0,
          'activeLoans': (row['activeLoans'] as num?) ?? 0,
          'outstandingAmount': totalOutstanding,
          'interestEarned': (row['interestEarned'] as num?) ?? 0,
          'totalDisbursed': (row['totalDisbursed'] as num?) ?? 0,
          'paymentsReceived': (row['paymentsReceived'] as num?) ?? 0,
        };
      });
    });
  }

  static Stream<List<Map<String, dynamic>>> watchMonthlyChartData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final txns = d.select(d.transactionsTable).watch();
      final pays = d.select(d.paymentsTable).watch();

      return _combineLatest2(txns, pays, (_, _) => 0).asyncMap((_) async {
        return fetchMonthlyChartData();
      });
    });
  }

  // ===========================================================================
  // DB management
  // ===========================================================================

  static Future<void> close() async {
    final d = _db;
    if (d == null) return;
    await d.close();
    _db = null;
  }

  // ===========================================================================
  // ANALYTICS (future)
  // ===========================================================================

  // ===========================================================================
  // CHARTS (future) - ✅ DateTime ranges
  // ===========================================================================

  static Future<List<Map<String, dynamic>>> fetchMonthlyChartData() async {
    final d = await db();
    final now = DateTime.now();

    final overallStart = _monthStart(DateTime(now.year, now.month - 5));
    final overallEnd = _monthEnd(DateTime(now.year, now.month));

    final txnQuery =
        (d.selectOnly(d.transactionsTable)
              ..addColumns([
                d.transactionsTable.transactionDate,
                d.transactionsTable.amount,
              ])
              ..where(
                d.transactionsTable.transactionDate.isBiggerOrEqualValue(
                      overallStart,
                    ) &
                    d.transactionsTable.transactionDate.isSmallerThanValue(
                      overallEnd,
                    ),
              ))
            .get();

    final payQuery =
        (d.selectOnly(d.paymentsTable)
              ..addColumns([
                d.paymentsTable.paymentDate,
                d.paymentsTable.amountPaid,
              ])
              ..where(
                d.paymentsTable.paymentDate.isBiggerOrEqualValue(overallStart) &
                    d.paymentsTable.paymentDate.isSmallerThanValue(overallEnd),
              ))
            .get();

    final queryResults = await Future.wait([txnQuery, payQuery]);
    final txnRows = queryResults[0];
    final payRows = queryResults[1];

    final Map<String, double> disbursedByMonth = {};
    for (final r in txnRows) {
      final dt = r.read(d.transactionsTable.transactionDate);
      if (dt == null) continue;
      final k = '${dt.year}-${dt.month}';
      final amt = r.read(d.transactionsTable.amount) ?? 0.0;
      disbursedByMonth[k] = (disbursedByMonth[k] ?? 0.0) + amt;
    }

    final Map<String, double> receivedByMonth = {};
    for (final r in payRows) {
      final dt = r.read(d.paymentsTable.paymentDate);
      if (dt == null) continue;
      final k = '${dt.year}-${dt.month}';
      final amt = r.read(d.paymentsTable.amountPaid) ?? 0.0;
      receivedByMonth[k] = (receivedByMonth[k] ?? 0.0) + amt;
    }

    final results = <Map<String, dynamic>>[];
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i);
      final k = '${monthDate.year}-${monthDate.month}';

      results.add({
        'month': DateFormat('MMM').format(monthDate),
        'disbursed': disbursedByMonth[k] ?? 0.0,
        'received': receivedByMonth[k] ?? 0.0,
      });
    }

    return results;
  }

  static Trx _trxFromRow(TransactionRow r) => Trx(
    id: r.transactionId,
    customerId: r.customerId,
    itemId: r.itemId,
    transacrtionDate: r.transactionDate,
    transacrtionType: r.transactionType,
    amount: r.amount,
    intrestRate: r.interestRate,
    intrestAmount: r.interestAmount,
    remainingAmount: r.remainingAmount,
    signature: r.signature,
    createdDate: r.createdDate,
  );

  // ===========================================================================
  // YEARLY / WEEKLY / TODAY (streams + futures) - ✅ DateTime ranges
  // ===========================================================================

  static Stream<List<Map<String, dynamic>>> watchYearlyChartData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      return d
          .customSelect(
            'SELECT 1',
            readsFrom: {d.transactionsTable, d.paymentsTable},
          )
          .watch()
          .asyncMap((_) => fetchYearlyChartData());
    });
  }

  static Future<List<Map<String, dynamic>>> fetchYearlyChartData() async {
    final d = await db();
    final now = DateTime.now();

    final overallStart = _monthStart(DateTime(now.year, now.month - 11));
    final overallEnd = _monthEnd(DateTime(now.year, now.month));

    final txnQuery =
        (d.selectOnly(d.transactionsTable)
              ..addColumns([
                d.transactionsTable.transactionDate,
                d.transactionsTable.amount,
              ])
              ..where(
                d.transactionsTable.transactionDate.isBiggerOrEqualValue(
                      overallStart,
                    ) &
                    d.transactionsTable.transactionDate.isSmallerThanValue(
                      overallEnd,
                    ),
              ))
            .get();

    final payQuery =
        (d.selectOnly(d.paymentsTable)
              ..addColumns([
                d.paymentsTable.paymentDate,
                d.paymentsTable.amountPaid,
              ])
              ..where(
                d.paymentsTable.paymentDate.isBiggerOrEqualValue(overallStart) &
                    d.paymentsTable.paymentDate.isSmallerThanValue(overallEnd),
              ))
            .get();

    final queryResults = await Future.wait([txnQuery, payQuery]);
    final txnRows = queryResults[0];
    final payRows = queryResults[1];

    final Map<String, double> disbursedByMonth = {};
    for (final r in txnRows) {
      final dt = r.read(d.transactionsTable.transactionDate);
      if (dt == null) continue;
      final k = '${dt.year}-${dt.month}';
      final amt = r.read(d.transactionsTable.amount) ?? 0.0;
      disbursedByMonth[k] = (disbursedByMonth[k] ?? 0.0) + amt;
    }

    final Map<String, double> receivedByMonth = {};
    for (final r in payRows) {
      final dt = r.read(d.paymentsTable.paymentDate);
      if (dt == null) continue;
      final k = '${dt.year}-${dt.month}';
      final amt = r.read(d.paymentsTable.amountPaid) ?? 0.0;
      receivedByMonth[k] = (receivedByMonth[k] ?? 0.0) + amt;
    }

    final results = <Map<String, dynamic>>[];
    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i);
      final k = '${monthDate.year}-${monthDate.month}';

      results.add({
        'month': DateFormat('MMM').format(monthDate),
        'disbursed': disbursedByMonth[k] ?? 0.0,
        'received': receivedByMonth[k] ?? 0.0,
        '_monthNum': monthDate.month,
        '_year': monthDate.year,
      });
    }

    return results;
  }

  static Stream<List<Map<String, dynamic>>> watchWeeklyChartData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      return d
          .customSelect(
            'SELECT 1',
            readsFrom: {d.transactionsTable, d.paymentsTable},
          )
          .watch()
          .asyncMap((_) => fetchWeeklyChartData());
    });
  }

  static Future<List<Map<String, dynamic>>> fetchWeeklyChartData() async {
    final d = await db();
    final now = DateTime.now();

    final oldestDay = now.subtract(const Duration(days: 6));
    final overallStart = _dayStart(oldestDay);
    final overallEnd = _dayEnd(now);

    final txnQuery =
        (d.selectOnly(d.transactionsTable)
              ..addColumns([
                d.transactionsTable.transactionDate,
                d.transactionsTable.amount,
              ])
              ..where(
                d.transactionsTable.transactionDate.isBiggerOrEqualValue(
                      overallStart,
                    ) &
                    d.transactionsTable.transactionDate.isSmallerThanValue(
                      overallEnd,
                    ),
              ))
            .get();

    final payQuery =
        (d.selectOnly(d.paymentsTable)
              ..addColumns([
                d.paymentsTable.paymentDate,
                d.paymentsTable.amountPaid,
              ])
              ..where(
                d.paymentsTable.paymentDate.isBiggerOrEqualValue(overallStart) &
                    d.paymentsTable.paymentDate.isSmallerThanValue(overallEnd),
              ))
            .get();

    final queryResults = await Future.wait([txnQuery, payQuery]);
    final txnRows = queryResults[0];
    final payRows = queryResults[1];

    final Map<String, double> disbursedByDay = {};
    for (final r in txnRows) {
      final dt = r.read(d.transactionsTable.transactionDate);
      if (dt == null) continue;
      final k = '${dt.year}-${dt.month}-${dt.day}';
      final amt = r.read(d.transactionsTable.amount) ?? 0.0;
      disbursedByDay[k] = (disbursedByDay[k] ?? 0.0) + amt;
    }

    final Map<String, double> receivedByDay = {};
    for (final r in payRows) {
      final dt = r.read(d.paymentsTable.paymentDate);
      if (dt == null) continue;
      final k = '${dt.year}-${dt.month}-${dt.day}';
      final amt = r.read(d.paymentsTable.amountPaid) ?? 0.0;
      receivedByDay[k] = (receivedByDay[k] ?? 0.0) + amt;
    }

    final results = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final k = '${day.year}-${day.month}-${day.day}';

      results.add({
        'month': DateFormat('EEE').format(day),
        'disbursed': disbursedByDay[k] ?? 0.0,
        'received': receivedByDay[k] ?? 0.0,
        // keep for your drill-down UI compatibility
        '_txnDate': DateFormat('dd/MM/yyyy').format(day),
        '_payDate': DateFormat('yyyy-MM-dd').format(day),
      });
    }

    return results;
  }

  static Stream<Map<String, dynamic>> watchTodayChartData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      return d
          .customSelect(
            'SELECT 1',
            readsFrom: {d.transactionsTable, d.paymentsTable},
          )
          .watch()
          .asyncMap((_) => fetchTodayChartData());
    });
  }

  static Future<Map<String, dynamic>> fetchTodayChartData() async {
    final d = await db();
    final now = DateTime.now();
    final start = _dayStart(now);
    final end = _dayEnd(now);

    final txnSumExpr = d.transactionsTable.amount.sum();
    final txnCountExpr = d.transactionsTable.transactionId.count();

    final paySumExpr = d.paymentsTable.amountPaid.sum();
    final payCountExpr = d.paymentsTable.paymentId.count();

    final txnFuture =
        (d.selectOnly(d.transactionsTable)
              ..addColumns([txnSumExpr, txnCountExpr])
              ..where(
                d.transactionsTable.transactionDate.isBiggerOrEqualValue(
                      start,
                    ) &
                    d.transactionsTable.transactionDate.isSmallerThanValue(end),
              ))
            .getSingle();

    final payFuture =
        (d.selectOnly(d.paymentsTable)
              ..addColumns([paySumExpr, payCountExpr])
              ..where(
                d.paymentsTable.paymentDate.isBiggerOrEqualValue(start) &
                    d.paymentsTable.paymentDate.isSmallerThanValue(end),
              ))
            .getSingle();

    final rows = await Future.wait([txnFuture, payFuture]);
    final txnRow = rows[0];
    final payRow = rows[1];

    final double disbTotal = (txnRow.read(txnSumExpr) ?? 0).toDouble();
    final int disbCount = txnRow.read(txnCountExpr) ?? 0;

    final double recTotal = (payRow.read(paySumExpr) ?? 0).toDouble();
    final int recCount = payRow.read(payCountExpr) ?? 0;

    return {
      'disbursed': disbTotal,
      'disbursedCount': disbCount,
      'received': recTotal,
      'receivedCount': recCount,
      'net': recTotal - disbTotal,
    };
  }

  // ===========================================================================
  // DRILL DOWN (month / day) - ✅ DateTime ranges
  // ===========================================================================

  static Future<List<Map<String, dynamic>>> fetchDrillDownForMonth({
    required int month,
    required int year,
  }) async {
    final d = await db();

    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);

    final txns =
        await (d.select(d.transactionsTable)
              ..where(
                (t) =>
                    t.transactionDate.isBiggerOrEqualValue(start) &
                    t.transactionDate.isSmallerThanValue(end),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
            .get();

    final pays =
        await (d.select(d.paymentsTable)
              ..where(
                (p) =>
                    p.paymentDate.isBiggerOrEqualValue(start) &
                    p.paymentDate.isSmallerThanValue(end),
              )
              ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
            .get();

    final all = <Map<String, dynamic>>[
      ...txns.map(
        (t) => {
          'id': t.transactionId,
          'amount': t.amount,
          'date': DateFormat('dd-MM-yyyy').format(t.transactionDate),
          'type': t.transactionType,
          'kind': 'disbursed',
          '_ts': t.transactionDate.millisecondsSinceEpoch,
        },
      ),
      ...pays.map(
        (p) => {
          'id': p.transactionId,
          'amount': p.amountPaid,
          'date': DateFormat('dd-MM-yyyy').format(p.paymentDate),
          'type': p.paymentType,
          'kind': 'received',
          '_ts': p.paymentDate.millisecondsSinceEpoch,
        },
      ),
    ]..sort((a, b) => (b['_ts'] as int).compareTo(a['_ts'] as int));

    for (final m in all) {
      m.remove('_ts');
    }
    return all;
  }

  /// Signature kept for your existing UI:
  /// txnDate = dd/MM/yyyy, payDate = yyyy-MM-dd
  static Future<List<Map<String, dynamic>>> fetchDrillDownForDay({
    required String txnDate,
    required String payDate,
  }) async {
    final d = await db();

    DateTime day;
    try {
      day = DateFormat('dd/MM/yyyy').parseStrict(txnDate);
    } catch (_) {
      day = DateFormat('yyyy-MM-dd').parseStrict(payDate);
    }

    final start = _dayStart(day);
    final end = _dayEnd(day);

    final txns =
        await (d.select(d.transactionsTable)
              ..where(
                (t) =>
                    t.transactionDate.isBiggerOrEqualValue(start) &
                    t.transactionDate.isSmallerThanValue(end),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
            .get();

    final pays =
        await (d.select(d.paymentsTable)
              ..where(
                (p) =>
                    p.paymentDate.isBiggerOrEqualValue(start) &
                    p.paymentDate.isSmallerThanValue(end),
              )
              ..orderBy([(p) => OrderingTerm.desc(p.createdDate)]))
            .get();

    return [
      ...txns.map(
        (t) => {
          'id': t.transactionId,
          'amount': t.amount,
          'date': DateFormat('yyyy-MM-dd').format(t.transactionDate),
          'type': t.transactionType,
          'kind': 'disbursed',
        },
      ),
      ...pays.map(
        (p) => {
          'id': p.transactionId,
          'amount': p.amountPaid,
          'date': DateFormat('yyyy-MM-dd').format(p.paymentDate),
          'type': p.paymentType,
          'kind': 'received',
        },
      ),
    ];
  }
}
