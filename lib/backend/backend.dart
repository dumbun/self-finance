import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';

import 'db_paths.dart';

part 'backend.g.dart';

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

  TextColumn get createdDate => text().named('Created_Date')();

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

  TextColumn get pawnedDate => text().named('Pawned_Date')();

  TextColumn get expiryDate => text().named('Expiry_Date')();

  RealColumn get pawnAmount => real().named('Pawn_Amount')();

  TextColumn get itemStatus => text().named('Item_Status')();

  TextColumn get itemPhoto => text().named('Item_Photo')();

  TextColumn get createdDate => text().named('Created_Date')();

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

  TextColumn get transactionDate => text().named('Transaction_Date')();

  TextColumn get transactionType => text().named('Transaction_Type')();

  RealColumn get amount => real().named('Amount')();

  RealColumn get interestRate => real().named('Interest_Rate')();

  RealColumn get interestAmount => real().named('Interest_Amount')();

  RealColumn get remainingAmount => real().named('Remaining_Amount')();

  TextColumn get signature => text().named('Signature')();

  TextColumn get createdDate => text().named('Created_Date')();

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

  TextColumn get paymentDate => text().named('Payment_Date')();

  RealColumn get amountPaid => real().named('Amount_Paid')();

  TextColumn get paymentType => text().named('Payment_Type')();

  TextColumn get createdDate => text().named('Created_Date')();
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

  TextColumn get eventDate => text().named('Event_Date')();

  TextColumn get eventType => text().named('Event_Type')();
}

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

  /// Default constructor used by your Flutter app.
  ///
  /// IMPORTANT: We point drift to the same file that sqflite used, so your
  /// existing data stays intact.
  factory ItDataDatabase.defaults() {
    return ItDataDatabase(
      driftDatabase(
        name: 'itdata',
        native: DriftNativeOptions(
          // Reuse the exact file path used by the old sqflite backend.
          databasePath: () async =>
              (await legacySqfliteDbFile('itdata.db')).path,
          shareAcrossIsolates: true,
        ),
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  /// Handy access to the underlying file (for backup / size).
  Future<File> get dbFile async => legacySqfliteDbFile('itdata.db');

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _ensureIndexes();
    },
    beforeOpen: (details) async {
      // Match your old sqflite configuration.
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA cache_size = 10000');

      await _ensureIndexes();
    },
  );

  Future<void> _ensureIndexes() async {
    // Safe to run on every open.
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
  }
}

/// Drop-in replacement for your old `BackEnd` class, but powered by drift.
///
/// You can either:
/// - rename this class to `BackEnd` and delete the old sqflite backend, OR
/// - update call sites from `BackEnd.` -> `BackEndDrift.`

// ---------------------------------------------------------------------------
// Stream helpers
// ---------------------------------------------------------------------------

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

class BackEnd {
  static ItDataDatabase? _db;

  static Future<ItDataDatabase> db() async {
    _db ??= ItDataDatabase.defaults();
    return _db!;
  }

