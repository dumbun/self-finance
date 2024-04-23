import 'package:path_provider/path_provider.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
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
      final int id = await db.insert(
        'Customers',
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.abort,
      );

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

  static Future<void> deleteTheCustomer({required int customerID}) async {
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
      await db.delete(
        'History',
        where: 'Customer_ID = ?',
        whereArgs: [customerID],
      );
    } catch (e) {
      //
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
    count = await db.update(
      'History',
      {
        'Customer_Name': newCustomerName,
        'Contact_Number ': newContactNumber,
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
  static Future<List<Items>> fetchAllItems() async {
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

  // fetch requried Item
  static Future<List<Items>> fetchRequriedItem({required int itemId}) async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.query(
      "Items",
      where: 'Item_ID = ?',
      whereArgs: [itemId],
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

  static Future<List<Trx>> fetchActiveTransactions() async {
    try {
      final db = await BackEnd.db();
      final response = await db.rawQuery("""
          SELECT * FROM Transactions WHERE Transaction_Type = '${Constant.active}'
      """);
      return Trx.toList(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Trx>> fetchRequriedCustomerTransactions({required int customerId}) async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.query(
      "Transactions",
      where: 'Customer_ID = ?',
      whereArgs: [customerId],
    );
    return Trx.toList(response);
  }

  static Future<List<Trx>> fetchRequriedTransaction({required int transacrtionId}) async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response = await db.query(
      "Transactions",
      where: 'Transaction_ID = ?',
      whereArgs: [transacrtionId],
    );
    return Trx.toList(response);
  }

  static Future<double> fetchSumOfTakenAmount() async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> respose = await db.rawQuery(
      """SELECT SUM(Amount) FROM Transactions WHERE Transaction_Type = '${Constant.active}'""",
    );
    if (respose[0]['SUM(Amount)'] != null) {
      return double.parse(respose[0]['SUM(Amount)'].toString());
    } else {
      return 0.0;
    }
  }

  static Future<int> updateTransactionAsPaid({required int id}) async {
    final db = await BackEnd.db();
    final data = {'Transaction_Type': Constant.inactive};
    final result = await db.update('Transactions', data, where: "Transaction_ID = ?", whereArgs: [id]);

    return result;
  }

  //// P A Y M E N T S

  ///Fetch All payments based on requrited transaction
  static Future<List<Payment>> fetchRequriedPaymentsOfTransaction({required int transactionId}) async {
    final Database db = await BackEnd.db();
    final List<Map<String, Object?>> response =
        await db.query('Payments', where: 'Transaction_ID = ?', whereArgs: [transactionId]);

    return Payment.toList(response);
  }

  static Future<int> addPayment({required Payment payment}) async {
    try {
      final db = await BackEnd.db();
      final Map<String, Object> data = {
        "Transaction_ID": payment.transactionId,
        "Payment_Date": payment.paymentDate,
        "Amount_Paid": payment.amountpaid,
        "Payment_Type": payment.type,
        "Created_Date": payment.createdDate,
      };
      try {
        final int id = await db.insert("Payments", data, conflictAlgorithm: sql.ConflictAlgorithm.abort);
        return id;
      } catch (e) {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  //// H I S T O R Y
  /// fetch all history
  static Future<List<UserHistory>> fetchAllUserHistory() async {
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
        final int id = await db.insert(
          "History",
          data,
          conflictAlgorithm: sql.ConflictAlgorithm.abort,
        );
        return id;
      } catch (e) {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> close() async {
    final db = await BackEnd.db();
    await db.close();
    return true;
  }
}
