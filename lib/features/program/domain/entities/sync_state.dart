import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Metadata about the last time a project was synced from a dev laptop
/// to this Pi. Mirrors the `.raccoon/sync_state.json` file written by
/// `raccoon sync` on the toolchain side.
///
/// The file lives at `<projectDir>/.raccoon/sync_state.json` and is excluded
/// from sync, so it represents the state as of the last successful verified
/// push into this project.
class SyncState {
  /// Monotonic counter bumped on every successful verified push.
  /// A value of 0 means "no verified sync on record".
  final int version;

  /// SHA-256 content hash of the project tree at the time of the last sync.
  /// Null when no sync has been recorded yet.
  final String? fingerprint;

  /// ISO-8601 UTC timestamp of the last successful sync, or null.
  final DateTime? syncedAt;

  /// Human identifier for who pushed last, e.g. `tobias@laptop`.
  final String? syncedBy;

  const SyncState({
    required this.version,
    this.fingerprint,
    this.syncedAt,
    this.syncedBy,
  });

  /// Has this project ever had a verified sync recorded?
  bool get hasBeenSynced => version > 0 && fingerprint != null;

  /// Short 12-char prefix of the fingerprint for compact display.
  String? get shortFingerprint => fingerprint?.substring(0, 12);

  factory SyncState.fromJson(Map<String, dynamic> json) {
    DateTime? parsedAt;
    final rawAt = json['synced_at'];
    if (rawAt is String && rawAt.isNotEmpty) {
      parsedAt = DateTime.tryParse(rawAt);
    }
    return SyncState(
      version: (json['version'] as num?)?.toInt() ?? 0,
      fingerprint: json['fingerprint'] as String?,
      syncedAt: parsedAt,
      syncedBy: json['synced_by'] as String?,
    );
  }

  /// Load the sync state for a project directory on disk.
  ///
  /// Returns `null` if the file does not exist or cannot be parsed — callers
  /// should treat that as "no verified sync yet" rather than an error, since
  /// it is a legitimate state for freshly-created projects.
  static Future<SyncState?> loadFromProjectDir(String projectDir) async {
    final file = File(path.join(projectDir, '.raccoon', 'sync_state.json'));
    if (!await file.exists()) return null;
    try {
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);
      if (decoded is Map<String, dynamic>) {
        return SyncState.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
