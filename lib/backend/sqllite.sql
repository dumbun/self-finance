-- Customers Table
CREATE TABLE Customers (
    Customer_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
    Customer_Name    TEXT,
    Gaurdian_Name    TEXT,
    Customer_Address TEXT,
    Contact_Number   TEXT,
    Customer_Photo   TEXT,
    Created_Date     DATETIME
);
-- Items Table
CREATE TABLE Items (
    Item_ID          INTEGER PRIMARY KEY AUTOINCREMENT,
    Customer_ID      INTEGER REFERENCES Customers(Customer_ID),
    Item_Name        TEXT,
    Item_Description TEXT,
    Pawned_Date      DATE,
    Expiry_Date      DATE,
    Pawn_Amount      REAL,
    Item_Status      TEXT,
    Created_Date     DATETIME
);
-- Transactions Table
CREATE TABLE Transactions (
    Transaction_ID   INTEGER PRIMARY KEY AUTOINCREMENT,
    Customer_ID      INTEGER REFERENCES Customers(Customer_ID),
    Item_ID          INTEGER REFERENCES Items(Item_ID),
    Transaction_Date DATE,
    Transaction_Type TEXT,
    Amount           REAL,
    Interest_Rate    REAL,
    Interest_Amount  REAL,
    Remaining_Amount REAL,
    Proof_Photo      TEXT,
    Created_Date     DATETIME
);
-- Payments Table
CREATE TABLE Payments (
    Payment_ID       INTEGER PRIMARY KEY AUTOINCREMENT,
    Transaction_ID   INTEGER REFERENCES Transactions(Transaction_ID),
    Payment_Date     DATE,
    Amount_Paid      REAL,
    Payment_Type     TEXT,
    Created_Date     DATETIME
);

-- Hisroy Table 
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

CREATE UNIQUE INDEX ui_cust_index ON "CUSTOMERS"("Contact_Number");
PRAGMA foreign_keys = ON
-- INSERT INTO Customers (Customer_Name, Gaurdian_Name, Customer_Address, Contact_Number, Customer_Photo, Created_Date)
-- VALUES ('John Doe', 'Jane Doe', '123 Main St', '555-1234', 'path/to/photo.jpg', '2023-01-01 12:00:00');
-- INSERT INTO Items (Customer_ID, Item_Name, Item_Description, Pawned_Date, Expiry_Date, Pawn_Amount, Item_Status, Created_Date)
-- VALUES (1, 'Gold Watch', 'Luxury timepiece', '2023-01-05', '2023-02-05', 500.00, 'Active', '2023-01-02 14:30:00');
-- INSERT INTO Transactions (Customer_ID, Item_ID, Transaction_Date, Transaction_Type, Amount, Interest_Rate, Interest_Amount, Remaining_Amount, Proof_Photo, Created_Date)
-- VALUES (1, 1, '2023-01-10', 'pawn', 500.00, 0.05, 25.00, 525.00, 'path/to/proof.jpg', '2023-01-05 09:45:00');
-- INSERT INTO Payments (Transaction_ID, Payment_Date, Amount_Paid,Payment_Type, Created_Date)
-- VALUES (1, '2023-01-15', 200.00,'G-Pay', '2023-01-12 16:20:00');
-- select * from Customers;
-- select * from Items;
-- select * from Transactions;
-- SELECT * FROM Payments;
-- INSERT INTO Payments (Transaction_ID, Payment_Date, Amount_Paid, Created_Date)
-- VALUES (1, '2023-01-29', 325.00, '2023-01-29 16:20:00');
-- ---New Customer
-- INSERT INTO Customers (Customer_Name, Gaurdian_Name, Customer_Address, Contact_Number, Customer_Photo, Created_Date)
-- VALUES ('Vamshi', 'Krishna', '123 Main St', '555-12346', 'path/to/photo.jpg', '2023-01-01 12:00:00');
-- --Item & Transcation 
-- INSERT INTO Items (Customer_ID, Item_Name, Item_Description, Pawned_Date, Expiry_Date, Pawn_Amount, Item_Status, Created_Date)
-- VALUES (2, 'MacBook', 'Old laptop', '2023-01-05', '2023-02-05', 5000.00, 'Active', '2023-01-02 14:30:00');
-- INSERT INTO Transactions (Customer_ID, Item_ID, Transaction_Date, Transaction_Type, Amount, Interest_Rate, Interest_Amount, Remaining_Amount, Proof_Photo, Created_Date)
-- VALUES (2, 2, '2023-01-10', 'pawn', 5000.00, 1, 50.00, 5050.00, 'path/to/proof.jpg', '2023-01-05 09:45:00');
-- INSERT INTO Payments (Transaction_ID, Payment_Date, Amount_Paid, Created_Date)
-- VALUES (2, '2023-01-15', 5050.00, '2023-01-12 16:20:00');
-- select c.*,t.*,I.*,p.* 
-- from Customers c
-- inner join Items i on c.customer_id = i.customer_id
-- left join Transactions t on c.customer_id = t.customer_id and t.item_id = i.item_id
-- left join Payments p on p.Transaction_ID = t.Transaction_ID
-- select t.Customer_ID,t.item_id,t.remaining_amount,Amt_calc.total_amt_Paid,t.remaining_amount-Amt_calc.total_amt_Paid  FROM Transactions t 
-- inner join (select sum(amount_paid) total_amt_Paid ,transaction_id from Payments
-- group by transaction_id) Amt_calc on Amt_calc.transaction_id = t.Transaction_ID 
-- INSERT INTO Customers (Customer_Name, Gaurdian_Name, Customer_Address, Contact_Number, Customer_Photo, Created_Date)
-- VALUES ('Akhilesh', 'Jane Doe', '123 Main St', '555-1266', 'path/to/photo.jpg', '2023-01-01 12:00:00');
-- INSERT INTO Items (Customer_ID, Item_Name, Item_Description, Pawned_Date, Expiry_Date, Pawn_Amount, Item_Status, Created_Date)
-- VALUES (3, 'Watch', 'Luxury timepiece', '2023-01-05', '2023-02-05', 100.00, 'Active', '2023-01-02 14:30:00');
-- INSERT INTO Transactions (Customer_ID, Item_ID, Transaction_Date, Transaction_Type, Amount, Interest_Rate, Interest_Amount, Remaining_Amount, Proof_Photo, Created_Date)
-- VALUES (3, 3, '2023-01-10', 'pawn', 100.00, 10, 10.00, 110.00, 'path/to/proof.jpg', '2023-01-05 09:45:00');
-- INSERT INTO Payments (Transaction_ID, Payment_Date, Amount_Paid, Created_Date)
-- VALUES (3, '2023-01-15', 30.00, '2023-01-12 16:20:00');
-- select * from Payments
-- select * from (
-- select distinct 'Shop Owner',transaction_id,transaction_type,amount,Transaction_Date as paid_date,'Debit' Trans_Type from Transactions
-- union  
-- select distinct t.customer_id,t.transaction_id,'',p.amount_paid as amount,p.payment_date as paid_date, 'Credit' Trans_Type from Payments p 
-- inner join Transactions t on p.transaction_id = t.transaction_id 
-- ) History_calc
-- order by paid_date
-- select * from Payments
-- UNION select 1





