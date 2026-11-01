import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te'),
  ];

  /// Title of the application
  ///
  /// In en, this message translates to:
  /// **'Self-Finance'**
  String get appTitle;

  /// Home tab title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// History tab title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Contacts tab title
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// Account tab title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Account settings screen title
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettings;

  /// New customer and loan screen title
  ///
  /// In en, this message translates to:
  /// **'New Customer & Loan'**
  String get newCustomerAndLoan;

  /// Subtitle on customer and loan entry screen
  ///
  /// In en, this message translates to:
  /// **'Enter customer, loan, item and signature details'**
  String get newCustomerSubtitle;

  /// Add new transaction title
  ///
  /// In en, this message translates to:
  /// **'Add new transaction'**
  String get addNewTransaction;

  /// Section header for customer details
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// Section header for loan terms
  ///
  /// In en, this message translates to:
  /// **'Loan Terms & Interest'**
  String get loanTermsAndInterest;

  /// Section header for collateral
  ///
  /// In en, this message translates to:
  /// **'Collateral & Documentation'**
  String get collateralAndDocumentation;

  /// Section header for signature
  ///
  /// In en, this message translates to:
  /// **'Borrower Acknowledgement'**
  String get borrowerAcknowledgement;

  /// Label for customer name input
  ///
  /// In en, this message translates to:
  /// **'Customer full name'**
  String get customerName;

  /// Label for guardian name input
  ///
  /// In en, this message translates to:
  /// **'Guardian full name'**
  String get guardianName;

  /// Label for mobile number input
  ///
  /// In en, this message translates to:
  /// **'Customer mobile number'**
  String get mobileNumber;

  /// Label for customer address input
  ///
  /// In en, this message translates to:
  /// **'Customer address'**
  String get customerAddress;

  /// Label for customer profile photo
  ///
  /// In en, this message translates to:
  /// **'Customer photo'**
  String get customerPhoto;

  /// Label for customer identity proof
  ///
  /// In en, this message translates to:
  /// **'Customer proof'**
  String get customerProof;

  /// Label for collateral item photo
  ///
  /// In en, this message translates to:
  /// **'Customer item'**
  String get customerItem;

  /// Label for item description
  ///
  /// In en, this message translates to:
  /// **'Item description'**
  String get itemDescription;

  /// Label for loan amount taken
  ///
  /// In en, this message translates to:
  /// **'Taken amount'**
  String get takenAmount;

  /// Label for monthly interest rate percentage
  ///
  /// In en, this message translates to:
  /// **'Monthly interest rate %'**
  String get rateOfIntrest;

  /// Label for date the loan was taken
  ///
  /// In en, this message translates to:
  /// **'Taken date'**
  String get takenDate;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Primary action button to create customer and loan
  ///
  /// In en, this message translates to:
  /// **'Create Customer & Loan'**
  String get createCustomerAndLoan;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Dialog title to select language
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'Hindi (हिंदी)'**
  String get hindi;

  /// Telugu language name
  ///
  /// In en, this message translates to:
  /// **'Telugu (తెలుగు)'**
  String get telugu;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Error alert title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry prompt message
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// Success message after saving
  ///
  /// In en, this message translates to:
  /// **'Saved successfully ✅'**
  String get savedSuccessfully;

  /// Validation error when contact number already exists
  ///
  /// In en, this message translates to:
  /// **'This contact number is already in your database.'**
  String get contactAlreadyExists;

  /// Validation error for invalid mobile number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get enterValidNumber;

  /// Validation error for empty required fields
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid value'**
  String get enterValidValue;

  /// Validation error for invalid amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// Empty state message for transactions
  ///
  /// In en, this message translates to:
  /// **'Sorry, no transactions found. 🫠'**
  String get noTransactionsFound;

  /// Analytics label for total invested amount
  ///
  /// In en, this message translates to:
  /// **'Total amount invested'**
  String get totalAmountInvested;

  /// Analytics label for total interest amount
  ///
  /// In en, this message translates to:
  /// **'Interest amount'**
  String get interestAmount;

  /// Active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Completed status label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Placeholder for country code search
  ///
  /// In en, this message translates to:
  /// **'Search country name or code...'**
  String get searchCountry;

  /// Title for country selection sheet
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// Clear button label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Signature label indicating requirement
  ///
  /// In en, this message translates to:
  /// **'Customer Signature (Required)'**
  String get signatureRequired;

  /// Transactions label
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// EMI Calculator label
  ///
  /// In en, this message translates to:
  /// **'EMI Calculator'**
  String get calculator;

  /// EMI Calculator title
  ///
  /// In en, this message translates to:
  /// **'EMI Calculator'**
  String get emiCalculatorTitle;

  /// Home screen label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeScreen;

  /// Profile section header
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Security section header
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Preferences section header
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Data section header
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// Theme tile label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Notifications tile label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Biometrics tile label
  ///
  /// In en, this message translates to:
  /// **'Biometrics / App Lock'**
  String get biometrics;

  /// Cloud sync tile label
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// Export to CSV tile label
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCsv;

  /// Feedback button label
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Rate us button label
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// Total customers card title
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// Active loans card title
  ///
  /// In en, this message translates to:
  /// **'Active Loans'**
  String get activeLoans;

  /// Outstanding amount card title
  ///
  /// In en, this message translates to:
  /// **'Outstanding Amount'**
  String get outstandingAmount;

  /// Outstanding amount card subtitle
  ///
  /// In en, this message translates to:
  /// **'To be collected'**
  String get outstandingAmountSub;

  /// Interest earned card title
  ///
  /// In en, this message translates to:
  /// **'Interest Earned'**
  String get interestEarned;

  /// Interest earned card subtitle
  ///
  /// In en, this message translates to:
  /// **'From completed'**
  String get interestEarnedSub;

  /// Total disbursed card title
  ///
  /// In en, this message translates to:
  /// **'Total Disbursed'**
  String get totalDisbursed;

  /// Payments received card title
  ///
  /// In en, this message translates to:
  /// **'Payments Received'**
  String get paymentsReceived;

  /// Change PIN tile title
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Currency tile title
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Terms and conditions label
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Privacy policy label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Legal section label
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// About section label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// All time subtitle
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// Total collected subtitle
  ///
  /// In en, this message translates to:
  /// **'Total collected'**
  String get totalCollected;

  /// Change app currency tile title
  ///
  /// In en, this message translates to:
  /// **'Change App Currency'**
  String get changeAppCurrency;

  /// Alert message when changing currency
  ///
  /// In en, this message translates to:
  /// **'This change affects the entire application. Do you really want to change the application\'\'s currency?'**
  String get currencyChangeAlert;

  /// Alert dialog title
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Yearly chart tab label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Monthly chart tab label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Weekly chart tab label
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Today chart tab label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Chart header for last 12 months
  ///
  /// In en, this message translates to:
  /// **'Last 12 Months'**
  String get last12Months;

  /// Chart header for last 6 months
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get last6Months;

  /// Chart header for last 7 days
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// Chart header for today's overview
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s Overview'**
  String get todaysOverview;

  /// Chart received legend label
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// Chart disbursed legend label
  ///
  /// In en, this message translates to:
  /// **'Disbursed'**
  String get disbursed;

  /// Details button label
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Error message when chart data fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load chart data'**
  String get couldNotLoadChartData;

  /// Prompt encouraging user to share app
  ///
  /// In en, this message translates to:
  /// **'If you like our app please'**
  String get likeOurApp;

  /// Invite friends button label
  ///
  /// In en, this message translates to:
  /// **'Invite your friends'**
  String get inviteFriends;

  /// Create new contact action button
  ///
  /// In en, this message translates to:
  /// **'Create new Contact'**
  String get createNewContact;

  /// Show contacts action button
  ///
  /// In en, this message translates to:
  /// **'Show Contacts'**
  String get showContacts;

  /// Hint text for transaction search
  ///
  /// In en, this message translates to:
  /// **'Search transaction ID'**
  String get searchTransactionId;

  /// Message when transaction list is empty
  ///
  /// In en, this message translates to:
  /// **'No Transactions to view'**
  String get noTransactionsToView;

  /// Message when loading additional transactions fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load more transactions'**
  String get failedToLoadMoreTransactions;

  /// Hint text for searching customer or phone number
  ///
  /// In en, this message translates to:
  /// **'Phone number or customer name'**
  String get searchCustomerOrPhone;

  /// Empty state message for contacts
  ///
  /// In en, this message translates to:
  /// **'0 contacts found 🫠'**
  String get zeroContacts;

  /// Message when history list is empty
  ///
  /// In en, this message translates to:
  /// **'No history to view'**
  String get noHistoryToView;

  /// Loan principal amount header in calculator
  ///
  /// In en, this message translates to:
  /// **'Loan Principal Amount'**
  String get loanPrincipalAmount;

  /// Placeholder hint for loan amount input
  ///
  /// In en, this message translates to:
  /// **'Enter amount (e.g. 50,000)'**
  String get enterAmountHint;

  /// Monthly interest rate label in calculator
  ///
  /// In en, this message translates to:
  /// **'Monthly Interest Rate (% per month)'**
  String get monthlyInterestRate;

  /// Calculate repayment button label
  ///
  /// In en, this message translates to:
  /// **'Calculate Repayment'**
  String get calculateRepayment;

  /// Total repayment amount card title
  ///
  /// In en, this message translates to:
  /// **'TOTAL REPAYMENT AMOUNT'**
  String get totalRepaymentAmount;

  /// Compound interest badge
  ///
  /// In en, this message translates to:
  /// **'COMPOUND'**
  String get compound;

  /// Simple interest badge
  ///
  /// In en, this message translates to:
  /// **'SIMPLE'**
  String get simple;

  /// Loan tenure duration metric title
  ///
  /// In en, this message translates to:
  /// **'Tenure Duration'**
  String get tenureDuration;

  /// Monthly interest metric title
  ///
  /// In en, this message translates to:
  /// **'Monthly Interest'**
  String get monthlyInterest;

  /// Daily interest metric title
  ///
  /// In en, this message translates to:
  /// **'Daily Interest'**
  String get dailyInterest;

  /// Total interest metric title
  ///
  /// In en, this message translates to:
  /// **'Total Interest'**
  String get totalInterest;

  /// Copy summary button label
  ///
  /// In en, this message translates to:
  /// **'Copy Summary'**
  String get copySummary;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// 1 Month plus filter chip label
  ///
  /// In en, this message translates to:
  /// **'1 Month +'**
  String get filterOneMonth;

  /// 3 Months plus filter chip label
  ///
  /// In en, this message translates to:
  /// **'3 Months +'**
  String get filterThreeMonths;

  /// 6 Months plus filter chip label
  ///
  /// In en, this message translates to:
  /// **'6 Months +'**
  String get filterSixMonths;

  /// 12 Months plus filter chip label
  ///
  /// In en, this message translates to:
  /// **'12 Months +'**
  String get filterTwelveMonths;

  /// Error message when user data fetch fails
  ///
  /// In en, this message translates to:
  /// **'Error fetching user data'**
  String get errorUserFetch;

  /// Subtitle in CSV export sheet
  ///
  /// In en, this message translates to:
  /// **'Select data to export'**
  String get selectDataToExport;

  /// CSV export type label for all transactions
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// CSV export description for all transactions
  ///
  /// In en, this message translates to:
  /// **'Every loan record regardless of status'**
  String get allTransactionsDesc;

  /// CSV export type label for completed loans
  ///
  /// In en, this message translates to:
  /// **'Completed Loans'**
  String get completedLoans;

  /// CSV export description for completed loans
  ///
  /// In en, this message translates to:
  /// **'Fully paid / closed loans'**
  String get completedLoansDesc;

  /// Payment history tab
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// CSV export description for payment history
  ///
  /// In en, this message translates to:
  /// **'All payment records with amounts'**
  String get paymentHistoryDesc;

  /// CSV export description for active loans
  ///
  /// In en, this message translates to:
  /// **'Only currently open/unpaid loans'**
  String get activeLoansDesc;

  /// Validation message when no export type is selected
  ///
  /// In en, this message translates to:
  /// **'Please select at least one data type.'**
  String get pleaseSelectAtLeastOneDataType;

  /// Progress message when starting CSV export
  ///
  /// In en, this message translates to:
  /// **'Starting export…'**
  String get startingExport;

  /// Success message when CSV export finishes
  ///
  /// In en, this message translates to:
  /// **'Export completed successfully!'**
  String get exportCompletedSuccessfully;

  /// Error message when CSV export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed.'**
  String get exportFailed;

  /// Button to retry CSV export
  ///
  /// In en, this message translates to:
  /// **'Export Again'**
  String get exportAgain;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Export button label with count of files
  ///
  /// In en, this message translates to:
  /// **'Export {count} file(s)'**
  String exportCountFiles(int count);

  /// Label for present date
  ///
  /// In en, this message translates to:
  /// **'Present date'**
  String get presentDate;

  /// Label for payment date
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get paymentDate;

  /// Label for loan due date
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Label for interest per month
  ///
  /// In en, this message translates to:
  /// **'Interest per month'**
  String get interestPerMonth;

  /// Label for total interest amount
  ///
  /// In en, this message translates to:
  /// **'Total interest amount'**
  String get totalInterestAmount;

  /// Label for total amount
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// Empty state subtitle in customer transactions view
  ///
  /// In en, this message translates to:
  /// **'This customer currently has no loan transactions recorded.'**
  String get customerNoTransactionsRecorded;

  /// Button to create first transaction for customer
  ///
  /// In en, this message translates to:
  /// **'Create First Transaction'**
  String get createFirstTransaction;

  /// Error message when fetching transactions fails
  ///
  /// In en, this message translates to:
  /// **'Error fetching transactions. Please restart the application.'**
  String get errorFetchingTransactions;

  /// Dialog title for deleting contact
  ///
  /// In en, this message translates to:
  /// **'Delete Contact?'**
  String get deleteContactQuestion;

  /// Confirmation message when deleting contact
  ///
  /// In en, this message translates to:
  /// **'By pressing \'\'YES\'\', you will remove all details of this customer from your database.'**
  String get contactDeleteMessage;

  /// Error message when fetching customer contacts fails
  ///
  /// In en, this message translates to:
  /// **'Error fetching customer contacts. Please try again. 😶‍🌫️'**
  String get errorFetchingContacts;

  /// Section header for personal and contact details
  ///
  /// In en, this message translates to:
  /// **'Personal & Contact Info'**
  String get personalAndContactInfo;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Fallback text when customer info is not provided
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// Label for customer registration date
  ///
  /// In en, this message translates to:
  /// **'Customer Since'**
  String get customerSince;

  /// Section header for KYC and identity proof
  ///
  /// In en, this message translates to:
  /// **'KYC & Identity Proof'**
  String get kycAndIdentityProof;

  /// Section header for contact action tiles
  ///
  /// In en, this message translates to:
  /// **'Contact Actions'**
  String get contactActions;

  /// Action tile title for editing contact details
  ///
  /// In en, this message translates to:
  /// **'Edit Contact Details'**
  String get editContactDetails;

  /// Subtitle for editing contact details
  ///
  /// In en, this message translates to:
  /// **'Update name, number, address, or photos'**
  String get updateContactSubtitle;

  /// Action tile title for sharing contact info
  ///
  /// In en, this message translates to:
  /// **'Share Contact Info'**
  String get shareContactInfo;

  /// Subtitle for sharing contact info
  ///
  /// In en, this message translates to:
  /// **'Share customer profile details'**
  String get shareContactSubtitle;

  /// Action tile title for deleting customer
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomer;

  /// Subtitle for deleting customer
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this customer and record'**
  String get deleteCustomerSubtitle;

  /// Badge text for verified identity document
  ///
  /// In en, this message translates to:
  /// **'Verified Document'**
  String get verifiedDocument;

  /// Button to view full proof image
  ///
  /// In en, this message translates to:
  /// **'View Full'**
  String get viewFull;

  /// Hint text overlaid on KYC document
  ///
  /// In en, this message translates to:
  /// **'Tap to preview KYC document'**
  String get tapToPreviewKyc;

  /// Empty state title when no KYC proof is attached
  ///
  /// In en, this message translates to:
  /// **'No Identity Proof Attached'**
  String get noIdentityProofAttached;

  /// Empty state subtitle for attaching KYC proof
  ///
  /// In en, this message translates to:
  /// **'Attach an Aadhaar, PAN, voter card, or photo document for KYC verification.'**
  String get attachKycSubtitle;

  /// Button label to attach KYC document
  ///
  /// In en, this message translates to:
  /// **'Attach Document'**
  String get attachDocument;

  /// Tooltip or button label to make a phone call
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Snack bar message when text is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String copiedToClipboard(String label);

  /// App bar title for editing contact
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editContact;

  /// Button label for updating contact
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Success message after updating contact
  ///
  /// In en, this message translates to:
  /// **'Contact updated successfully.'**
  String get contactUpdatedSuccessfully;

  /// Error message when contact update fails
  ///
  /// In en, this message translates to:
  /// **'Error while updating the contact. Please try again later.'**
  String get errorUpdatingContact;

  /// Menu item to edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Menu item to delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Currency selector label
  ///
  /// In en, this message translates to:
  /// **'Please select a currency type'**
  String get selectCurrencyType;

  /// Button label to show customer proof
  ///
  /// In en, this message translates to:
  /// **'Show Customer proof'**
  String get showCustomerProof;

  /// Error message when fetching item data fails
  ///
  /// In en, this message translates to:
  /// **'Error fetching Item data'**
  String get errorFetchingItem;

  /// Status chip label for inactive state
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Success message after transaction is added
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully.'**
  String get transactionAddedSuccessfully;

  /// Error message when adding transaction fails
  ///
  /// In en, this message translates to:
  /// **'Error adding transaction. Please try again later.'**
  String get errorAddingTransaction;

  /// Heading for enter app PIN
  ///
  /// In en, this message translates to:
  /// **'Enter your app PIN'**
  String get enterYourAppPin;

  /// Error snack bar when incorrect PIN is entered
  ///
  /// In en, this message translates to:
  /// **'Please enter the correct PIN'**
  String get enterCorrectPin;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Tab title for KYC & Details
  ///
  /// In en, this message translates to:
  /// **'KYC & Details'**
  String get kycAndDetails;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get loading;

  /// Title for the customer OTP verification bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Customer OTP Verification'**
  String get customerOtpVerification;

  /// Message showing who the OTP was sent to
  ///
  /// In en, this message translates to:
  /// **'An OTP has been sent to {customerName} ({phoneNumber}) to confirm this loan transaction.'**
  String otpSentMessage(String customerName, String phoneNumber);

  /// Instruction to enter the 4-digit OTP
  ///
  /// In en, this message translates to:
  /// **'Enter 4-Digit Verification Code'**
  String get enterVerificationCode;

  /// Button label to verify OTP and confirm transaction
  ///
  /// In en, this message translates to:
  /// **'Verify & Confirm'**
  String get verifyAndConfirm;

  /// Action label to resend OTP
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// Countdown timer before OTP can be resent
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String resendOtpIn(int seconds);

  /// Error displayed when entered OTP is incorrect
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code. Please check and try again.'**
  String get invalidOtpCode;

  /// Error displayed when OTP expires
  ///
  /// In en, this message translates to:
  /// **'OTP has expired. Please request a new code.'**
  String get otpExpired;

  /// Snack bar message when OTP SMS is triggered
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully to customer'**
  String get otpSentSuccessfully;

  /// Button to launch the SMS application
  ///
  /// In en, this message translates to:
  /// **'Open SMS App'**
  String get openSmsApp;

  /// SMS message template sent to customer
  ///
  /// In en, this message translates to:
  /// **'Your verification code for Self-Finance loan of {amount} is {otp}. Valid for 5 minutes. Do not share with anyone.'**
  String otpSmsTemplate(String amount, String otp);

  /// Dialog or alert title when OTP is required
  ///
  /// In en, this message translates to:
  /// **'OTP Verification Required'**
  String get otpRequiredTitle;

  /// Notification when test OTP is copied
  ///
  /// In en, this message translates to:
  /// **'Test OTP {otp} copied to clipboard'**
  String testOtpCopied(String otp);

  /// Error alert dialog message when customer contact already exists
  ///
  /// In en, this message translates to:
  /// **'This contact number is already in your database. Please change the number, or if you want to add a transaction to an existing contact, select \'\'Add transaction to existing contact\'\' on the Home screen.'**
  String get contactAlreadyExistMessage;

  /// Alert title when an action cannot be performed
  ///
  /// In en, this message translates to:
  /// **'Sorry'**
  String get sorry;

  /// Validation message when transaction date is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select the transaction date'**
  String get pleaseSelectTransactionDate;

  /// Timeline label for loan taken
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get bought;

  /// Timeline label for payment made
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Financial summary active balance metric title
  ///
  /// In en, this message translates to:
  /// **'Active Balance'**
  String get activeBalance;

  /// Total borrowed summary label
  ///
  /// In en, this message translates to:
  /// **'Total Borrowed'**
  String get totalBorrowed;

  /// Count of customer loans
  ///
  /// In en, this message translates to:
  /// **'{count} Loans'**
  String loansCount(int count);

  /// Error snackbar when SMS app cannot be launched
  ///
  /// In en, this message translates to:
  /// **'Unable to open SMS composer'**
  String get unableToOpenSms;

  /// Snackbar when customer has no proof image attached
  ///
  /// In en, this message translates to:
  /// **'No proof document attached for this customer'**
  String get noProofDocumentAttached;

  /// Snackbar when customer has no profile photo attached
  ///
  /// In en, this message translates to:
  /// **'No photo attached for this customer'**
  String get noPhotoAttached;

  /// Title when customer profile is not found
  ///
  /// In en, this message translates to:
  /// **'Customer Not Found'**
  String get customerNotFound;

  /// Subtitle when customer profile is not found
  ///
  /// In en, this message translates to:
  /// **'The requested customer profile could not be found or has been removed.'**
  String get customerNotFoundSubtitle;

  /// Button to go back to previous screen
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Title for app lock and currency setup
  ///
  /// In en, this message translates to:
  /// **'Set App Lock & Currency'**
  String get setAppLockAndCurrency;

  /// Subtitle for app lock and currency setup
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN to secure your records and select your preferred currency.'**
  String get appLockSetupSubtitle;

  /// Label for optional name in setup
  ///
  /// In en, this message translates to:
  /// **'Your Name (Optional)'**
  String get yourNameOptional;

  /// Hint text for name field
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterTheName;

  /// Label for primary currency selection in setup
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get primaryCurrency;

  /// Section title to create PIN
  ///
  /// In en, this message translates to:
  /// **'Create 4-Digit App Lock PIN'**
  String get createAppLockPin;

  /// Section title to confirm PIN
  ///
  /// In en, this message translates to:
  /// **'Confirm 4-Digit PIN'**
  String get confirmPin;

  /// Validation error when PIN and confirm PIN do not match
  ///
  /// In en, this message translates to:
  /// **'* PINs do not match'**
  String get pinsDoNotMatch;

  /// Submit button on app lock setup
  ///
  /// In en, this message translates to:
  /// **'Finish Setup & Go to Dashboard'**
  String get finishSetupGoToDashboard;

  /// Snackbar when setup completes
  ///
  /// In en, this message translates to:
  /// **'App lock and currency configured successfully!'**
  String get appLockConfiguredSuccessfully;

  /// Action pill label for new loan
  ///
  /// In en, this message translates to:
  /// **'New Loan'**
  String get newLoan;

  /// Subtitle tag line for the app
  ///
  /// In en, this message translates to:
  /// **'Personal Lending & Finance'**
  String get appSubtitle;

  /// Prompt on Google sign in view
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your data across devices'**
  String get signInToSyncData;

  /// Button label for Google sign-in
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Button label while signing in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// Trust banner on Google sign in view
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get yourDataStaysOnDevice;

  /// Error when online connection or login is missing for OTP
  ///
  /// In en, this message translates to:
  /// **'Active internet connection and login required for customer OTP verification.'**
  String get onlineVerificationRequired;

  /// Error when OTP attempts exceed limit
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Please request a new code.'**
  String get tooManyOtpAttempts;

  /// Loading status while fetching OTP from cloud server
  ///
  /// In en, this message translates to:
  /// **'Requesting secure OTP from server...'**
  String get generatingOtp;

  /// Title for customer portal
  ///
  /// In en, this message translates to:
  /// **'Customer Portal'**
  String get customerPortal;

  /// Customer login title
  ///
  /// In en, this message translates to:
  /// **'Customer / Borrower Login'**
  String get customerLogin;

  /// Subtitle on customer login screen
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number to view your loans & transactions'**
  String get customerLoginSubtitle;

  /// Prompt on Google sign-in screen to navigate to customer portal
  ///
  /// In en, this message translates to:
  /// **'Borrower or Customer? Access your loan account'**
  String get customerPortalPrompt;

  /// Placeholder for mobile number
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumber;

  /// Button to request customer portal OTP
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// Button to verify customer portal OTP
  ///
  /// In en, this message translates to:
  /// **'Verify & View Loans'**
  String get verifyAndViewLoans;

  /// Customer dashboard title
  ///
  /// In en, this message translates to:
  /// **'My Loans & Transactions'**
  String get customerDashboard;

  /// Remaining balance summary label
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get remainingBalance;

  /// Total paid summary label
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// My loans tab
  ///
  /// In en, this message translates to:
  /// **'My Loans'**
  String get myLoans;

  /// Empty state when no loans found
  ///
  /// In en, this message translates to:
  /// **'No loans found for this account'**
  String get noLoansFound;

  /// Empty state when no payments found
  ///
  /// In en, this message translates to:
  /// **'No payment records found'**
  String get noPaymentsFound;

  /// Label for collateral item
  ///
  /// In en, this message translates to:
  /// **'Collateral Item'**
  String get collateralItem;

  /// Title for loan details screen
  ///
  /// In en, this message translates to:
  /// **'Loan Details'**
  String get loanDetails;

  /// Label for pawned date
  ///
  /// In en, this message translates to:
  /// **'Pawned Date'**
  String get pawnedDate;

  /// Customer portal logout button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutCustomer;

  /// Back to lender login link
  ///
  /// In en, this message translates to:
  /// **'Back to Lender Login'**
  String get backToLenderLogin;

  /// Validation message when phone number is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterTheNumber;

  /// Prompt to enter 4-digit OTP
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit verification code'**
  String get enterOtpCode;

  /// Action to change entered phone number
  ///
  /// In en, this message translates to:
  /// **'Change Number'**
  String get changeNumber;

  /// Dashboard portfolio overview header
  ///
  /// In en, this message translates to:
  /// **'Portfolio Overview'**
  String get portfolioOverview;

  /// Active portfolio balance label
  ///
  /// In en, this message translates to:
  /// **'Active Portfolio Balance'**
  String get activePortfolioBalance;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// View all action link
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Empty state when no recent transactions exist
  ///
  /// In en, this message translates to:
  /// **'No recent transactions found'**
  String get noRecentActivity;

  /// Quick action label for creating a new loan
  ///
  /// In en, this message translates to:
  /// **'New Loan'**
  String get newLoanAction;

  /// Quick action label for borrowers list
  ///
  /// In en, this message translates to:
  /// **'Borrowers'**
  String get borrowersAction;

  /// Quick action label for transactions ledger
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledgerAction;

  /// Section title for analytics metrics
  ///
  /// In en, this message translates to:
  /// **'Business Breakdown'**
  String get businessBreakdown;

  /// Section title for cashflow trends chart
  ///
  /// In en, this message translates to:
  /// **'Cashflow Analytics'**
  String get cashflowAnalytics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
