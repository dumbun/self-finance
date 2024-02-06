import 'package:path_provider/path_provider.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

/*

Customers Table:

Customer_ID: Unique identifier for each customer (auto-incremented).
Customer_Name: Name of the customer (text, not null).
Guardian_Name: Name of the guardian (text, not null).
Customer_Address: Address of the customer (text, not null).
Contact_Number: Unique contact number for the customer (text, unique, not null).
Customer_Photo: Binary Large Object (BLOB) storing customer's photo (not null).
Proof_Photo: BLOB storing proof photo (not null).
Created_Date: Date when the record was created (text, not null).

Items Table:

Item_ID: Unique identifier for each item (auto-incremented).
Customer_ID: Foreign key referencing Customer_ID in Customers table.
Item_Name: Name of the item (text, not null).
Item_Description: Description of the item (text, not null).
Pawned_Date: Date when the item was pawned (text, not null).
Expiry_Date: Date when the pawn expires (text, not null).
Pawn_Amount: Pawn amount (real, not null).
Item_Status: Status of the item (text, not null).
Item_Photo: BLOB storing item's photo (not null).
Created_Date: Date when the record was created (text, not null).

Transactions Table:

Transaction_ID: Unique identifier for each transaction (auto-incremented).
Customer_ID: Foreign key referencing Customer_ID in Customers table.
Item_ID: Foreign key referencing Item_ID in Items table.
Transaction_Date: Date of the transaction (text, not null).
Transaction_Type: Type of the transaction (text, not null).
Amount: Transaction amount (real, not null).
Interest_Rate: Interest rate for the transaction (real, not null).
Interest_Amount: Amount of interest (real, not null).
Remaining_Amount: Remaining amount after payment (real, not null).
Created_Date: Date when the record was created (text, not null).

Payments Table:

Payment_ID: Unique identifier for each payment (auto-incremented).
Transaction_ID: Foreign key referencing Transaction_ID in Transactions table.
Payment_Date: Date of the payment (text, not null).
Amount_Paid: Amount paid in the payment (real, not null).
Payment_Type: Type of the payment (text, not null).
Created_Date: Date when the record was created (text, not null).

The PRAGMA foreign_keys = ON statement at the end is used to enable foreign key support in SQLite. This ensures referential integrity between tables using foreign keys.

*/

class BackEnd {
  static Future<void> createTable(sql.Database database) async {
    //// create [new tables]
    await database.execute("""
          -- Customers Table
          CREATE TABLE Customers (
          User_ID          INTEGER NOT NULL,
          Customer_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
          Customer_Name    TEXT NOT NULL,
          Gaurdian_Name    TEXT NOT NULL,
          Customer_Address TEXT NOT NULL,
          Contact_Number   TEXT UNIQUE NOT NULL,
          Customer_Photo   BLOB NOT NULL,
          Proof_Photo      BLOB NOT NULL,
          Created_Date     TEXT NOT NULL 
          );
      """);

    await database.execute("""
          -- Items Table
          CREATE TABLE Items (
          Item_ID          INTEGER PRIMARY KEY AUTOINCREMENT,
          Customer_ID      INTEGER REFERENCES Customers(Customer_ID),
          Item_Name        TEXT NOT NULL,
          Item_Description TEXT NOT NULL,
          Pawned_Date      TEXT NOT NULL,
          Expiry_Date      TEXT NOT NULL,
          Pawn_Amount      REAL NOT NULL,
          Item_Status      TEXT NOT NULL,
          Item_Photo       BLOB NOT NULL,
          Created_Date     TEXT NOT NULL
          );
        """);

    await database.execute("""
          -- Transactions Table
          CREATE TABLE Transactions (
          Transaction_ID   INTEGER PRIMARY KEY AUTOINCREMENT,
          Customer_ID      INTEGER REFERENCES Customers(Customer_ID),
          Item_ID          INTEGER REFERENCES Items(Item_ID),
          Transaction_Date TEXT NOT NULL,
          Transaction_Type TEXT NOT NULL,
          Amount           REAL NOT NULL,
          Interest_Rate    REAL NOT NULL,
          Interest_Amount  REAL NOT NULL,
          Remaining_Amount REAL NOT NULL,
          Created_Date     TEXT NOT NULL 
          );
        """);
    await database.execute("""
          -- Payments Table
          CREATE TABLE Payments (
          Payment_ID       INTEGER PRIMARY KEY AUTOINCREMENT,
          Transaction_ID   INTEGER REFERENCES Transactions(Transaction_ID),
          Payment_Date     TEXT NOT NULL,
          Amount_Paid      REAL NOT NULL,
          Payment_Type     TEXT NOT NULL,
          Created_Date     TEXT NOT NULL
          );
        """);
    await database.execute("""
          -- History Table
          CREATE TABLE History (
          Histoy_ID        INTEGER PRIMARY KEY AUTOINCREMENT,
          User_ID          INTEGER NOT NULL,
          Customer_ID      INTEGER NOT NULL,
          Customer_Name    TEXT NOT NULL,
          Contact_Number   TEXT NOT NULL,
          Item_ID          INTEGER NOT NULL,
          Transacrtion_ID  INTEGER NOT NULL,
          Amount           REAL NOT NULL,
          Event_Date       TEXT NOT NULL,
          Event_Type       TEXT NOT NULL
          );
        """);

    await database.execute("""
             PRAGMA foreign_keys = ON
        """);
  }

