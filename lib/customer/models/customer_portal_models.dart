/// Models representing the data returned by the customer portal backend.
class CustomerPortalProfile {
  final String name;
  final String guardianName;
  final String contactNumber;
  final String address;
  final String photoPath;
  final String proofPath;
  final DateTime? createdAt;

  CustomerPortalProfile({
    required this.name,
    required this.guardianName,
    required this.contactNumber,
    required this.address,
    required this.photoPath,
    required this.proofPath,
    this.createdAt,
  });

  factory CustomerPortalProfile.fromJson(Map<String, dynamic> json) {
    return CustomerPortalProfile(
      name: json['name']?.toString() ?? '',
      guardianName: json['guardian_name']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      photoPath: json['photo_path']?.toString() ?? '',
      proofPath: json['proof_path']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class CustomerPortalLoan {
  final String transactionId;
  final double amount;
  final double interestRate;
  final double interestAmount;
  final double remainingAmount;
  final DateTime transactionDate;
  final String transactionType;
  final String signaturePath;
  final DateTime? createdAt;
  final String? itemId;
  final String itemName;
  final String itemDescription;
  final double pawnAmount;
  final String itemStatus;
  final DateTime? pawnedDate;
  final DateTime? expiryDate;
  final String itemPhotoPath;

  CustomerPortalLoan({
    required this.transactionId,
    required this.amount,
    required this.interestRate,
    required this.interestAmount,
    required this.remainingAmount,
    required this.transactionDate,
    required this.transactionType,
    required this.signaturePath,
    this.createdAt,
    this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.pawnAmount,
    required this.itemStatus,
    this.pawnedDate,
    this.expiryDate,
    required this.itemPhotoPath,
  });

  bool get isActive => remainingAmount > 0;

  factory CustomerPortalLoan.fromJson(Map<String, dynamic> json) {
    return CustomerPortalLoan(
      transactionId: json['transaction_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      interestAmount: (json['interest_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: json['transaction_date'] != null
          ? DateTime.tryParse(json['transaction_date'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      transactionType: json['transaction_type']?.toString() ?? 'Active',
      signaturePath: json['signature_path']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      itemId: json['item_id']?.toString(),
      itemName: json['item_name']?.toString() ?? 'Collateral Item',
      itemDescription: json['item_description']?.toString() ?? '',
      pawnAmount: (json['pawn_amount'] as num?)?.toDouble() ?? 0.0,
      itemStatus: json['item_status']?.toString() ?? 'Active',
      pawnedDate: json['pawned_date'] != null
          ? DateTime.tryParse(json['pawned_date'].toString())
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      itemPhotoPath: json['item_photo_path']?.toString() ?? '',
    );
  }
}

class CustomerPortalPayment {
  final String paymentId;
  final String transactionId;
  final double amountPaid;
  final String paymentType;
  final DateTime paymentDate;
  final DateTime? createdAt;

  CustomerPortalPayment({
    required this.paymentId,
    required this.transactionId,
    required this.amountPaid,
    required this.paymentType,
    required this.paymentDate,
    this.createdAt,
  });

  factory CustomerPortalPayment.fromJson(Map<String, dynamic> json) {
    return CustomerPortalPayment(
      paymentId: json['payment_id']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['payment_type']?.toString() ?? 'Interest',
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class CustomerPortalSummary {
  final int totalLoans;
  final double totalBorrowed;
  final double totalRemaining;
  final double totalPaid;

  CustomerPortalSummary({
    required this.totalLoans,
    required this.totalBorrowed,
    required this.totalRemaining,
    required this.totalPaid,
  });

  factory CustomerPortalSummary.fromJson(Map<String, dynamic> json) {
    return CustomerPortalSummary(
      totalLoans: (json['total_loans'] as num?)?.toInt() ?? 0,
      totalBorrowed: (json['total_borrowed'] as num?)?.toDouble() ?? 0.0,
      totalRemaining: (json['total_remaining'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CustomerPortalData {
  final CustomerPortalProfile customer;
  final CustomerPortalSummary summary;
  final List<CustomerPortalLoan> loans;
  final List<CustomerPortalPayment> payments;

  CustomerPortalData({
    required this.customer,
    required this.summary,
    required this.loans,
    required this.payments,
  });

  factory CustomerPortalData.fromJson(Map<String, dynamic> json) {
    final customerJson = json['customer'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? {};
    final loansList = (json['loans'] as List<dynamic>?) ?? [];
    final paymentsList = (json['payments'] as List<dynamic>?) ?? [];

    return CustomerPortalData(
      customer: CustomerPortalProfile.fromJson(customerJson),
      summary: CustomerPortalSummary.fromJson(summaryJson),
      loans: loansList
          .map((e) => CustomerPortalLoan.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: paymentsList
          .map((e) => CustomerPortalPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
