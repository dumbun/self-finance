import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:self_finance/customer/services/customer_portal_service.dart';

void main() {
  group('CustomerPortalProfile Tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'Ramesh Kumar',
        'contact_number': '+91 9876543210',
        'photo_path': 'https://example.com/photo.jpg',
        'guardian_name': 'Suresh Kumar',
        'address': 'Plot 42, Hyderabad',
        'proof_path': 'https://example.com/proof.jpg',
        'created_at': '2026-01-01T00:00:00Z',
      };

      final profile = CustomerPortalProfile.fromJson(json);

      expect(profile.name, 'Ramesh Kumar');
      expect(profile.contactNumber, '+91 9876543210');
      expect(profile.photoPath, 'https://example.com/photo.jpg');
      expect(profile.guardianName, 'Suresh Kumar');
      expect(profile.address, 'Plot 42, Hyderabad');
      expect(profile.proofPath, 'https://example.com/proof.jpg');
      expect(profile.createdAt, DateTime.parse('2026-01-01T00:00:00Z'));
    });

    test('fromJson handles null values with safe defaults', () {
      final profile = CustomerPortalProfile.fromJson({});

      expect(profile.name, '');
      expect(profile.contactNumber, '');
      expect(profile.photoPath, '');
      expect(profile.guardianName, '');
      expect(profile.address, '');
      expect(profile.proofPath, '');
      expect(profile.createdAt, isNull);
    });
  });

  group('CustomerPortalLoan Tests', () {
    test('fromJson parses complete loan and collateral details', () {
      final json = {
        'transaction_id': 'txn-555',
        'amount': 50000,
        'interest_rate': 2.5,
        'interest_amount': 1250.0,
        'remaining_amount': 25000.50,
        'transaction_date': '2026-01-15T00:00:00Z',
        'transaction_type': 'Active',
        'signature_path': 'sig.png',
        'item_name': 'Gold Ring 22K',
        'item_description': 'Hallmarked 8 grams',
        'pawn_amount': 50000.0,
        'item_status': 'Active',
        'pawned_date': '2026-01-15T00:00:00Z',
        'expiry_date': '2026-07-15T00:00:00Z',
        'item_photo_path': 'https://example.com/ring.jpg',
      };

      final loan = CustomerPortalLoan.fromJson(json);

      expect(loan.transactionId, 'txn-555');
      expect(loan.amount, 50000.0);
      expect(loan.interestRate, 2.5);
      expect(loan.interestAmount, 1250.0);
      expect(loan.remainingAmount, 25000.50);
      expect(loan.isActive, isTrue);
      expect(loan.transactionDate, DateTime.parse('2026-01-15T00:00:00Z'));
      expect(loan.itemName, 'Gold Ring 22K');
      expect(loan.itemDescription, 'Hallmarked 8 grams');
      expect(loan.pawnedDate, DateTime.parse('2026-01-15T00:00:00Z'));
      expect(loan.expiryDate, DateTime.parse('2026-07-15T00:00:00Z'));
      expect(loan.itemPhotoPath, 'https://example.com/ring.jpg');
    });

    test('isActive returns false when remainingAmount is zero or negative', () {
      final loan = CustomerPortalLoan.fromJson({
        'transaction_id': 'txn-closed',
        'amount': 20000,
        'remaining_amount': 0,
      });

      expect(loan.isActive, isFalse);
    });
  });

  group('CustomerPortalPayment Tests', () {
    test('fromJson parses payment history correctly', () {
      final json = {
        'payment_id': 'pay-001',
        'transaction_id': 'txn-555',
        'amount_paid': 12500.0,
        'payment_date': '2026-03-01T10:30:00Z',
        'payment_type': 'Principal & Interest',
      };

      final payment = CustomerPortalPayment.fromJson(json);

      expect(payment.paymentId, 'pay-001');
      expect(payment.transactionId, 'txn-555');
      expect(payment.amountPaid, 12500.0);
      expect(payment.paymentDate, DateTime.parse('2026-03-01T10:30:00Z'));
      expect(payment.paymentType, 'Principal & Interest');
    });
  });

  group('CustomerPortalSummary Tests', () {
    test('fromJson parses financial aggregates', () {
      final json = {
        'total_loans': 4,
        'total_borrowed': 100000.0,
        'total_remaining': 45000.0,
        'total_paid': 55000.0,
      };

      final summary = CustomerPortalSummary.fromJson(json);

      expect(summary.totalLoans, 4);
      expect(summary.totalBorrowed, 100000.0);
      expect(summary.totalRemaining, 45000.0);
      expect(summary.totalPaid, 55000.0);
    });
  });

  group('CustomerPortalData Tests', () {
    test('fromJson integrates full payload', () {
      final json = {
        'customer': {
          'name': 'Priya Sharma',
          'contact_number': '+91 9123456789',
        },
        'summary': {
          'total_loans': 1,
          'total_borrowed': 30000.0,
          'total_remaining': 10000.0,
          'total_paid': 20000.0,
        },
        'loans': [
          {
            'transaction_id': 'txn-1',
            'amount': 30000,
            'interest_rate': 2.0,
            'transaction_date': '2026-01-01T00:00:00Z',
            'remaining_amount': 10000,
            'item_name': 'Laptop',
          }
        ],
        'payments': [
          {
            'payment_id': 'pay-1',
            'transaction_id': 'txn-1',
            'amount_paid': 20000,
            'payment_date': '2026-02-01T00:00:00Z',
            'payment_type': 'Principal',
          }
        ],
      };

      final data = CustomerPortalData.fromJson(json);

      expect(data.customer.name, 'Priya Sharma');
      expect(data.summary.totalBorrowed, 30000.0);
      expect(data.loans.length, 1);
      expect(data.loans.first.itemName, 'Laptop');
      expect(data.payments.length, 1);
      expect(data.payments.first.amountPaid, 20000.0);
    });
  });

  group('CustomerPortalAuthResponse Tests', () {
    test('instantiates with complete fields', () {
      final response = CustomerPortalAuthResponse(
        success: true,
        sessionId: 'sess-uuid-123',
        customerName: 'Anil Kumar',
        otpCode: '1234',
        portalToken: 'token-uuid-abc',
        phoneNumber: '+91 9999988888',
        remainingAttempts: 3,
      );

      expect(response.success, isTrue);
      expect(response.sessionId, 'sess-uuid-123');
      expect(response.customerName, 'Anil Kumar');
      expect(response.otpCode, '1234');
      expect(response.portalToken, 'token-uuid-abc');
      expect(response.phoneNumber, '+91 9999988888');
      expect(response.remainingAttempts, 3);
    });
  });
}
