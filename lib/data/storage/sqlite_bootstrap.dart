import 'package:flutter/foundation.dart';

import 'sqlite_bootstrap_io.dart'
    if (dart.library.html) 'sqlite_bootstrap_web.dart';

/// Configure the correct SQLite factory for the current platform.
Future<void> bootstrapSqlite() => bootstrapSqliteImpl();

/// Whether SQLite can be used on this runtime.
bool get sqliteSupported => !kIsWeb;

/// Exposed for tests — returns null on web.
Object? get activeDatabaseFactory => activeDatabaseFactoryImpl();
