import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalService {
  static const _storage = FlutterSecureStorage();
  
  // Keys untuk penyimpanan
  static const _keyToken = 'auth_token';
  static const _keyUserData = 'user_data';
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyLastSync = 'last_sync';
  static const _keyAppSettings = 'app_settings';
  
  // Cache di memori untuk status login
  static bool? _isLoggedInCache;
  static bool _isInitialized = false;
  static final _initCompleter = Completer<void>();
  
  // Inisialisasi cache
  static Future<void> _initCache() async {
    if (_isInitialized) return;
    
    try {
      final value = await _storage.read(key: _keyIsLoggedIn);
      _isLoggedInCache = value?.toLowerCase() == 'true';
      _isInitialized = true;
      _initCompleter.complete();
    } catch (e) {
      _isLoggedInCache = false;
      _isInitialized = true;
      _initCompleter.completeError(e);
    }
  }
  
  // Pastikan cache sudah diinisialisasi
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initCache();
    }
    await _initCompleter.future;
  }

  // Simpan token autentikasi
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Ambil token autentikasi
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Hapus token autentikasi (saat logout)
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyToken);
  }

  // Simpan data user
  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: _keyUserData, value: userData);
  }

  // Ambil data user
  static Future<String?> getUserData() async {
    return await _storage.read(key: _keyUserData);
  }

  // Set status login
  static Future<void> setLoggedIn(bool value) async {
    try {
      await _storage.write(key: _keyIsLoggedIn, value: value.toString());
      // Update cache
      _isLoggedInCache = value;
    } catch (e) {
      print('Error in setLoggedIn: $e');
      rethrow;
    }
  }

  // Cek status login (sinkron) - Menggunakan cache di memori
  static bool isLoggedInSync() {
    // Kembalikan nilai cache jika sudah diinisialisasi
    if (_isInitialized) {
      return _isLoggedInCache ?? false;
    }
    
    // Jika belum diinisialisasi, mulai inisialisasi (non-blocking)
    if (!_initCompleter.isCompleted) {
      _initCache().catchError((_) {});
    }
    
    // Default ke false jika belum diinisialisasi
    return false;
  }
  
  // Cek status login (async)
  static Future<bool> isLoggedIn() async {
    try {
      final value = await _storage.read(key: _keyIsLoggedIn);
      return value?.toLowerCase() == 'true';
    } catch (e) {
      print('Error in isLoggedIn: $e');
      return false;
    }
  }

  // Simpan waktu sinkronisasi terakhir
  static Future<void> saveLastSync(DateTime dateTime) async {
    await _storage.write(
      key: _keyLastSync,
      value: dateTime.toIso8601String(),
    );
  }

  // Ambil waktu sinkronisasi terakhir
  static Future<DateTime?> getLastSync() async {
    final value = await _storage.read(key: _keyLastSync);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  // Simpan pengaturan aplikasi
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    final settingsString = settings.entries
        .map((e) => '${e.key}:${e.value}')
        .join(';');
    await _storage.write(key: _keyAppSettings, value: settingsString);
  }

  // Ambil pengaturan aplikasi
  static Future<Map<String, String>> getAppSettings() async {
    final settingsString = await _storage.read(key: _keyAppSettings) ?? '';
    final settings = <String, String>{};
    
    if (settingsString.isNotEmpty) {
      final pairs = settingsString.split(';');
      for (var pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          settings[parts[0]] = parts[1];
        }
      }
    }
    
    return settings;
  }

  // Hapus semua data (saat logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Cek apakah key tertentu ada
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Hapus data dengan key tertentu
  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }
}