  //// C U S T O M E R S

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
      // Provide a nicer message for duplicate numbers.
      // if (e.extendedResultCode ==
      //     SqlExtendedResultCodes.sqliteConstraintUnique) {
      //   throw Exception('Contact number already exists');
      // }
      rethrow;
    }
  }

  static Future<List<Customer>> fetchAllCustomerData() async {
    final d = await db();
    final rows = await (d.select(
      d.customersTable,
    )..orderBy([(t) => OrderingTerm.asc(t.customerName)])).get();

    return rows
        .map(
          (r) => Customer(
            id: r.customerId,
            userID: r.userId,
            name: r.customerName,
            guardianName: r.gaurdianName,
            address: r.customerAddress,
            number: r.contactNumber,
            photo: r.customerPhoto,
            proof: r.proofPhoto,
            createdDate: r.createdDate,
          ),
        )
        .toList();
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

  static Future<List<Contact>> fetchAllCustomerNumbersWithNames() async {
    final d = await db();
    final rows =
        await (d.selectOnly(d.customersTable)
              ..addColumns([
                d.customersTable.customerId,
                d.customersTable.customerName,
                d.customersTable.contactNumber,
              ])
              ..orderBy([OrderingTerm.asc(d.customersTable.customerName)]))
            .get();

    return rows
        .map(
          (r) => Contact(
            id: r.read(d.customersTable.customerId)!,
            name: r.read(d.customersTable.customerName)!,
            number: r.read(d.customersTable.contactNumber)!,
          ),
        )
        .toList();
  }

  static Future<String> fetchRequriedCustomerName(int id) async {
    final d = await db();
    final row =
        await (d.selectOnly(d.customersTable)
              ..addColumns([d.customersTable.customerName])
              ..where(d.customersTable.customerId.equals(id))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) throw Exception('Customer not found');
    return row.read(d.customersTable.customerName)!;
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
    required String newCreatedDate,
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

      // keep History in sync like your sqflite code
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

  //// I T E M S

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

  static Future<List<Items>> fetchAllItems() async {
    final d = await db();
    final rows = await (d.select(
      d.itemsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdDate)])).get();

    return rows
        .map(
          (r) => Items(
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
          ),
        )
        .toList();
  }

  static Future<List<Items>> fetchitemOfRequriedCustomer({
    required int customerID,
  }) async {
    final d = await db();
    final rows =
        await (d.select(d.itemsTable)
              ..where((t) => t.customerId.equals(customerID))
              ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
            .get();

    return rows
        .map(
          (r) => Items(
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
          ),
        )
        .toList();
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

  //// T R A N S A C T I O N S

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

  static Future<List<Trx>> fetchAllTransactions() async {
    final d = await db();
    final rows = await (d.select(
      d.transactionsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.transactionId)])).get();

    return rows.map(_trxFromRow).toList();
  }

  static Future<List<Trx>> fetchActiveTransactions() async {
    final d = await db();
    final rows =
        await (d.select(d.transactionsTable)
              ..where((t) => t.transactionType.equals('Active'))
              ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
            .get();
    return rows.map(_trxFromRow).toList();
  }

  static Future<List<Trx>> fetchRequriedCustomerTransactions({
    required int customerId,
  }) async {
    final d = await db();
    final rows =
        await (d.select(d.transactionsTable)
              ..where((t) => t.customerId.equals(customerId))
              ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
            .get();
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

  static Future<double> fetchSumOfTakenAmount() async {
    final d = await db();
    final rows = await d
        .customSelect(
          'SELECT COALESCE(SUM(Amount), 0) as total FROM Transactions WHERE Transaction_Type = ?',
          variables: const [Variable<String>('Active')],
        )
        .get();

    return (rows.first.data['total'] as num).toDouble();
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

  static Future<List<Trx>> fetchTransactionsByDate({
    required String inputDate,
  }) async {
    try {
      final d = await db();
      final rows =
          await (d.select(d.transactionsTable)
                ..where((t) => t.transactionDate.equals(inputDate))
                ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
              .get();
      return rows.map(_trxFromRow).toList();
    } on SqliteException catch (e) {
      throw Exception('Database error while fetching transactions: $e');
    } catch (e) {
      throw Exception('Failed to fetch transactions by date: $e');
    }
  }

  static Future<List<Trx>> fetchTransactionsByAge({required int months}) async {
    if (![1, 3, 6, 12].contains(months)) {
      throw ArgumentError('Months must be one of: 1, 3, 6, or 12');
    }

    try {
      final d = await db();
      final now = DateTime.now();
      final cutoffDate = DateTime(now.year, now.month - months, now.day);
      final cutoffDateStr = DateFormat('yyyy-MM-dd').format(cutoffDate);

      final List<QueryRow> rows = await d
          .customSelect(
            '''
        SELECT * FROM Transactions
        WHERE substr(Transaction_Date, 7, 4) || '-' ||
              substr(Transaction_Date, 4, 2) || '-' ||
              substr(Transaction_Date, 1, 2) < ?
        ORDER BY substr(Transaction_Date, 7, 4) DESC,
                 substr(Transaction_Date, 4, 2) DESC,
                 substr(Transaction_Date, 1, 2) DESC
        ''',
            variables: [Variable<String>(cutoffDateStr)],
            readsFrom: {d.transactionsTable},
          )
          .get();

      return Trx.toList(rows.map((r) => r.data).toList());
    } on SqliteException catch (e) {
      throw Exception('Database error while fetching transactions: $e');
    } catch (e) {
      throw Exception('Failed to fetch transactions by age: $e');
    }
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

        // Delete signature file (same behavior as old code).
        if (trxRow.signature.isNotEmpty) {
          final f = File(trxRow.signature);
          if (await f.exists()) {
            await f.delete();
          }
        }
        final historyDeleted = await (d.delete(
          d.historyTable,
        )..where((h) => h.transactionId.equals(transactionId))).go();

        // Delete transaction (payments cascade).
        final txnDeleted = await (d.delete(
          d.transactionsTable,
        )..where((t) => t.transactionId.equals(transactionId))).go();

        // Delete item row (and item photo file) like your sqflite code.
        final itemRow =
            await (d.select(d.itemsTable)
                  ..where((i) => i.itemId.equals(trxRow.itemId))
                  ..limit(1))
                .getSingleOrNull();

        int itemDeleted = 0;
        if (itemRow != null) {
          if (itemRow.itemPhoto.isNotEmpty) {
            final f = File(itemRow.itemPhoto);
            if (await f.exists()) {
              await f.delete();
            }
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

  //// P A Y M E N T S

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

  //// H I S T O R Y

  static Future<List<UserHistory>> fetchAllUserHistory() async {
    final d = await db();
    final rows = await (d.select(
      d.historyTable,
    )..orderBy([(t) => OrderingTerm.desc(t.eventDate)])).get();

    return rows
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
        .toList();
  }

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

  static Future<int> deleteHistory({required int transactionId}) async {
    final d = await db();
    try {
      return await d.transaction(() async {
        final deleted = await (d.delete(
          d.historyTable,
        )..where((t) => t.transactionId.equals(transactionId))).go();
        return deleted;
      });
    } catch (e) {
      throw Exception('Database error while deleting history: $e');
    }
  }

  //// D A T A B A S E   M A N A G E M E N T

  // ---------------------------------------------------------------------------
  // STREAMS (reactive reads)
  // ---------------------------------------------------------------------------

  //// C U S T O M E R S (streams)

  static Stream<List<Customer>> watchAllCustomerData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q = (d.select(
        d.customersTable,
      )..orderBy([(t) => OrderingTerm.asc(t.customerName)])).watch();

      return q.map(
        (List<CustomerRow> rows) => rows
            .map(
              (CustomerRow r) => Customer(
                id: r.customerId,
                userID: r.userId,
                name: r.customerName,
                guardianName: r.gaurdianName,
                address: r.customerAddress,
                number: r.contactNumber,
                photo: r.customerPhoto,
                proof: r.proofPhoto,
                createdDate: r.createdDate,
              ),
            )
            .toList(),
      );
    });
  }

  static Stream<List<String>> watchAllCustomerNumbers() {
    return Stream.fromFuture(db()).asyncExpand((ItDataDatabase d) {
      final Stream<List<TypedResult>> q =
          (d.selectOnly(d.customersTable)
                ..addColumns([d.customersTable.contactNumber])
                ..orderBy([OrderingTerm.asc(d.customersTable.contactNumber)]))
              .watch();

      return q.map(
        (List<TypedResult> rows) =>
            rows.map((r) => r.read(d.customersTable.contactNumber)!).toList(),
      );
    });
  }

  static Stream<List<Contact>> watchAllCustomerNumbersWithNames() {
    return Stream.fromFuture(db()).asyncExpand((ItDataDatabase d) {
      final Stream<List<TypedResult>> q =
          (d.selectOnly(d.customersTable)
                ..addColumns([
                  d.customersTable.customerId,
                  d.customersTable.customerName,
                  d.customersTable.contactNumber,
                ])
                ..orderBy([OrderingTerm.asc(d.customersTable.customerName)]))
              .watch();

      return q.map((List<TypedResult> rows) {
        return rows
            .map(
              (TypedResult r) => Contact(
                name: r.read(d.customersTable.customerName) ?? '',
                number: r.read(d.customersTable.contactNumber) ?? '',
                id: r.read(d.customersTable.customerId) ?? 0,
              ),
            )
            .toList();
      });
    });
  }

  static Stream<String> watchRequriedCustomerName({required int customerId}) {
    return Stream.fromFuture(db()).asyncExpand((ItDataDatabase d) {
      final Stream<List<TypedResult>> q =
          (d.selectOnly(d.customersTable)
                ..addColumns([d.customersTable.customerName])
                ..where(d.customersTable.customerId.equals(customerId))
                ..limit(1))
              .watch();

      return q.map(
        (List<TypedResult> rows) => rows.isEmpty
            ? ''
            : (rows.first.read(d.customersTable.customerName) ?? ''),
      );
    });
  }

  static Stream<Customer?> watchSingleCustomer({required int id}) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final Stream<List<CustomerRow>> q =
          (d.select(d.customersTable)
                ..where((t) => t.customerId.equals(id))
                ..limit(1))
              .watch();

      return q.map((rows) {
        if (rows.isEmpty) return null;
        final r = rows.first;
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

  //// I T E M S (streams)

  static Stream<List<Items>> watchAllItems() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q = (d.select(
        d.itemsTable,
      )..orderBy([(t) => OrderingTerm.desc(t.createdDate)])).watch();

      return q.map(
        (rows) => rows
            .map(
              (r) => Items(
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
              ),
            )
            .toList(),
      );
    });
  }

  static Stream<List<Items>> watchitemOfRequriedCustomer({
    required int customerID,
  }) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.itemsTable)
                ..where((t) => t.customerId.equals(customerID))
                ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
              .watch();

      return q.map(
        (rows) => rows
            .map(
              (r) => Items(
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
              ),
            )
            .toList(),
      );
    });
  }

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

  //// T R A N S A C T I O N S (streams)

  static Stream<List<Trx>> watchAllTransactions() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q = (d.select(
        d.transactionsTable,
      )..orderBy([(t) => OrderingTerm.desc(t.transactionId)])).watch();
      return q.map((rows) => rows.map(_trxFromRow).toList());
    });
  }

  static Stream<List<Trx>> watchActiveTransactions() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.transactionsTable)
                ..where((t) => t.transactionType.equals('Active'))
                ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
              .watch();
      return q.map((rows) => rows.map(_trxFromRow).toList());
    });
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

  static Stream<double> watchSumOfTakenAmount() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q = d
          .customSelect(
            '''
        SELECT COALESCE(SUM(Amount), 0) AS total
        FROM Transactions
        ''',
            readsFrom: {d.transactionsTable},
          )
          .watch();

      return q.map((rows) {
        final num n = (rows.first.data['total'] as num?) ?? 0;
        return n.toDouble();
      });
    });
  }

  static Stream<List<Trx>> watchTransactionsByDate({
    required String inputDate,
  }) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.select(d.transactionsTable)
                ..where((t) => t.transactionDate.equals(inputDate))
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
      final cutoffDate = DateTime(now.year, now.month - months, now.day);
      final cutoffDateStr = DateFormat('yyyy-MM-dd').format(cutoffDate);

      final Stream<List<QueryRow>> q = d
          .customSelect(
            '''
        SELECT * FROM Transactions
        WHERE substr(Transaction_Date, 7, 4) || '-' ||
              substr(Transaction_Date, 4, 2) || '-' ||
              substr(Transaction_Date, 1, 2) < ?
        ORDER BY substr(Transaction_Date, 7, 4) DESC,
                 substr(Transaction_Date, 4, 2) DESC,
                 substr(Transaction_Date, 1, 2) DESC
        ''',
            variables: [Variable<String>(cutoffDateStr)],
            readsFrom: {d.transactionsTable},
          )
          .watch();

      return q.map((rows) => Trx.toList(rows.map((r) => r.data).toList()));
    });
  }

  //// P A Y M E N T S (streams)

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

  //// H I S T O R Y (streams)

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

  //// A N A L Y T I C S (streams)

  /// Reactive version of [fetchAnalyticsData].
  ///
  /// NOTE: The "outstandingAmount" is computed in Dart from active transactions.
  /// This stream will update whenever Customers / Transactions / Payments change.
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
              Variable<String>('Active'),
            ],
            readsFrom: {d.customersTable, d.transactionsTable, d.paymentsTable},
          )
          .watch();

      final activeTxns = (d.select(
        d.transactionsTable,
      )..where((t) => t.transactionType.equals('Active'))).watch();

      return _combineLatest2(base, activeTxns, (baseRows, activeRows) {
        final row = baseRows.first.data;

        double totalOutstanding = 0.0;
        for (final t in activeRows) {
          final principal = t.amount;
          final rate = t.interestRate;
          final takenDate = t.transactionDate;
          final l = LoanCalculator(
            takenAmount: principal,
            rateOfInterest: rate,
            takenDate: takenDate,
          );
          totalOutstanding += l.totalAmount;
        }

        return {
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

  /// Reactive version of [fetchMonthlyChartData] (last 6 months).
  /// Recomputes when Transactions or Payments change.
  static Stream<List<Map<String, dynamic>>> watchMonthlyChartData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final txns = (d.select(d.transactionsTable)).watch();
      final pays = (d.select(d.paymentsTable)).watch();

      return _combineLatest2(txns, pays, (_, _) => 0).asyncMap((_) async {
        return fetchMonthlyChartData();
      });
    });
  }

  static Future<void> close() async {
    final d = _db;
    if (d == null) return;
    await d.close();
    _db = null;
  }

  static Future<String> backupDatabase() async {
    final d = await db();
    final File dbFile = await d.dbFile;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory backupDir = Directory(p.join(appDocDir.path, 'backups'));
    await backupDir.create(recursive: true);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupPath = p.join(backupDir.path, 'backup_$timestamp.db');

    await dbFile.copy(backupPath);
    return backupPath;
  }

  static Future<int> getDatabaseSize() async {
    final d = await db();
    final File file = await d.dbFile;
    return file.length();
  }

  static Future<void> vacuumDatabase() async {
    final d = await db();
    await d.customStatement('VACUUM');
  }

  static Future<bool> checkDatabaseIntegrity() async {
    final d = await db();
    final rows = await d.customSelect('PRAGMA integrity_check').get();
    return rows.isNotEmpty && rows.first.data['integrity_check'] == 'ok';
  }

  //// A N A L Y T I C S

  static Future<Map<String, num>> fetchAnalyticsData() async {
    final d = await db();

    final rows = await d
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
            Variable<String>('Inactive'),
          ],
        )
        .get();

    final row = rows.first.data;

    // Outstanding amount uses your existing LoanCalculator logic.
    final activeTxns = await (d.select(
      d.transactionsTable,
    )..where((t) => t.transactionType.equals('Active'))).get();

    double totalOutstanding = 0.0;
    for (final t in activeTxns) {
      final principal = t.amount;
      final rate = t.interestRate;
      final takenDate = t.transactionDate;
      final l = LoanCalculator(
        takenAmount: principal,
        rateOfInterest: rate,
        takenDate: takenDate,
      );
      totalOutstanding += l.totalAmount;
    }

    return {
      'totalCustomers': (row['totalCustomers'] as num?) ?? 0,
      'activeLoans': (row['activeLoans'] as num?) ?? 0,
      'outstandingAmount': totalOutstanding,
      'interestEarned': (row['interestEarned'] as num?) ?? 0,
      'totalDisbursed': (row['totalDisbursed'] as num?) ?? 0,
      'paymentsReceived': (row['paymentsReceived'] as num?) ?? 0,
    };
  }

  static Future<List<Map<String, dynamic>>> fetchMonthlyChartData() async {
    final d = await db();
    final now = DateTime.now();
    final List<Map<String, dynamic>> results = [];

    for (int i = 5; i >= 0; i--) {
      final DateTime date = DateTime(now.year, now.month - i, 1);
      final String monthStr = DateFormat('MMM').format(date);
      final int year = date.year;
      final String month = date.month.toString().padLeft(2, '0');

      final List<QueryRow> disbursedRows = await d
          .customSelect(
            '''
        SELECT COALESCE(SUM(Amount), 0) as total
        FROM Transactions
        WHERE substr(Transaction_Date, 4, 2) = ?
          AND substr(Transaction_Date, 7, 4) = ?
        ''',
            variables: [
              Variable<String>(month),
              Variable<String>(year.toString()),
            ],
          )
          .get();

      final receivedRows = await d
          .customSelect(
            '''
        SELECT COALESCE(SUM(Amount_Paid), 0) as total
        FROM Payments
        WHERE substr(Payment_Date, 1, 7) = ?
        ''',
            variables: [Variable<String>('$year-$month')],
          )
          .get();

      results.add({
        'month': monthStr,
        'disbursed': (disbursedRows.first.data['total'] as num).toDouble(),
        'received': (receivedRows.first.data['total'] as num).toDouble(),
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
}
