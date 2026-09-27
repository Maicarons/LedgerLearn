import 'local_store.dart';
import 'local_store_io.dart'
    if (dart.library.html) 'local_store_web.dart';

/// Platform factory for LocalStore.
///
/// IO platforms get the SQLite implementation; web gets a GetStorage-backed
/// store so the tree never imports `dart:io` / `sqflite` on the browser.
LocalStore createLocalStore() => createStoreImpl();
