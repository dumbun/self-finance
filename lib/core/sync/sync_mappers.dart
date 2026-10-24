import 'package:self_finance/backend/backend.dart';

/// Maps between local Drift entities and Supabase cloud JSON records.
class SyncMappers {
  // ── Customers ──

  static Map<String, dynamic> customerToSupabase(
    CustomerRow row,
    String ownerId, {
    String? remotePhotoPath,
    String? remoteProofPath,
  }) {
    return {
      'id': row.syncId,
      'owner_id': ownerId,
      'name': row.customerName,
      'guardian_name': row.gaurdianName,
      'address': row.customerAddress,
      'contact_number': row.contactNumber,
      'photo_path': remotePhotoPath ?? row.customerPhoto,
      'proof_path': remoteProofPath ?? row.proofPhoto,
      'created_at': row.createdDate.toUtc().toIso8601String(),
      'updated_at': (row.updatedAt ?? row.createdDate).toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  // ── Items ──

  static Map<String, dynamic> itemToSupabase(
    ItemRow row,
    String customerSyncId,
    String ownerId, {
    String? remotePhotoPath,
  }) {
    return {
      'id': row.syncId,
      'owner_id': ownerId,
      'customer_sync_id': customerSyncId,
      'name': row.itemName,
      'description': row.itemDescription,
      'pawned_date': row.pawnedDate.toUtc().toIso8601String(),
      'expiry_date': row.expiryDate.toUtc().toIso8601String(),
      'pawn_amount': row.pawnAmount,
      'status': row.itemStatus,
      'photo_path': remotePhotoPath ?? row.itemPhoto,
      'created_at': row.createdDate.toUtc().toIso8601String(),
      'updated_at': (row.updatedAt ?? row.createdDate).toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  // ── Transactions ──

  static Map<String, dynamic> transactionToSupabase(
    TransactionRow row,
    String customerSyncId,
    String itemSyncId,
    String ownerId, {
    String? remoteSignaturePath,
  }) {
    return {
      'id': row.syncId,
      'owner_id': ownerId,
      'customer_sync_id': customerSyncId,
      'item_sync_id': itemSyncId,
      'transaction_date': row.transactionDate.toUtc().toIso8601String(),
      'transaction_type': row.transactionType,
      'amount': row.amount,
      'interest_rate': row.interestRate,
      'interest_amount': row.interestAmount,
      'remaining_amount': row.remainingAmount,
      'signature_path': remoteSignaturePath ?? row.signature,
      'created_at': row.createdDate.toUtc().toIso8601String(),
      'updated_at': (row.updatedAt ?? row.createdDate).toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  // ── Payments ──

  static Map<String, dynamic> paymentToSupabase(
    PaymentRow row,
    String transactionSyncId,
    String ownerId,
  ) {
    return {
      'id': row.syncId,
      'owner_id': ownerId,
      'transaction_sync_id': transactionSyncId,
      'payment_date': row.paymentDate.toUtc().toIso8601String(),
      'amount_paid': row.amountPaid,
      'payment_type': row.paymentType,
      'created_at': row.createdDate.toUtc().toIso8601String(),
      'updated_at': (row.updatedAt ?? row.createdDate).toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  // ── History ──

  static Map<String, dynamic> historyToSupabase(
    HistoryRow row,
    String customerSyncId,
    String? itemSyncId,
    String? transactionSyncId,
    String ownerId,
  ) {
    return {
      'id': row.syncId,
      'owner_id': ownerId,
      'customer_sync_id': customerSyncId,
      'customer_name': row.customerName,
      'contact_number': row.contactNumber,
      'item_sync_id': (itemSyncId != null && itemSyncId.isNotEmpty) ? itemSyncId : null,
      'transaction_sync_id': (transactionSyncId != null && transactionSyncId.isNotEmpty) ? transactionSyncId : null,
      'amount': row.amount,
      'event_date': row.eventDate.toUtc().toIso8601String(),
      'event_type': row.eventType,
      'created_at': row.eventDate.toUtc().toIso8601String(),
      'updated_at': (row.updatedAt ?? row.eventDate).toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }
}
