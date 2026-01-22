import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class BackEnd {
  static Database? _database;
  static const String _databaseName = 'itdata.db';
  static const int _databaseVersion = 1;

  /// Singleton database instance with proper connection management
  static Future<Database> db() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    final String databasePath = await _getDatabasePath();

    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onOpen: _onOpen,
    );

    return _database!;
  }

  /// Get platform-specific database path
  static Future<String> _getDatabasePath() async {
    if (Platform.isIOS) {
      // iOS: Use app documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory dbDir = Directory(p.join(appDocDir.path, 'databases'));
      await dbDir.create(recursive: true);
      return p.join(dbDir.path, _databaseName);
    } else {
      // Android and others: Use standard database path
      final String databasePath = await getDatabasesPath();
      return p.join(databasePath, _databaseName);
    }
  }

  /// Configure database settings before opening
  static Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.rawQuery('PRAGMA foreign_keys = ON');
    // Enable Write-Ahead Logging for better concurrency
    await db.rawQuery('PRAGMA journal_mode = WAL');
    // Increase cache size for better performance
    await db.rawQuery('PRAGMA cache_size = 10000');
  }

  /// Called when database is opened
  static Future<void> _onOpen(Database db) async {
    // Verify foreign keys are enabled
    final result = await db.rawQuery('PRAGMA foreign_keys');
    if (result.isEmpty || result.first['foreign_keys'] != 1) {
      throw Exception('Failed to enable foreign keys');
    }
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // Customers Table with proper constraints
      await txn.execute("""
        CREATE TABLE Customers (
          User_ID          INTEGER NOT NULL,
          Customer_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
          Customer_Name    TEXT NOT NULL CHECK(length(trim(Customer_Name)) > 0),
          Gaurdian_Name    TEXT NOT NULL CHECK(length(trim(Gaurdian_Name)) > 0),
          Customer_Address TEXT NOT NULL CHECK(length(trim(Customer_Address)) > 0),
          Contact_Number   TEXT UNIQUE NOT NULL CHECK(length(Contact_Number) >= 10),
          Customer_Photo   TEXT NOT NULL,
          Proof_Photo      TEXT NOT NULL,
          Created_Date     TEXT NOT NULL,
          Updated_Date     TEXT DEFAULT NULL
        )
      """);

      // Items Table with cascading deletes
      await txn.execute("""
        CREATE TABLE Items (
          Item_ID          INTEGER PRIMARY KEY AUTOINCREMENT,
          Customer_ID      INTEGER NOT NULL,
          Item_Name        TEXT NOT NULL CHECK(length(trim(Item_Name)) > 0),
          Item_Description TEXT NOT NULL,
          Pawned_Date      TEXT NOT NULL,
          Expiry_Date      TEXT NOT NULL,
          Pawn_Amount      REAL NOT NULL CHECK(Pawn_Amount > 0),
          Item_Status      TEXT NOT NULL,
          Item_Photo       TEXT NOT NULL,
          Created_Date     TEXT NOT NULL,
          Updated_Date     TEXT DEFAULT NULL,
          FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE
        )
      """);

      // Transactions Table with cascading deletes
      await txn.execute("""
        CREATE TABLE Transactions (
          Transaction_ID   INTEGER PRIMARY KEY AUTOINCREMENT,
          Customer_ID      INTEGER NOT NULL,
          Item_ID          INTEGER NOT NULL,
          Transaction_Date TEXT NOT NULL,
          Transaction_Type TEXT NOT NULL,
          Amount           REAL NOT NULL,
          Interest_Rate    REAL NOT NULL,
          Interest_Amount  REAL NOT NULL,
          Remaining_Amount REAL NOT NULL,
          Signature        TEXT NOT NULL,
          Created_Date     TEXT NOT NULL,
          Updated_Date     TEXT DEFAULT NULL,
          FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE,
          FOREIGN KEY (Item_ID) REFERENCES Items(Item_ID) ON DELETE CASCADE
        )
      """);

      // Payments Table with cascading deletes
      await txn.execute("""
        CREATE TABLE Payments (
          Payment_ID       INTEGER PRIMARY KEY AUTOINCREMENT,
          Transaction_ID   INTEGER NOT NULL,
          Payment_Date     TEXT NOT NULL,
          Amount_Paid      REAL NOT NULL CHECK(Amount_Paid > 0),
          Payment_Type     TEXT NOT NULL,
          Created_Date     TEXT NOT NULL,
          FOREIGN KEY (Transaction_ID) REFERENCES Transactions(Transaction_ID) ON DELETE CASCADE
        )
      """);

      // History Table with cascading deletes
      await txn.execute("""
        CREATE TABLE History (
          History_ID       INTEGER PRIMARY KEY AUTOINCREMENT,
          User_ID          INTEGER NOT NULL,
          Customer_ID      INTEGER NOT NULL,
          Customer_Name    TEXT NOT NULL,
          Contact_Number   TEXT NOT NULL,
          Item_ID          INTEGER NOT NULL,
          Transaction_ID   INTEGER NOT NULL,
          Amount           REAL NOT NULL,
          Event_Date       TEXT NOT NULL,
          Event_Type       TEXT NOT NULL,
          FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE
        )
      """);

      // Create indexes for better query performance
      await txn.execute(
        'CREATE INDEX idx_customer_contact ON Customers(Contact_Number)',
      );
      await txn.execute(
        'CREATE INDEX idx_items_customer ON Items(Customer_ID)',
      );
      await txn.execute('CREATE INDEX idx_items_status ON Items(Item_Status)');
      await txn.execute(
        'CREATE INDEX idx_transactions_customer ON Transactions(Customer_ID)',
      );
      await txn.execute(
        'CREATE INDEX idx_transactions_item ON Transactions(Item_ID)',
      );
      await txn.execute(
        'CREATE INDEX idx_transactions_type ON Transactions(Transaction_Type)',
      );
      await txn.execute(
        'CREATE INDEX idx_payments_transaction ON Payments(Transaction_ID)',
      );
      await txn.execute(
        'CREATE INDEX idx_history_customer ON History(Customer_ID)',
      );
      await txn.execute('CREATE INDEX idx_history_date ON History(Event_Date)');
    });
  }

  //// C U S T O M E R S

  /// Create new customer entry with validation
  static Future<int> createNewCustomer(Customer customer) async {
    if (customer.name.trim().isEmpty) {
      throw ArgumentError('Customer name cannot be empty');
    }
    if (customer.number.trim().length < 10) {
      throw ArgumentError('Invalid contact number');
    }

    try {
      final Database db = await BackEnd.db();
      final int id = await db.insert('Customers', {
        "User_ID": customer.userID,
        "Customer_Name": customer.name.trim(),
        "Gaurdian_Name": customer.guardianName.trim(),
        "Customer_Address": customer.address.trim(),
        "Contact_Number": customer.number.trim(),
        "Customer_Photo": customer.photo,
        "Proof_Photo": customer.proof,
        "Created_Date": customer.createdDate,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      return id;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Contact number already exists');
      }
      rethrow;
    }
  }

  /// Fetch all customer data
  static Future<List<Customer>> fetchAllCustomerData() async {
    final Database db = await BackEnd.db();
    final response = await db.query('Customers', orderBy: 'Customer_Name ASC');
    return Customer.toList(response);
  }

  /// Fetch all customer numbers
  static Future<List<String>> fetchAllCustomerNumbers() async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Customers',
      columns: ['Contact_Number'],
      orderBy: 'Contact_Number ASC',
    );
    return response.map((e) => e['Contact_Number'] as String).toList();
  }

  /// Fetch all customer numbers with names
  static Future<List<Contact>> fetchAllCustomerNumbersWithNames() async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Customers',
      columns: ['Customer_ID', 'Customer_Name', 'Contact_Number'],
      orderBy: 'Customer_Name ASC',
    );
    return Contact.toList(response);
  }

  /// Fetch required customer name
  static Future<String> fetchRequriedCustomerName(int id) async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Customers',
      columns: ['Customer_Name'],
      where: 'Customer_ID = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (response.isEmpty) {
      throw Exception('Customer not found');
    }

    return response.first['Customer_Name'] as String;
  }

  /// Fetch single contact details
  static Future<List<Customer>> fetchSingleContactDetails({
    required int id,
  }) async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Customers',
      where: 'Customer_ID = ?',
      whereArgs: [id],
      limit: 1,
    );
    return Customer.toList(response);
  }

  /// Delete customer with cascade (transactional)
  static Future<void> deleteTheCustomer({required int customerID}) async {
    final Database db = await BackEnd.db();

    await db.transaction((txn) async {
      // With CASCADE DELETE enabled, this will automatically delete:
      // - All items for this customer
      // - All transactions for this customer
      // - All payments for those transactions
      // - All history for this customer
      await txn.delete(
        'Customers',
        where: 'Customer_ID = ?',
        whereArgs: [customerID],
      );
    });
  }

  /// Update customer details with validation
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

    final Database db = await BackEnd.db();

    return await db.transaction((txn) async {
      // Update customer
      final count = await txn.update(
        'Customers',
        {
          'Customer_Name': newCustomerName.trim(),
          'Gaurdian_Name': newGuardianName.trim(),
          'Customer_Address': newCustomerAddress.trim(),
          'Contact_Number': newContactNumber.trim(),
          'Customer_Photo': newCustomerPhoto,
          'Proof_Photo': newProofPhoto,
          'Created_Date': newCreatedDate,
          'Updated_Date': DateTime.now().toIso8601String(),
        },
        where: 'Customer_ID = ?',
        whereArgs: [customerId],
      );

      // Update history records
      await txn.update(
        'History',
        {
          'Customer_Name': newCustomerName.trim(),
          'Contact_Number': newContactNumber.trim(),
        },
        where: 'Customer_ID = ?',
        whereArgs: [customerId],
      );

      return count;
    });
  }

  //// I T E M S

  /// Create a new item with validation
  static Future<int> createNewItem(Items item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Item name cannot be empty');
    }
    if (item.pawnAmount <= 0) {
      throw ArgumentError('Pawn amount must be greater than 0');
    }

    final Database db = await BackEnd.db();
    final id = await db.insert('Items', {
      "Customer_ID": item.customerid,
      "Item_Name": item.name.trim(),
      "Item_Description": item.description.trim(),
      "Pawned_Date": item.pawnedDate,
      "Expiry_Date": item.expiryDate,
      "Pawn_Amount": item.pawnAmount,
      "Item_Status": item.status,
      "Item_Photo": item.photo,
      "Created_Date": item.createdDate,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
    return id;
  }

  /// Fetch all items
  static Future<List<Items>> fetchAllItems() async {
    final Database db = await BackEnd.db();
    final response = await db.query('Items', orderBy: 'Created_Date DESC');
    return Items.toList(response);
  }

  /// Fetch all items of a required customer
  static Future<List<Items>> fetchitemOfRequriedCustomer({
    required int customerID,
  }) async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Items',
      where: 'Customer_ID = ?',
      whereArgs: [customerID],
      orderBy: 'Created_Date DESC',
    );
    return Items.toList(response);
  }

  /// Fetch required item
  static Future<List<Items>> fetchRequriedItem({required int itemId}) async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Items',
      where: 'Item_ID = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    return Items.toList(response);
  }

  //// T R A N S A C T I O N S

  /// Create new transaction with validation
  static Future<int> createNewTransaction(Trx transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError('Transaction amount must be greater than 0');
    }
    if (transaction.intrestRate < 0) {
      throw ArgumentError('Interest rate cannot be negative');
    }

    final Database db = await BackEnd.db();

    final response = await db.insert('Transactions', {
      "Customer_ID": transaction.customerId,
      "Item_ID": transaction.itemId,
      "Transaction_Date": transaction.transacrtionDate,
      "Transaction_Type": transaction.transacrtionType,
      "Amount": transaction.amount,
      "Interest_Rate": transaction.intrestRate,
      "Interest_Amount": transaction.intrestAmount,
      "Remaining_Amount": transaction.remainingAmount,
      "Signature": transaction.signature,
      "Created_Date": transaction.createdDate,
    }, conflictAlgorithm: ConflictAlgorithm.abort);

    return response;
  }

  /// Fetch all transactions
  static Future<List<Trx>> fetchAllTransactions() async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Transactions',
      orderBy: 'Transaction_Date DESC',
    );
    return Trx.toList(response);
  }

  /// Fetch active transactions
  static Future<List<Trx>> fetchActiveTransactions() async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Transactions',
      where: 'Transaction_Type = ?',
      whereArgs: [Constant.active],
      orderBy: 'Transaction_Date DESC',
    );
    return Trx.toList(response);
  }

  /// Fetch required customer transactions
  static Future<List<Trx>> fetchRequriedCustomerTransactions({
    required int customerId,
  }) async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Transactions',
      where: 'Customer_ID = ?',
      whereArgs: [customerId],
      orderBy: 'Transaction_Date DESC',
    );
    return Trx.toList(response);
  }

  /// Fetch required transaction
  static Future<List<Trx>> fetchRequriedTransaction({
    required int transacrtionId,
  }) async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      'Transactions',
      where: 'Transaction_ID = ?',
      whereArgs: [transacrtionId],
      limit: 1,
    );
    return Trx.toList(response);
  }

  /// Fetch sum of taken amount
  static Future<double> fetchSumOfTakenAmount() async {
    final Database db = await BackEnd.db();
    final response = await db.rawQuery(
      'SELECT COALESCE(SUM(Amount), 0) as total FROM Transactions WHERE Transaction_Type = ?',
      [Constant.active],
    );
    return (response.first['total'] as num).toDouble();
  }

  /// Update transaction as paid
  static Future<int> updateTransactionAsPaid({required int id}) async {
    final Database db = await BackEnd.db();
    return await db.update(
      'Transactions',
      {
        'Transaction_Type': Constant.inactive,
        'Updated_Date': DateTime.now().toIso8601String(),
      },
      where: 'Transaction_ID = ?',
      whereArgs: [id],
    );
  }

  /// Fetch all transactions for a specific date
  /// [inputDate] - Date string in format 'DD-MM-YYYY' (e.g., '22-01-2026')
  /// Returns list of transactions for that specific date
  static Future<List<Trx>> fetchTransactionsByDate({
    required String inputDate,
  }) async {
    try {
      final Database db = await BackEnd.db();

      final List<Map<String, Object?>> response = await db.query(
        'Transactions',
        where: 'Transaction_Date = ?',
        whereArgs: [inputDate],
        orderBy: 'Created_Date DESC',
      );

      return Trx.toList(response);
    } on DatabaseException catch (e) {
      throw Exception(
        'Database error while fetching transactions: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Failed to fetch transactions by date: $e');
    }
  }

  /// [fetchTransactionsByAge] Fetches transactions older than specified months
  /// [months] - Number of months (1, 3, 6, or 12)
  /// Returns list of transactions that are older than the specified period
  static Future<List<Trx>> fetchTransactionsByAge({required int months}) async {
    if (![1, 3, 6, 12].contains(months)) {
      throw ArgumentError('Months must be one of: 1, 3, 6, or 12');
    }

    try {
      final Database db = await BackEnd.db();

      // Calculate the cutoff date (transactions older than this date)
      final DateTime now = DateTime.now();
      final DateTime cutoffDate = DateTime(
        now.year,
        now.month - months,
        now.day,
      );

      // Format as YYYY-MM-DD for SQL comparison
      final String cutoffDateStr = DateFormat('yyyy-MM-dd').format(cutoffDate);

      // Convert DD-MM-YYYY to YYYY-MM-DD in SQL for proper date comparison
      final List<Map<String, Object?>> response = await db.rawQuery(
        '''
      SELECT * FROM Transactions
      WHERE substr(Transaction_Date, 7, 4) || '-' || 
            substr(Transaction_Date, 4, 2) || '-' || 
            substr(Transaction_Date, 1, 2) < ?
      ORDER BY substr(Transaction_Date, 7, 4) DESC,
               substr(Transaction_Date, 4, 2) DESC,
               substr(Transaction_Date, 1, 2) DESC
      ''',
        [cutoffDateStr],
      );

      return Trx.toList(response);
    } on DatabaseException catch (e) {
      throw Exception(
        'Database error while fetching transactions: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Failed to fetch transactions by age: $e');
    }
  }

  //// P A Y M E N T S

  /// Fetch all payments of a transaction
  static Future<List<Payment>> fetchRequriedPaymentsOfTransaction({
    required int transactionId,
  }) async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.query(
      'Payments',
      where: 'Transaction_ID = ?',
      whereArgs: [transactionId],
      orderBy: 'Payment_Date DESC',
    );
    return Payment.toList(response);
  }

  /// Add payment with validation
  static Future<int> addPayment({required Payment payment}) async {
    if (payment.amountpaid <= 0) {
      throw ArgumentError('Payment amount must be greater than 0');
    }

    final Database db = await BackEnd.db();
    final int id = await db.insert('Payments', {
      "Transaction_ID": payment.transactionId,
      "Payment_Date": payment.paymentDate,
      "Amount_Paid": payment.amountpaid,
      "Payment_Type": payment.type,
      "Created_Date": payment.createdDate,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
    return id;
  }

  //// H I S T O R Y

  /// Fetch all user history
  static Future<List<UserHistory>> fetchAllUserHistory() async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.query(
      'History',
      orderBy: 'Event_Date DESC',
    );
    return UserHistory.toList(response);
  }

  /// Create new history entry
  static Future<int> createNewHistory(UserHistory history) async {
    final Database db = await BackEnd.db();
    final id = await db.insert('History', {
      "User_ID": history.userID,
      "Customer_ID": history.customerID,
      "Customer_Name": history.customerName,
      "Contact_Number": history.customerNumber,
      "Item_ID": history.itemID,
      "Transaction_ID": history.transactionID,
      "Amount": history.amount,
      "Event_Date": history.eventDate,
      "Event_Type": history.eventType,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
    return id;
  }

  /// Fetch all History for a specific date
  /// [inputDate] - Date string in format 'DD-MM-YYYY' (e.g., '22-01-2026')
  /// Returns list of transactions for that specific date
  static Future<List<UserHistory>> fetchHistoryByDate({
    required String inputDate,
  }) async {
    try {
      final Database db = await BackEnd.db();

      final List<Map<String, Object?>> response = await db.query(
        'History',
        where: 'Event_Date = ?',
        whereArgs: [inputDate],
        orderBy: 'Created_Date DESC',
      );

      return UserHistory.toList(response);
    } on DatabaseException catch (e) {
      throw Exception('Database error while fetching history: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch history by date: $e');
    }
  }

  //// D A T A B A S E   M A N A G E M E N T

  /// Safely close database connection
  static Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Backup database to a file
  static Future<String> backupDatabase() async {
    final Database db = await BackEnd.db();
    final dbPath = db.path;

    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDocDir.path, 'backups'));
    await backupDir.create(recursive: true);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupPath = p.join(backupDir.path, 'backup_$timestamp.db');

    await File(dbPath).copy(backupPath);
    return backupPath;
  }

  /// Get database file size
  static Future<int> getDatabaseSize() async {
    final Database db = await BackEnd.db();
    final file = File(db.path);
    return await file.length();
  }

  /// Vacuum database to optimize storage
  static Future<void> vacuumDatabase() async {
    final Database db = await BackEnd.db();
    await db.execute('VACUUM');
  }

  /// Check database integrity
  static Future<bool> checkDatabaseIntegrity() async {
    final Database db = await BackEnd.db();
    final result = await db.rawQuery('PRAGMA integrity_check');
    return result.isNotEmpty && result.first['integrity_check'] == 'ok';
  }
}
