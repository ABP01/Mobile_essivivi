import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/repositories/sales_repository.dart';

// Enhanced SyncService for offline delivery proof management
class SyncService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SalesRepository _salesRepo = SalesRepository();
  final Connectivity _connectivity = Connectivity();

  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _pendingProofsKey = 'pending_delivery_proofs';
  static const String _syncStatusKey = 'sync_status';

  Future<void> queueDeliveryProof(
    int deliveryId,
    Map<String, dynamic> proofData,
  ) async {
    try {
      // Get existing pending proofs
      final existingData = await _storage.read(key: _pendingProofsKey);
      Map<String, dynamic> pendingProofs = existingData != null
          ? jsonDecode(existingData)
          : {};

      // Add new proof with timestamp
      pendingProofs[deliveryId.toString()] = {
        'data': proofData,
        'timestamp': DateTime.now().toIso8601String(),
        'attempts': 0,
      };

      // Save back to storage
      await _storage.write(
        key: _pendingProofsKey,
        value: jsonEncode(pendingProofs),
      );

      // Try to sync immediately if online
      final connectivityResults = await _connectivity.checkConnectivity();
      if (!connectivityResults.contains(ConnectivityResult.none)) {
        await sync();
      }
    } catch (e) {
      print('Error queuing delivery proof: $e');
      rethrow;
    }
  }

  Future<void> sync() async {
    try {
      final existingData = await _storage.read(key: _pendingProofsKey);
      if (existingData == null) return;

      final pendingProofs = jsonDecode(existingData) as Map<String, dynamic>;
      final successfulSyncs = <String>[];
      final failedSyncs = <String>[];

      for (final entry in pendingProofs.entries) {
        final deliveryId = entry.key;
        final proofInfo = entry.value as Map<String, dynamic>;

        try {
          // Attempt to sync with backend
          await _salesRepo.submitDeliveryProof(
            int.parse(deliveryId),
            proofInfo['data'],
          );

          successfulSyncs.add(deliveryId);
        } catch (e) {
          print('Failed to sync delivery $deliveryId: $e');

          // Increment attempts
          proofInfo['attempts'] = (proofInfo['attempts'] ?? 0) + 1;
          proofInfo['lastError'] = e.toString();

          // Remove if too many attempts (max 5)
          if (proofInfo['attempts'] >= 5) {
            failedSyncs.add(deliveryId);
          }
        }
      }

      // Update storage - remove successful syncs
      final updatedProofs = Map<String, dynamic>.from(pendingProofs);
      successfulSyncs.forEach(updatedProofs.remove);
      failedSyncs.forEach(
        updatedProofs.remove,
      ); // Also remove failed ones after max attempts

      if (updatedProofs.isEmpty) {
        await _storage.delete(key: _pendingProofsKey);
      } else {
        await _storage.write(
          key: _pendingProofsKey,
          value: jsonEncode(updatedProofs),
        );
      }

      // Update sync status
      await _storage.write(
        key: _syncStatusKey,
        value: jsonEncode({
          'lastSync': DateTime.now().toIso8601String(),
          'successful': successfulSyncs.length,
          'failed': failedSyncs.length,
          'pending': updatedProofs.length,
        }),
      );
    } catch (e) {
      print('Error during sync: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final statusData = await _storage.read(key: _syncStatusKey);
      if (statusData != null) {
        return jsonDecode(statusData);
      }
      return {'lastSync': null, 'successful': 0, 'failed': 0, 'pending': 0};
    } catch (e) {
      return {'lastSync': null, 'successful': 0, 'failed': 0, 'pending': 0};
    }
  }

  Future<int> getPendingProofsCount() async {
    try {
      final existingData = await _storage.read(key: _pendingProofsKey);
      if (existingData == null) return 0;

      final pendingProofs = jsonDecode(existingData) as Map<String, dynamic>;
      return pendingProofs.length;
    } catch (e) {
      return 0;
    }
  }
}