  // by providing the path the data will store in that path whene it reinstall app data will be safe

  static Future<sql.Database> db() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/itdata.db';
    // print(path);
    return sql.openDatabase(path, version: 1, onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

  //// C U S T O M E R S
  /// create new customer entry
  static Future<int> createNewCustomer(Customer customer) async {
    try {
      final db = await BackEnd.db();
      final Map<String, Object> data = {
        "User_ID": customer.userID,
        "Customer_Name": customer.name,
        "Gaurdian_Name": customer.guardianName,
        "Customer_Address": customer.address,
        "Contact_Number": customer.number,
        "Customer_Photo": customer.photo,
        "Proof_Photo": customer.proof,
        "Created_Date": customer.createdDate,
      };
      final int id = await db.insert('Customers', data, conflictAlgorithm: sql.ConflictAlgorithm.abort);
      return id;
    } catch (e) {
      return 0;
    }
  }

  /// fetch all customer data
  static Future<List<Customer>> fetchAllCustomerData() async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.rawQuery("""SELECT * FROM Customers""");
    return Customer.toList(response);
  }

  /// [fetchAllCustomerNumbers] fetch's the mobile numbers from the all customers
  static Future<List<String>> fetchAllCustomerNumbers() async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.rawQuery("""SELECT Contact_Number FROM Customers""");
    return response.map((e) {
      return e["Contact_Number"] as String;
    }).toList();
  }

  /// [fetchAllCustomerNumbersWithNames] fetch's the mobile numbers with there id and name from the all customers
  static Future<List<Contact>> fetchAllCustomerNumbersWithNames() async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db
        .rawQuery("""SELECT Customer_ID, Customer_Name, Contact_Number FROM Customers ORDER BY Customer_Name ASC""");

    return Contact.toList(response);
  }

  static Future<String> fetchRequriedCustomerName(int id) async {
    final Database db = await BackEnd.db();
    try {
      final response = await db.rawQuery("""SELECT Customer_Name FROM Customers WHERE Customer_ID == $id""");
      return response.first["Customer_Name"].toString();
    } catch (e) {
      return "";
    }
  }

  static Future<List<Customer>> fetchSingleContactDetails({required int id}) async {
    try {
      final db = await BackEnd.db();
      final response = await db.query(
        'Customers',
        where: 'Customer_ID = ?',
        whereArgs: [id],
      );
      return Customer.toList(response);
    } catch (e) {
      return [];
    }
  }

  static Future deleteTheCustomer({required int customerID}) async {
    final Database db = await BackEnd.db();
    try {
      await db.delete(
        "Customers",
        where: 'Customer_ID = ?',
        whereArgs: [customerID],
      );
      await db.delete(
        "Items",
        where: 'Customer_ID = ?',
        whereArgs: [customerID],
      );
      final List<Trx> t = Trx.toList(
        await db.query(
          "Transactions",
          where: 'Customer_ID = ?',
          whereArgs: [customerID],
        ),
      );
      t.map((e) async {
        await db.delete(
          "Payments",
          where: 'Transaction_ID = ?',
          whereArgs: [e.id],
        );
      });
      await db.delete(
        "Transactions",
        where: 'Customer_ID = ?',
        whereArgs: [customerID],
      );
    } catch (e) {
      print(e);
    }
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
    final db = await BackEnd.db();
    int count = await db.update(
      'Customers',
      {
        'Customer_Name': newCustomerName,
        'Gaurdian_Name': newGuardianName,
        'Customer_Address': newCustomerAddress,
        'Contact_Number': newContactNumber,
        'Customer_Photo': newCustomerPhoto,
        'Proof_Photo': newProofPhoto,
        'Created_Date': newCreatedDate,
      },
      where: 'Customer_ID = ?',
      whereArgs: [customerId],
    );
    return count;
  }

  //// I T E M S
  /// create a new item row
  static Future<int> createNewItem(Items item) async {
    try {
      final db = await BackEnd.db();
      final Map<String, Object> data = {
        "Customer_ID": item.customerid,
        "Item_Name": item.name,
        "Item_Description": item.description,
        "Pawned_Date": item.pawnedDate,
        "Expiry_Date": item.expiryDate,
        "Pawn_Amount": item.pawnAmount,
        "Item_Status": item.status,
        "Item_Photo": item.photo,
        "Created_Date": item.createdDate
      };
      final int id = await db.insert("Items", data, conflictAlgorithm: sql.ConflictAlgorithm.abort);
      return id;
    } catch (e) {
      return 0;
    }
  }

  /// fetch all items
  static fetchAllItems() async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.rawQuery("""SELECT * FROM Items""");
    return Items.toList(response);
  }

  // fetch all items of a requried customer
  static Future<List<Items>> fetchitemOfRequriedCustomer({required int customerID}) async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.query(
      "Items",
      where: 'Customer_ID = ?',
      whereArgs: [customerID],
    );
    return Items.toList(response);
  }

  //// T R A N S A C T I O N S

  /// create new Transaction

  static Future<int> createNewTransaction(Trx transasction) async {
    try {
      final db = await BackEnd.db();
      final Map<String, dynamic> data = {
        "Customer_ID": transasction.customerId,
        "Item_ID": transasction.itemId,
        "Transaction_Date": transasction.transacrtionDate,
        "Transaction_Type": transasction.transacrtionType,
        "Amount": transasction.amount,
        "Interest_Rate": transasction.intrestRate,
        "Interest_Amount": transasction.intrestAmount,
        "Remaining_Amount": transasction.remainingAmount,
        "Created_Date": transasction.createdDate,
      };
      final response = await db.insert("Transactions", data, conflictAlgorithm: sql.ConflictAlgorithm.abort);
      return response;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  static Future<List<Trx>> fetchAllTransactions() async {
    try {
      final db = await BackEnd.db();
      final response = await db.rawQuery("""
          SELECT * FROM Transactions
      """);
      return Trx.toList(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Trx>> fetchRequriedCustomerTransactions({required int customerId}) async {
    final Database db = await BackEnd.db();
    final response = await db.query(
      "Transactions",
      where: 'Customer_ID = ?',
      whereArgs: [customerId],
    );
    return Trx.toList(response);
  }

  //// H I S T O R Y
  /// fetch all history
  static fetchAllUserHistory() async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.rawQuery("""SELECT * FROM History ORDER BY Event_Date DESC""");
    return UserHistory.toList(response);
  }

  static Future<int> createNewHistory(UserHistory history) async {
    try {
      final db = await BackEnd.db();
      final Map<String, Object> data = {
        "User_ID": history.userID,
        "Customer_ID": history.customerID,
        "Customer_Name": history.customerName,
        "Contact_Number": history.customerNumber,
        "Item_ID": history.itemID,
        "Transacrtion_ID": history.transactionID,
        "Amount": history.amount,
        "Event_Date": history.eventDate,
        "Event_Type": history.eventType,
      };
      try {
        final int id = await db.insert("History", data, conflictAlgorithm: sql.ConflictAlgorithm.abort);
        return id;
      } catch (e) {
        print(e);
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // ///[createNewTransaction] creates a new transaction in the DataBase
  // static Future<int> createNewTransaction(TransactionsHistory transacrtion) async {
  //   final db = await BackEnd.db();
  //   try {
  //     final data = {
  //       "CUST_ID": transacrtion.custId,
  //       "TAKEN_DATE": transacrtion.takenDate,
  //       "TAKEN_AMOUNT": transacrtion.takenAmount,
  //       "RATE_OF_INTEREST": transacrtion.rateOfInterest,
  //       "ITEM_NAME": transacrtion.itemName,
  //       "TRANSACTION_TYPE": transacrtion.transactionType,
  //       "PAID_DATE": transacrtion.paidDate,
  //       "VIA": transacrtion.via,
  //       "PAID_AMOUNT": transacrtion.paidAmount,
  //       "TOTAL_INTREST": transacrtion.totalIntrest,
  //       "DUE_TIME": transacrtion.dueTime,
  //       "PHOTO_ITEM": transacrtion.photoItem ?? "",
  //       "PHOTO_PROOF": transacrtion.photoProof ?? "",
  //       "CREATED_DATE": DateTime.now().toString(),
  //     };

  //     final id = await db.insert('TRANSACTIONS', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  //     return id;
  //   } catch (e) {
  //     print(e);
  //     return 0;
  //   }
  // }

  // /// [fetchLatestTransactions] : get latest
  // /// Transactions of all customers from the TRANSACTIONS Tables without Customers
  // static Future<List<TransactionsHistory>> fetchLatestTransactions() async {
  //   final db = await BackEnd.db();
  //   List<Map<String, Object?>> result = await db.rawQuery("""
  //     SELECT * FROM TRANSACTIONS ORDER BY TAKEN_DATE
  //   """);
  //   if (result.isNotEmpty) {
  //     return TransactionsHistory.toList(result);
  //   } else {
  //     return [];
  //   }
  // }

  // /// [fetchUserHistory] fetch user history
  // static Future<List<UserHistory>> fetchUserHistory() async {
  //   final db = await BackEnd.db();
  //   try {
  //     List<Map<String, Object?>> response = await db.rawQuery("""
  //         SELECT * FROM USER_HISTORY
  //         """);
  //     return UserHistory.toList(response);
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }

  // // get called first  app lunches or reload app

  // static Future<List<Customer>> fetchAllCustomersData() async {
  //   final db = await BackEnd.db();

  //   try {
  //     final response = await db.query('CUSTOMERS', orderBy: 'CUST_ID');
  //     final List<Customer> result = Customer.toList(response);
  //     print("resumt $result");
  //     return result;
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }

  // /// [fetchAllCustomersWithTransactions] fetchs the all users with there transactions from the Db
  // List<Map<Customer, List<TransactionsHistory>>> fetchAllCustomersWithTransactions() {
  //   //todo write a query to fetch the all users with there transactions from the Db and map them
  //   //todo and list this them
  //   return List.empty();
  // }

  // /// [getCustomerEntriesByMobileNumber] get the entry by mobile number
  // static Future<List<Map<String, dynamic>>> getCustomerEntriesByMobileNumber(String mobileNumber, int transfer) async {
  //   final db = await BackEnd.db();

  //   return db.query(
  //     'CUSTOMERS',
  //     orderBy: 'ID',
  //     where: "MOBILE_NUMBER = ? and TRANSFER = ?",
  //     whereArgs: [mobileNumber, transfer],
  //   );
  // }
  // // get the transaction by mobile number

  // static Future<List<TransactionsHistory>> getTransactionsEntriesByMobileNumber(String mobileNumber) async {
  //   final db = await BackEnd.db();
  //   final List<Map<String, Object?>> data = await db.query(
  //     'TRANSACTIONS',
  //     orderBy: 'ID',
  //     where: "MOBILE_NUMBER = ?",
  //     whereArgs: [mobileNumber],
  //   );
  //   List<TransactionsHistory> result = TransactionsHistory.toList(data);
  //   if (result.isNotEmpty) {
  //     return result;
  //   } else {
  //     return [];
  //   }
  // }

  // // get the transaction by Customer Name

  // static Future<List<TransactionsHistory>> getTransactionsEntriesByCustomerName(String name) async {
  //   final db = await BackEnd.db();
  //   final List<Map<String, Object?>> data = await db.query(
  //     'TRANSACTIONS',
  //     orderBy: 'ID',
  //     where: "CUSTOMER_NAME = ?",
  //     whereArgs: [name],
  //   );
  //   List<TransactionsHistory> result = TransactionsHistory.toList(data);
  //   if (result.isNotEmpty) {
  //     return result;
  //   } else {
  //     return [];
  //   }
  // }

  // // Update the item

  // static Future<int> updateCustomerStatus(int id, int code) async {
  //   final db = await BackEnd.db();
  //   final data = {'TRANSFER': code, 'PAID_DATE': DateTime.now().toString()};
  //   final result = await db.update('CUSTOMERS', data, where: "id = ?", whereArgs: [id]);
  //   return result;
  // }

  // // Delete entry

  // static Future<bool> deleteItem(int id) async {
  //   final db = await BackEnd.db();
  //   try {
  //     await db.delete('CUSTOMERS', where: "id = ?", whereArgs: [id]);
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // // fetch the all paid transctions

  // static Future<List<Map<String, dynamic>>> fetchAllPaidTransactions() async {
  //   final db = await BackEnd.db();
  //   return db.query("CUSTOMERS", where: "TRANSFER = ?", whereArgs: [2]);
  // }

  // // fetch the paid transactions of a requried number

  // static Future<List<Map<String, dynamic>>> fetchThisNumberPaidTransactions(String mobileNumber) async {
  //   final db = await BackEnd.db();
  //   return db.query("CUSTOMERS", where: "MOBILE_NUMBER = ? and TRANSFER = ?", whereArgs: [mobileNumber, 2]);
  // }

  // // fetch the paid transactions of a requried number

  // static Future<List<Customer>> fetchThisIDPaidTransactions(String mobileNumber) async {
  //   final db = await BackEnd.db();
  //   List<Customer> data = Customer.toList(
  //     await db.query("CUSTOMERS", where: "MOBILE_NUMBER = ? and TRANSFER = ?", whereArgs: [mobileNumber, 2]),
  //   );
  //   return data;
  // }

  // // // fetch the latest transactions

  // // static Future<List<Customer>> fetchLatestTransactions() async {
  // //   final db = await BackEnd.db();
  // //   List<Map<String, Object?>> result = await db.rawQuery("""
  // //     SELECT * FROM CUSTOMERS ORDER BY ID DESC
  // //   """);
  // //   if (result.isNotEmpty) {
  // //     return Customer.toList(result);
  // //   } else {
  // //     return [];
  // //   }
  // // }

  // //todo  total amount querys

  // // total ammmountInvested present
  // static Future<int> fetchUserPresentInvestedAmount() async {
  //   final db = await BackEnd.db();
  //   List<Map<String, Object?>> result = await db.rawQuery("""
  //   SELECT SUM(TAKEN_AMOUNT) FROM CUSTOMERS WHERE TRANSFER = 1
  //   """);
  //   if (result[0]["SUM(TAKEN_AMOUNT)"] != null) {
  //     int finalResut = (result[0]["SUM(TAKEN_AMOUNT)"]) as int;
  //     return finalResut;
  //   } else {
  //     return 0;
  //   }
  // }

  // close a data base

  Future<bool> close() async {
    final db = await BackEnd.db();
    await db.close();
    return true;
  }
}
