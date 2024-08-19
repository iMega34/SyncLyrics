
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SettingsState {
  /// State for the settings provider
  /// 
  /// Parameters:
  /// - [musixmatchApiKey] is the API key for the Musixmatch API
  /// - [downloadDirectory] is the directory where downloaded files are stored
  /// - [theme] is the theme mode of the app
  const SettingsState({
    this.musixmatchApiKey,
    this.downloadDirectory,
    this.theme = ThemeMode.system
  });

  // Class attributes
  final String? musixmatchApiKey;
  final String? downloadDirectory;
  final ThemeMode theme;

  /// Copy the current state with new values
  /// 
  /// Parameters:
  /// - [musixmatchApiKey] is the API key for the Musixmatch API as a [String]
  /// - [downloadDirectory] is the directory where downloaded files are stored as a [String]
  /// - [theme] is the theme mode of the app as a [ThemeMode]
  SettingsState copyWith({
    String? musixmatchApiKey,
    String? downloadDirectory,
    ThemeMode? theme
  }) => SettingsState(
    musixmatchApiKey: musixmatchApiKey ?? this.musixmatchApiKey,
    downloadDirectory: downloadDirectory ?? this.downloadDirectory,
    theme: theme ?? this.theme
  );

  /// Clear the Musixmatch API key, effectively resetting it to `null`
  /// 
  /// Returns:
  /// - A new [SettingsState] with [musixmatchApiKey] set to `null`
  SettingsState clearMusixmatchApiKey() => SettingsState(
    musixmatchApiKey: null,
    downloadDirectory: downloadDirectory,
    theme: theme
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  /// Settings provider
  /// 
  /// Stores the settings for the app and implements methods to support editing
  /// the Musixmatch API key, download directory, and theme mode
  /// 
  /// The initial state is an empty state, with no settings
  SettingsNotifier() : super(const SettingsState());

  /// Initialize the settings from the local settings database
  /// 
  /// Reads the settings from the local SQLite database and updates the state
  /// with the values found. Only used once when the app is initialized
  Future<void> initializeSettings() async {
    final query = await _fetchSettings();
    state = state.copyWith(
      musixmatchApiKey: query['musixmatchApiKey'],
      downloadDirectory: query['downloadDirectory'],
      theme: ThemeMode.values.firstWhere(
        (e) => e.toString() == query['theme'],
        orElse: () => ThemeMode.system
      )
    );
  }

  /// Save the Musixmatch API key to the local settings database
  /// 
  /// Parameters:
  /// - [musixmatchApiKey] is the API key for the Musixmatch API as a [String]
  Future<void> saveMusixmatchApiKey(String musixmatchApiKey) async {
    await _handleUpdateTransaction('musixmatchApiKey', musixmatchApiKey);
    state = state.copyWith(musixmatchApiKey: musixmatchApiKey);
  }

  /// Clear the Musixmatch API key from the local settings database
  Future<void> clearMusixmatchApiKey() async {
    await _handleUpdateTransaction('musixmatchApiKey', null);
    state = state.clearMusixmatchApiKey();
  }

  /// Save the download directory to the local settings database
  /// 
  /// Parameters:
  /// - [downloadDirectory] is the directory where downloaded files are stored as a [String]
  Future<void> saveDownloadDirectory(String downloadDirectory) async {
    await _handleUpdateTransaction('downloadDirectory', downloadDirectory);
    state = state.copyWith(downloadDirectory: downloadDirectory);
  }

  /// Set the theme mode of the app
  /// 
  /// Parameters:
  /// - [theme] is the theme mode of the app as a [ThemeMode]
  Future<void> setTheme(ThemeMode theme) async {
    await _handleUpdateTransaction('theme', theme.toString());
    state = state.copyWith(theme: theme);
  }

  /// Fetch the settings from the local settings database
  /// 
  /// Returns:
  /// - A [Map] with the settings found in the local settings database
  Future<Map<String, dynamic>> _fetchSettings() async {
    // Get the path to the local settings database
    final path = '${await getDatabasesPath()}\\settings.db';
    const sql = '''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY,
        musixmatchApiKey TEXT,
        downloadDirectory TEXT,
        theme TEXT
      )
    ''';

    // Open the database and create the settings table if it doesn't exist
    final database = await openDatabase(
      path, version: 1,
      onCreate: (db, version) async {
        final downloadsDirectory = await getDownloadsDirectory();
        await db.execute(sql);
        await db.insert('settings', {
          'id': 1,
          'musixmatchApiKey': null,
          'downloadDirectory': downloadsDirectory,
          'theme': ThemeMode.system.toString(),
        });
      },
    );

    // Get the settings from the database, closing the connection afterwards
    final query = await database.query('settings');
    await database.close();

    return query.isNotEmpty ? Map<String, dynamic>.from(query.first) : {};
  }

  /// Handle the transaction to update the settings in the local settings database
  /// 
  /// Parameters:
  /// - [config] is the setting to update as a [String]
  /// - [value] is the new value for the setting as a [String]
  Future<void> _handleUpdateTransaction(String config, String? value) async {
    // Get the path to the local settings database
    final path = '${await getDatabasesPath()}\\settings.db';
    final database = await openDatabase(path);

    // Update the setting in the database, closing the connection afterwards
    await database.transaction((txn) async
      => await txn.update(
        'settings',
        {config : value},
        where: 'id = ?',
        whereArgs: [1],
        conflictAlgorithm: ConflictAlgorithm.replace
      )
    );

    await database.close();
  }
}

/// Settings provider
/// 
/// Stores the settings for the app and implements methods to support editing
/// the Musixmatch API key, download directory, and theme mode
/// 
/// The initial state is an empty state, with no settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier()
);
