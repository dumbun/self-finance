# Self-Finance Privacy Policy

**Effective Date:** 01 November 2026  
**Last Updated:** 01 November 2026  

Self-Finance (“Self-Finance,” “the App,” “we,” “us,” or “our”) is developed and operated by **Kamsali Vamshi Krishna**. This Privacy Policy describes how we handle, collect, use, store, share, and protect information when you use our mobile application (available on Google Play Store and Apple App Store), our cloud synchronization features, and related services.

We are committed to transparency and user privacy. Self-Finance is designed as a secure digital ledger, bookkeeping, and interest calculation tool. **We do not sell, rent, monetize, or trade your personal data, your customers’ data, or your financial records to any third party, nor do we track you for advertising purposes.**

* **Developer & Controller:** Kamsali Vamshi Krishna
* **Contact & Grievance Email:** [sf.help.vamshi@gmail.com](mailto:sf.help.vamshi@gmail.com)
* **Application Website / Repository:** [https://github.com/dumbun/self-finance](https://github.com/dumbun/self-finance)
* **Account Deletion Request Resource:** [https://dumbun.github.io/self-finance/account_deletion](https://dumbun.github.io/self-finance/account_deletion)

---

## 1. Application Overview & Core Purpose

Self-Finance provides tools to record, manage, and calculate customer, loan, collateral/pawned item, payment, and transaction records.

### Important Regulatory Clarification:
Self-Finance is purely a digital ledger, calculation, and bookkeeping utility. **Self-Finance is NOT a bank, non-banking financial company (NBFC), money lender, credit broker, peer-to-peer lending platform, or financial institution.** The App does not disburse funds, issue loans, offer credit, collect loan payments, or underwrite financial transactions. All data recorded within the App is entered solely by you based on transactions and agreements conducted independently between you and your customers outside the application.

---

## 2. Information Handled by the Application

Depending on how you use Self-Finance, the App handles the following categories of data:

### A. Account & Profile Information
When you sign in using Google Sign-In to use cloud backup and multi-device synchronization:
* **Account Credentials & Identifiers:** Your Google account email address, display name, profile avatar photo URL, and a unique user identifier assigned by our authentication provider (Supabase Auth).
* **Purpose:** To create and securely authenticate your user account, manage user sessions, and isolate your synchronized financial data so that only you can access it.

### B. Customer & Borrower Information (User-Entered)
Information you manually enter regarding individuals you transact with:
* **Customer Profile:** Full name, guardian/parent name, mobile phone number, physical or residential address, and optional notes.
* **Important Notice:** Self-Finance does **not** silently read, scrape, or upload your device’s global address book or contact list. Customer entries are recorded only when explicitly entered or imported by you.

### C. Financial & Transaction Records
Ledger records that you choose to log:
* **Loan & Transaction Data:** Loan principal amount, interest rate percentage (monthly, simple, or custom rate), transaction creation date, repayment due date, settlement status, and transaction history.
* **Payment Records:** Partial repayments, interest payments collected, principal repayments, balance calculations, and payment dates.

### D. Collateral & Pawned Item Details
Records relating to pledged items:
* **Item Information:** Item name/description, weight, purity (e.g., gold/silver carats or percentage), quantity, estimated valuation, and pawn/custody status.

### E. Photographs & Media Attachments
Media files you choose to attach to records:
* **Customer Photographs:** Captured via camera or selected from your device gallery to identify customer profiles.
* **Customer Proof Documents:** Photographs of government identity cards (such as Aadhaar, PAN card, voter ID, driving license, or passport) chosen by you to verify borrower identity.
* **Collateral / Item Images:** Photographs of pledged items or jewelry.
* **Customer Digital Signatures:** Touchscreen digital signatures drawn by the customer or user on the on-screen signature pad to verify transaction agreements and generate printable invoices.

### F. Application Settings & Preferences
* Local preferences such as selected currency symbol, app theme (dark/light/system), local app PIN (stored securely), biometric unlock configuration, and notification preferences.

### G. Technical & Connectivity Information
* Operating system version, app version, and network connection status (used locally by the app to schedule sync tasks when connected and avoid data loss while offline).

---

## 3. Device Permissions & Why We Need Them

To deliver specific features, Self-Finance requests the following device permissions. Each permission is requested in-context and can be enabled or disabled at any time in your device settings:

| Permission | Android / iOS Identifier | Purpose & Usage in Self-Finance |
| :--- | :--- | :--- |
| **Camera** | `android.permission.CAMERA` / `NSCameraUsageDescription` | Used exclusively when you choose to capture a customer profile photo, take a photo of an identity proof document, or capture an image of a collateral item. The camera is never accessed in the background. |
| **Photo Library / Storage** | `android.permission.READ_MEDIA_IMAGES` / `NSPhotoLibraryUsageDescription` | Used exclusively when you choose to attach an existing image from your photo gallery to a customer record, proof document, or item profile. |
| **Biometric Authentication** | `android.permission.USE_BIOMETRIC` / `NSFaceIDUsageDescription` | Used to lock and unlock the app using Fingerprint, Face ID, or device biometrics. **Biometric verification is handled strictly by your device’s operating system (Secure Enclave / Android Keystore). The App never accesses, receives, or stores your biometric data.** |
| **Notifications** | `android.permission.POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` | Used exclusively to schedule local on-device reminder notifications for loan due dates and payment milestones. **These notifications are generated locally on your device; they are never used for promotional push marketing.** |
| **Internet & Network** | `android.permission.INTERNET`, `ACCESS_NETWORK_STATE` | Required to communicate with Supabase for cloud synchronization, authenticate your Google account, and check network status before syncing. |
| **External App Launchers** | Phone, SMS, and Email intents (`tel:`, `sms:`, `mailto:`) | Enables you to tap a phone number or email within the app to initiate a phone call, send an SMS, or draft an email using your device’s default phone or messaging applications. The app does not read your SMS messages or call history. |
| **Document Sharing** | `LSSupportsOpeningDocumentsInPlace`, `UIFileSharingEnabled` | Allows you to export transaction histories to CSV spreadsheets and save or print generated PDF invoices. |

---

## 4. Local Storage and Cloud Synchronization

Self-Finance offers an **offline-first** architecture with optional **cloud synchronization**:

1. **Local Storage:** All your records (customers, transactions, items, photos, and signatures) are stored locally in a high-performance local database (Drift / SQLite) and local sandboxed storage on your device. You can use the app completely offline without an internet connection.
2. **Cloud Synchronization (Via Supabase):** When you sign in with your Google account, Self-Finance enables cloud synchronization. The app securely uploads and synchronizes your database records and media files to our hosted **Supabase** backend:
   * Cloud sync ensures that your financial ledger and attached images are safely backed up and accessible across your devices.
   * Sync occurs automatically when an internet connection is available and when you perform actions in the app.
   * **Row-Level Security (RLS):** All synchronized cloud data is strictly isolated using Supabase Row-Level Security. Each record is cryptographically linked to your unique user ID (`auth.uid()`), ensuring that no other user can view, access, or modify your data.
3. **If You Prefer Not to Sync:** If you do not wish to have your data stored in the cloud, you can use the app without signing in or log out of your cloud account. Note that without cloud sync, your data resides solely on your physical device.

---

## 5. How We Use Information

We process and use the information handled by Self-Finance strictly to:
* Provide, maintain, and optimize the features of the Self-Finance application.
* Authenticate your identity and secure your account access across devices.
* Synchronize your ledger, customer files, items, and media across your connected devices.
* Calculate interest, repayment amounts, total balances, and due dates according to your configurations.
* Generate and export printable PDF receipts/invoices and CSV data spreadsheets upon your request.
* Schedule local on-device reminder notifications for upcoming payment due dates.
* Detect, prevent, and troubleshoot technical errors, bugs, or synchronization conflicts.
* Respond to customer service inquiries and process account or data deletion requests.

### We Do Not:
* **We DO NOT sell, rent, lease, or trade personal data or customer records to third parties.**
* **We DO NOT use personal or financial data for targeted advertising, behavioural profiling, or tracking across other apps and websites.**
* **We DO NOT share personal data with data brokers, ad networks, or marketing agencies.**
* **We DO NOT submit your loan or transaction records to credit bureaus or external financial authorities.**

---

## 6. Third-Party Service Providers (Subprocessors)

To provide reliable authentication and cloud synchronization, Self-Finance integrates trusted third-party infrastructure providers. These service providers process data strictly on our behalf under contractual confidentiality and security commitments:

| Provider | Service Provided | Data Processed | Privacy Information |
| :--- | :--- | :--- | :--- |
| **Supabase Inc.** | Cloud database hosting (PostgreSQL), cloud object storage (attachments & images), and user authentication. | Synced database records, customer files, photos, signatures, email address, user UUID. | Encrypted in transit (TLS 1.2/1.3) and at rest (AES-256). Subject to [Supabase Privacy Policy](https://supabase.com/privacy). |
| **Google LLC** | Google Sign-In (OAuth 2.0) authentication and Google Play Services on Android. | Basic Google profile information (name, email, profile picture, account ID). | Governed by [Google Privacy Policy](https://policies.google.com/privacy). |

When you use features such as calling a customer, sending an SMS, or exporting files via third-party apps (e.g., WhatsApp, Gmail, Google Drive, or local file viewers), the handling of the exported file or communication is governed by the destination application’s privacy policy.

---

## 7. Data Security

We implement rigorous technical, organizational, and administrative safeguards to protect your data against unauthorized access, loss, misuse, or alteration:

* **Encryption in Transit:** All communications between Self-Finance and our Supabase cloud servers are encrypted using modern Transport Layer Security (TLS 1.2 and TLS 1.3).
* **Encryption at Rest:** Cloud database records and media files stored in Supabase Storage are encrypted at rest using industry-standard AES-256 encryption.
* **Row-Level Security (RLS):** Supabase database tables enforce strict database-level access rules tied to your authenticated user identifier. No other user or third party can query or retrieve your records.
* **Application Lock:** The app provides a built-in security gate allowing you to secure access to Self-Finance on your device using a custom 4-digit PIN code and biometric authentication (Fingerprint / Face ID).
* **Storage Sandboxing:** Local files, photos, and database instances are stored in your device’s private application sandbox, protected by mobile OS security boundaries.

*Please note:* While we strive to use the highest standards of data protection, no method of electronic transmission or mobile storage can be guaranteed 100% secure. You are responsible for safeguarding your device, PIN, and account credentials.

---

## 8. Data Retention Policy

* **Local Data:** Data stored locally on your device remains on your device until you delete specific records, clear the app data in device system settings, or uninstall the application.
* **Cloud Data:** Synced records and attachments stored in Supabase remain associated with your account for as long as your account remains active.
* **Backups:** Because local data may be lost if your device is damaged, lost, or reset, we recommend maintaining regular backups using the built-in CSV export feature.

---

## 9. Account and Data Deletion (Play Store & App Store Compliance)

In compliance with Google Play Store User Data Policies and Apple App Store Review Guideline 5.1.1(v), Self-Finance provides complete, transparent, and user-controlled pathways to delete your account and all associated data.

### A. Deleting Local Data from Your Device
You can delete any customer, transaction, or photo individually at any time from within the app interface. To completely remove all local data from your device, clear the app’s storage/cache in your device settings or uninstall the Self-Finance application.

### B. Deleting Your Cloud Account and All Cloud Data
If you have created an account or used cloud synchronization and wish to permanently delete your account and all associated cloud data:

1. **How to Submit a Request:**
   * Send an email to **[sf.help.vamshi@gmail.com](mailto:sf.help.vamshi@gmail.com?subject=Account%20Deletion%20Request%20-%20Self-Finance)**.
   * The email **must** be sent from the same Google account email address you use to sign in to Self-Finance (this verifies account ownership).
   * Include the subject line: `Account Deletion Request - Self-Finance`.
   * State in the email body that you request the permanent deletion of your Self-Finance account and all associated cloud data.

2. **What Data Is Deleted:**
   * Upon receipt and verification of your request, we permanently delete:
     * Your user account credentials and authentication records in Supabase Auth.
     * All database ledger records, customer details, transaction histories, payment records, and notes.
     * All uploaded photographs (customer photos, identity proof images, collateral item images) and customer digital signatures stored in Supabase Storage buckets.
   * Deletion is permanent, irreversible, and wipes all cloud copies.

3. **Processing Timeline:**
   * Your deletion request will be processed and completely executed within **30 days** of receipt. We will send a confirmation email once the deletion is complete.

4. **Dedicated Web Deletion Resource:**
   * You can also view these instructions on our dedicated web resource:  
     [https://dumbun.github.io/self-finance/account_deletion](https://dumbun.github.io/self-finance/account_deletion)

---

## 10. User Responsibility for Customer / Third-Party Data

Self-Finance enables you to record personal data concerning your customers, borrowers, and third parties (including contact details, identity proof documents, and signatures). 

**You act as the data controller with respect to your customers’ personal data.** You acknowledge and warrant that:
* You have obtained all necessary consents, authorizations, and legal permissions from individuals whose information, identity cards, photos, or signatures you record in the App.
* You will collect and handle customer data lawfully, fairly, and in compliance with all applicable data protection regulations (such as the Digital Personal Data Protection Act, 2023 in India, GDPR, CCPA, or other local privacy laws).
* You will not use the App to collect unlawful, defamatory, infringing, or fraudulent information.

---

## 11. Children’s Privacy

Self-Finance is designed strictly for business bookkeeping, financial record-keeping, and adult personal financial management. The Service is not intended for or directed towards children under the age of 13 (or under 16 in the European Economic Area). We do not knowingly collect personal information directly from children. If you become aware that a child has provided us with personal information, please contact us immediately at [sf.help.vamshi@gmail.com](mailto:sf.help.vamshi@gmail.com), and we will promptly delete such information.

---

## 12. Your Legal Rights & Choices

Depending on your geographic location, you may have specific privacy rights under applicable data protection legislation (including India's Digital Personal Data Protection Act (DPDPA 2023), EU General Data Protection Regulation (GDPR), and the California Consumer Privacy Act (CCPA/CPRA)):

* **Right to Access / Portability:** You can access your data within the App at any time and export your transaction records to CSV spreadsheets.
* **Right to Rectification:** You can edit, update, or correct customer details, loan records, item information, and photos directly in the App.
* **Right to Erasure (Right to be Forgotten):** You have the right to request the complete deletion of your account and cloud data as described in Section 9.
* **Right to Withdraw Consent:** You can revoke device permissions (Camera, Photos, Biometrics, Notifications) in your device settings at any time, or log out of your cloud account to stop cloud synchronization.

To exercise any of these rights, contact us at [sf.help.vamshi@gmail.com](mailto:sf.help.vamshi@gmail.com).

---

## 13. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect updates in the application, infrastructure enhancements, or evolving legal and regulatory standards. When changes are made, we will update the “Last Updated” and “Effective Date” at the top of this page. We encourage you to review this Privacy Policy periodically. Continued use of Self-Finance after any revision constitutes your acceptance of the updated policy.

---

## 14. Contact & Grievance Information

If you have questions, feedback, privacy concerns, or data deletion requests regarding this Privacy Policy or Self-Finance, please contact our Developer and Grievance Officer:

* **Name:** Kamsali Vamshi Krishna
* **Email:** [sf.help.vamshi@gmail.com](mailto:sf.help.vamshi@gmail.com)
* **Open Source Repository:** [https://github.com/dumbun/self-finance](https://github.com/dumbun/self-finance)

---

## 15. Store Disclosures & Data Safety Reference Guide

This section provides an explicit reference mapping for the **Google Play Data Safety Section** and the **Apple App Store App Privacy Nutrition Labels**:

### Google Play Data Safety Questionnaire Mapping:
* **Does your app collect or share any of the required user data types?** Yes (for App functionality and Account Management).
* **Is all of the user data collected by your app encrypted in transit?** Yes (All cloud communications use HTTPS / TLS encryption).
* **Do you provide a way for users to request that their data is deleted?** Yes (Via in-app record deletion, clearing app storage, and by sending an email request to sf.help.vamshi@gmail.com).
* **Data Types Collected:**
  * *Personal Info:* Name, Email address, User ID (Collected for Account Management, App Functionality; Not shared with third parties).
  * *Financial Info:* User payment history, loan records (Collected for App Functionality; Stored locally and in Supabase; Not shared).
  * *Photos and Videos:* Photos (Customer profile photos, proof images, item images; Collected for App Functionality; Stored locally and in Supabase; Not shared).
  * *Files and Documents:* Files/Documents (Customer ID proof documents, CSV exports; Collected for App Functionality; Not shared).
  * *Other Actions:* Customer Digital Signatures (Collected for App Functionality / Invoicing; Stored locally and in Supabase; Not shared).

### Apple App Store Privacy Nutrition Labels Mapping:
* **Data Used to Track You:** None (Self-Finance does not track users across other companies’ apps and websites).
* **Data Linked to You:**
  * Contact Info (Email Address, Name)
  * User Content (Photos, Customer Signatures, Customer Proof Documents)
  * Financial Info (Transaction and Ledger Data entered by user)
  * Identifiers (User ID)
* **Data Not Linked to You:**
  * Diagnostics / Performance (Local connectivity status)
