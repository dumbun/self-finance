import 'package:path_provider/path_provider.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:sqflite/sqflite.dart' as sql;

class BackEnd {
  static Future<void> createTable(sql.Database database) async {
    //// create new customerSTable
    await database.execute("""

        CREATE TABLE "CUSTOMERS" (
        CUST_ID INTEGER PRIMARY KEY AUTOINCREMENT, 
        MOBILE_NUMBER INTEGER NOT NULL, 
        ADDRESS TEXT NOT NULL, 
        CUSTOMER_NAME TEXT NOT NULL, 
        GUARDIAN_NAME TEXT NOT NULL, 
        PHOTO_CUSTOMER TEXT, 
        CREATED_DATE CURRENT_TIMESTAMP NOT NULL
        )
      
      """);

    //// make the Unique index
    await database.execute("""

        CREATE UNIQUE INDEX pk_cust_index ON "CUSTOMERS"("MOBILE_NUMBER")

      """);

    //// creates a new Transactions table
    await database.execute("""

        CREATE TABLE TRANSACTIONS (       
        TRAN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        CUST_ID INTEGER NOT NULL,
        TAKEN_DATE TIMESTAMP NOT NULL ,
        TAKEN_AMOUNT INTEGER NOT NULL ,
        RATE_OF_INTEREST DOUBLE NOT NULL ,
        ITEM_NAME TEXT NOT NULL ,
        TRANSACTION_TYPE  INTEGER NOT NULL ,
        PAID_DATE TEXT,
        VIA  TEXT,
        PAID_AMOUNT DOUBLE ,
        TOTAL_INTREST DOUBLE,
        DUE_TIME  TEXT,
        PHOTO_PROOF TEXT,
        PHOTO_ITEM TEXT,
        CREATED_DATE CURRENT_TIMESTAMP NOT NULL, 
        FOREIGN KEY (CUST_ID) REFERENCES CUSTOMERS(CUST_ID) 

      )""");

    //// CREATE A TRANSACTION HISTORY TABLE WHERE IT WILL STORE ALL THE TRANSACTIONS
    await database.execute("""

      CREATE TABLE USER_HISTORY(
      CUST_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      MOBILE_NUMBER INTEGER NOT NULL,
      ADDRESS TEXT NOT NULL,
      CUSTOMER_NAME TEXT NOT NULL,
      GUARDIAN_NAME TEXT NOT NULL,
      TAKEN_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      TAKEN_AMOUNT INT NOT NULL,
      RATE_OF_INTEREST DOUBLE NOT NULL,
      ITEM_NAME TEXT NOT NULL,
      TRANSACTION_TYPE INT NOT NULL,
      PAID_DATE TEXT,
      VIA TEXT,
      PAID_AMOUNT DOUBLE,
      TOTAL_INTREST DOUBLE,
      DUE_TIME TEXT,
      PHOTO_PROOF TEXT NOT NULL,
      PHOTO_ITEM TEXT NOT NULL,
      PHOTO_CUSTOMER TEXT NOT NULL


    )""");

    //// create the qnique key
    await database.execute("""

      CREATE UNIQUE INDEX pk_trans_index ON "TRANSACTIONS"("TRAN_ID","CUST_ID")

    """);

    //// turns on foreign key
    await database.execute("""

      PRAGMA foreign_keys = ON

    """);
  }

  // by providing the path the data will store in that path whene it reinstall app data will be safe

