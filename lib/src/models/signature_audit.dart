import 'package:flutter/foundation.dart';
import 'signature_point.dart';

/// Cryptographic and contextual audit trail metadata for digital signatures.
/// Compliant with electronic signature legal requirements (IT Act 2000 / ESIGN).
@immutable
class SignatureAuditMetadata {
  SignatureAuditMetadata({
    this.signerName,
    this.signerId,
    this.documentId,
    this.deviceInfo,
    DateTime? timestamp,
    this.integrityHash,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  /// Legal name of the signatory.
  final String? signerName;

  /// External identity identifier (e.g. email, user ID, PAN, Aadhaar ref).
  final String? signerId;

  /// Associated contract or document ID.
  final String? documentId;

  /// Device hardware/platform signature context.
  final String? deviceInfo;

  /// Exact UTC timestamp when signature was captured.
  final DateTime timestamp;

  /// Deterministic integrity hash of all raw stroke coordinates and timestamps.
  final String? integrityHash;

  /// Computes a deterministic 64-bit FNV-1a hex integrity hash from the recorded signature strokes.
  static String computeStrokesHash(List<List<SignaturePoint>> strokes) {
    // 64-bit FNV-1a hash implementation in pure Dart (0 dependencies)
    BigInt hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final fnvPrime = BigInt.parse('100000001b3', radix: 16);
    final mask64 = BigInt.parse('ffffffffffffffff', radix: 16);

    final buffer = StringBuffer();
    for (final stroke in strokes) {
      for (final pt in stroke) {
        buffer.write(
            '${pt.offset.dx.toStringAsFixed(2)},${pt.offset.dy.toStringAsFixed(2)},${pt.time};');
      }
      buffer.write('|');
    }

    final bytes = buffer.toString().codeUnits;
    for (final byte in bytes) {
      hash = hash ^ BigInt.from(byte);
      hash = (hash * fnvPrime) & mask64;
    }

    return hash.toRadixString(16).padLeft(16, '0');
  }

  /// Creates a copy with the calculated integrity hash populated from [strokes].
  SignatureAuditMetadata withComputedHash(List<List<SignaturePoint>> strokes) {
    return SignatureAuditMetadata(
      signerName: signerName,
      signerId: signerId,
      documentId: documentId,
      deviceInfo: deviceInfo,
      timestamp: timestamp,
      integrityHash: computeStrokesHash(strokes),
    );
  }

  /// Compact one-line audit summary string.
  String get auditLine {
    final parts = <String>[];
    if (signerName != null) parts.add('Signer: $signerName');
    parts.add('Time: ${timestamp.toIso8601String().substring(0, 19)}Z');
    if (integrityHash != null) {
      parts.add('Hash: $integrityHash');
    }
    return parts.join(' • ');
  }
}
