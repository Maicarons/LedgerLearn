import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Configure the correct SQLite factory for the current platform.
///
/// - Android / iOS: stock `sqflite`
/// - Windows / Linux / macOS / tests: `databaseFactoryFfi`
/// - Web: stock sqflite is unavailable; callers should keep a web fallback
Future<void> bootstrapSqlite() async {
  if (kIsWeb) return;
  final platform = defaultTargetPlatform;
  final isDesktop = platform == TargetPlatform.windows ||
      platform == TargetPlatform.linux ||
      platform == TargetPlatform.macOS;
  if (isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

/// Whether SQLite can be used on this runtime.
bool get sqliteSupported => !kIsWeb;

/// Exposed for tests.
DatabaseFactory get activeDatabaseFactory => databaseFactory;