  static Future<sql.Database> db() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/itdata.db';
    return sql.openDatabase(path, version: 1, onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

  // create new customer entry

  static Future<int> createNewCustomer(Customer customer) async {
    final db = await BackEnd.db();

    final data = {
      "MOBILE_NUMBER": customer.mobileNumber,
      "ADDRESS": customer.address,
      "CUSTOMER_NAME": customer.customerName,
      "GUARDIAN_NAME": customer.guardianName,
      "PHOTO_CUSTOMER": customer.photoCustomer ?? "",
      "CREATED_DATE": DateTime.now().toString(),
    };
    final id = await db.insert('CUSTOMERS', data);
    if (id != 0) {
      return id;
    } else {
      return id;
    }
  }

  ///[createNewTransaction] creates a new transaction in the DataBase
  static Future<int> createNewTransaction(TransactionsHistory transacrtion) async {
    final db = await BackEnd.db();
    try {
      final data = {
        "CUST_ID": transacrtion.custId,
        "TAKEN_DATE": transacrtion.takenDate,
        "TAKEN_AMOUNT": transacrtion.takenAmount,
        "RATE_OF_INTEREST": transacrtion.rateOfInterest,
        "ITEM_NAME": transacrtion.itemName,
        "TRANSACTION_TYPE": transacrtion.transactionType,
        "PAID_DATE": transacrtion.paidDate,
        "VIA": transacrtion.via,
        "PAID_AMOUNT": transacrtion.paidAmount,
        "TOTAL_INTREST": transacrtion.totalIntrest,
        "DUE_TIME": transacrtion.dueTime,
        "PHOTO_ITEM": transacrtion.photoItem ?? "",
        "PHOTO_PROOF": transacrtion.photoProof ?? "",
        "CREATED_DATE": DateTime.now().toString(),
      };

      final id = await db.insert('TRANSACTIONS', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// [fetchLatestTransactions] : get latest
  /// Transactions of all customers from the TRANSACTIONS Tables without Customers
  static Future<List<TransactionsHistory>> fetchLatestTransactions() async {
    final db = await BackEnd.db();
    List<Map<String, Object?>> result = await db.rawQuery("""
      SELECT * FROM TRANSACTIONS ORDER BY TAKEN_DATE 
    """);
    if (result.isNotEmpty) {
      return TransactionsHistory.toList(result);
    } else {
      return [];
    }
  }

  /// [fetchUserHistory] fetch user history
  static Future<List<UserHistory>> fetchUserHistory() async {
    final db = await BackEnd.db();
    try {
      List<Map<String, Object?>> response = await db.rawQuery("""
          SELECT * FROM USER_HISTORY
          """);
      return UserHistory.toList(response);
    } catch (e) {
      print(e);
      return [];
    }
  }

  // get called first  app lunches or reload app

  static Future<List<Customer>> fetchAllCustomersData() async {
    final db = await BackEnd.db();

    try {
      final response = await db.query('CUSTOMERS', orderBy: 'CUST_ID');
      final List<Customer> result = Customer.toList(response);
      print("resumt $result");
      return result;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// [fetchAllCustomersWithTransactions] fetchs the all users with there transactions from the Db
  List<Map<Customer, List<TransactionsHistory>>> fetchAllCustomersWithTransactions() {
    //todo write a query to fetch the all users with there transactions from the Db and map them
    //todo and list this them
    return List.empty();
  }

  /// [getCustomerEntriesByMobileNumber] get the entry by mobile number
  static Future<List<Map<String, dynamic>>> getCustomerEntriesByMobileNumber(String mobileNumber, int transfer) async {
    final db = await BackEnd.db();

    return db.query(
      'CUSTOMERS',
      orderBy: 'ID',
      where: "MOBILE_NUMBER = ? and TRANSFER = ?",
      whereArgs: [mobileNumber, transfer],
    );
  }
  // get the transaction by mobile number

  static Future<List<TransactionsHistory>> getTransactionsEntriesByMobileNumber(String mobileNumber) async {
    final db = await BackEnd.db();
    final List<Map<String, Object?>> data = await db.query(
      'TRANSACTIONS',
      orderBy: 'ID',
      where: "MOBILE_NUMBER = ?",
      whereArgs: [mobileNumber],
    );
    List<TransactionsHistory> result = TransactionsHistory.toList(data);
    if (result.isNotEmpty) {
      return result;
    } else {
      return [];
    }
  }

  // get the transaction by Customer Name

  static Future<List<TransactionsHistory>> getTransactionsEntriesByCustomerName(String name) async {
    final db = await BackEnd.db();
    final List<Map<String, Object?>> data = await db.query(
      'TRANSACTIONS',
      orderBy: 'ID',
      where: "CUSTOMER_NAME = ?",
      whereArgs: [name],
    );
    List<TransactionsHistory> result = TransactionsHistory.toList(data);
    if (result.isNotEmpty) {
      return result;
    } else {
      return [];
    }
  }

  // Update the item

  static Future<int> updateCustomerStatus(int id, int code) async {
    final db = await BackEnd.db();
    final data = {'TRANSFER': code, 'PAID_DATE': DateTime.now().toString()};
    final result = await db.update('CUSTOMERS', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete entry

  static Future<bool> deleteItem(int id) async {
    final db = await BackEnd.db();
    try {
      await db.delete('CUSTOMERS', where: "id = ?", whereArgs: [id]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // fetch the all paid transctions

  static Future<List<Map<String, dynamic>>> fetchAllPaidTransactions() async {
    final db = await BackEnd.db();
    return db.query("CUSTOMERS", where: "TRANSFER = ?", whereArgs: [2]);
  }

  // fetch the paid transactions of a requried number

  static Future<List<Map<String, dynamic>>> fetchThisNumberPaidTransactions(String mobileNumber) async {
    final db = await BackEnd.db();
    return db.query("CUSTOMERS", where: "MOBILE_NUMBER = ? and TRANSFER = ?", whereArgs: [mobileNumber, 2]);
  }

  // fetch the paid transactions of a requried number

  static Future<List<Customer>> fetchThisIDPaidTransactions(String mobileNumber) async {
    final db = await BackEnd.db();
    List<Customer> data = Customer.toList(
      await db.query("CUSTOMERS", where: "MOBILE_NUMBER = ? and TRANSFER = ?", whereArgs: [mobileNumber, 2]),
    );
    return data;
  }

  // // fetch the latest transactions

  // static Future<List<Customer>> fetchLatestTransactions() async {
  //   final db = await BackEnd.db();
  //   List<Map<String, Object?>> result = await db.rawQuery("""
  //     SELECT * FROM CUSTOMERS ORDER BY ID DESC
  //   """);
  //   if (result.isNotEmpty) {
  //     return Customer.toList(result);
  //   } else {
  //     return [];
  //   }
  // }

  //todo  total amount querys

  // total ammmountInvested present
  static Future<int> fetchUserPresentInvestedAmount() async {
    final db = await BackEnd.db();
    List<Map<String, Object?>> result = await db.rawQuery("""
    SELECT SUM(TAKEN_AMOUNT) FROM CUSTOMERS WHERE TRANSFER = 1
    """);
    if (result[0]["SUM(TAKEN_AMOUNT)"] != null) {
      int finalResut = (result[0]["SUM(TAKEN_AMOUNT)"]) as int;
      return finalResut;
    } else {
      return 0;
    }
  }

  // close a data base

  Future<bool> close() async {
    final db = await BackEnd.db();
    await db.close();
    return true;
  }
}
