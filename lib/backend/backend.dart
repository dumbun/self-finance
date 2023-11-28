import 'package:path_provider/path_provider.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart' as sql;

class BackEnd {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE CUSTOMERS(
      ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      MOBILE_NUMBER TEXT NOT NULL,
      ADDRESS TEXT NOT NULL,
      CUSTOMER_NAME TEXT NOT NULL,
      GUARDIAN_NAME TEXT NOT NULL,
      TAKEN_AMOUNT INT NOT NULL,
      RATE_OF_INTEREST DOUBLE NOT NULL,
      TAKEN_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      ITEM_NAME TEXT NOT NULL,
      TRANSFER INT NOT NULL,
      PHOTO_PROOF TEXT NOT NULL,
      PHOTO_ITEM TEXT NOT NULL,
      PHOTO_CUSTOMER TEXT NOT NULL,
      PAID_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
    await database.execute("""CREATE TABLE TRANSACTIONS(
      ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      MOBILE_NUMBER TEXT NOT NULL,
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

  static Future<bool> createNewEntry(Customer customer) async {
    final db = await BackEnd.db();
    try {
      final data = {
        "MOBILE_NUMBER": customer.mobileNumber,
        "ADDRESS": customer.address,
        "CUSTOMER_NAME": customer.customerName,
        "GUARDIAN_NAME": customer.guardianName,
        "TAKEN_DATE": customer.takenDate,
        "TAKEN_AMOUNT": customer.takenAmount,
        "RATE_OF_INTEREST": customer.rateOfInterest,
        "ITEM_NAME": customer.itemName,
        "TRANSFER": customer.transaction,
        "PHOTO_CUSTOMER": customer.photoCustomer,
        "PHOTO_ITEM": customer.photoItem,
        "PHOTO_PROOF": customer.photoProof,
      };
      final id = await db.insert('CUSTOMERS', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
      if (id == 0) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  //create new transaction

  static Future<bool> createNewTransaction(Transactions transacrtion) async {
    final db = await BackEnd.db();
    try {
      final data = {
        "MOBILE_NUMBER": transacrtion.mobileNumber,
        "ADDRESS": transacrtion.address,
        "CUSTOMER_NAME": transacrtion.customerName,
        "GUARDIAN_NAME": transacrtion.guardianName,
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
        "PHOTO_CUSTOMER": transacrtion.photoCustomer,
        "PHOTO_ITEM": transacrtion.photoItem,
        "PHOTO_PROOF": transacrtion.photoProof,
      };

      final id = await db.insert('TRANSACTIONS', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
      if (id == 0) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  // get latest Transaction

  static Future<List<Transactions>> fetchLatestTransactions() async {
    final db = await BackEnd.db();
    List<Map<String, Object?>> result = await db.rawQuery("""
      SELECT * FROM TRANSACTIONS ORDER BY TAKEN_DATE 
    """);
    if (result.isNotEmpty) {
      return Transactions.toList(result);
    } else {
      return [];
    }
  }

  // get called first  app lunches or reload app

  static Future<List<Map<String, dynamic>>> fetchAllData() async {
    final db = await BackEnd.db();
    return db.query('CUSTOMERS', orderBy: 'ID');
  }

  // get the entry by mobile number

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

  static Future<List<Transactions>> getTransactionsEntriesByMobileNumber(String mobileNumber) async {
    final db = await BackEnd.db();
    final List<Map<String, Object?>> data = await db.query(
      'TRANSACTIONS',
      orderBy: 'ID',
      where: "MOBILE_NUMBER = ?",
      whereArgs: [mobileNumber],
    );
    List<Transactions> result = Transactions.toList(data);
    if (result.isNotEmpty) {
      return result;
    } else {
      return [];
    }
  }
  // get the transaction by Customer Name

  static Future<List<Transactions>> getTransactionsEntriesByCustomerName(String name) async {
    final db = await BackEnd.db();
    final List<Map<String, Object?>> data = await db.query(
      'TRANSACTIONS',
      orderBy: 'ID',
      where: "CUSTOMER_NAME = ?",
      whereArgs: [name],
    );
    List<Transactions> result = Transactions.toList(data);
    if (result.isNotEmpty) {
      return result;
    } else {
      return [];
    }
  }

  // Update the item

  static Future<int> updateTransactionStatus(int id, int code) async {
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
        db.query("CUSTOMERS", where: "MOBILE_NUMBER = ? and TRANSFER = ?", whereArgs: [mobileNumber, 2]));
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
