import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/features/education/services/auth_service.dart';
import 'package:ios_club_app/features/education/services/auth_session_guard.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  const String fallbackPrefix = 'secure_storage_fallback.';
  final Map<String, String> store = <String, String>{};
  final List<MethodCall> calls = <MethodCall>[];
  final SecureStorageService service = SecureStorageService.instance;

  setUpAll(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });

  setUp(() async {
    await PrefsService.instance.clear();
    store.clear();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          final Map<dynamic, dynamic> arguments =
              call.arguments as Map<dynamic, dynamic>;
          final String? key = arguments['key'] as String?;
          switch (call.method) {
            case 'write':
              store[key!] = arguments['value'] as String;
            case 'read':
              return store[key];
            case 'delete':
              store.remove(key);
            case 'deleteAll':
              store.clear();
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('macOS secure storage', () {
    test('should_use_login_keychain_when_running_unsigned_debug', () async {
      expect(await service.write(key: 'token', value: 'value'), isTrue);
      final Map<dynamic, dynamic> options =
          calls.single.arguments['options'] as Map<dynamic, dynamic>;
      expect(options['usesDataProtectionKeychain'], 'false');
    });

    test('should_migrate_fallback_when_keychain_read_returns_null', () async {
      await PrefsService.instance.setString('${fallbackPrefix}token', 'legacy');

      expect(await service.read(key: 'token'), 'legacy');
      expect(store['token'], 'legacy');
      expect(
        PrefsService.instance.containsKey('${fallbackPrefix}token'),
        isFalse,
      );
    });

    test('should_remove_stale_fallback_when_keychain_write_succeeds', () async {
      await PrefsService.instance.setString('${fallbackPrefix}token', 'old');

      expect(await service.write(key: 'token', value: 'new'), isTrue);
      expect(store['token'], 'new');
      expect(
        PrefsService.instance.containsKey('${fallbackPrefix}token'),
        isFalse,
      );
    });

    test('should_remove_fallback_when_deleting_key_or_writing_null', () async {
      for (final String key in <String>['delete', 'null']) {
        store[key] = 'value';
        await PrefsService.instance.setString('$fallbackPrefix$key', 'old');
      }

      expect(await service.delete(key: 'delete'), isTrue);
      expect(await service.write(key: 'null', value: null), isTrue);
      expect(store, isEmpty);
      expect(PrefsService.instance.getKeys(), isEmpty);
    });

    test(
      'should_preserve_other_preferences_when_deleting_all_secrets',
      () async {
        store['token'] = 'value';
        await PrefsService.instance.setString('${fallbackPrefix}token', 'old');
        await PrefsService.instance.setString('theme', 'dark');

        expect(await service.deleteAll(), isTrue);
        expect(store, isEmpty);
        expect(PrefsService.instance.getKeys(), <String>{'theme'});
      },
    );

    test('should_keep_fallback_when_keychain_migration_fails', () async {
      await PrefsService.instance.setString('${fallbackPrefix}token', 'legacy');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            if (call.method == 'write') {
              throw PlatformException(code: '-34018');
            }
            return null;
          });

      expect(await service.read(key: 'token'), 'legacy');
      expect(
        PrefsService.instance.getString('${fallbackPrefix}token'),
        'legacy',
      );
    });

    test('should_migrate_credentials_when_keychain_write_succeeds', () async {
      final Map<String, String> credentials = <String, String>{
        PrefsKeys.USERNAME: 'student',
        PrefsKeys.PASSWORD: 'password',
        PrefsKeys.PAYMENT_NUM: '123456',
      };
      for (final MapEntry<String, String> entry in credentials.entries) {
        await PrefsService.instance.setString(entry.key, entry.value);
      }

      await AuthService.migrateCredentials();

      expect(store, credentials);
      expect(PrefsService.instance.getKeys(), isEmpty);
    });

    test(
      'should_revoke_migrated_credential_when_logout_occurs_during_write',
      () async {
        await PrefsService.instance.setString(PrefsKeys.USERNAME, 'student');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall call) async {
              final String key = call.arguments['key'] as String;
              if (call.method == 'write') {
                store[key] = call.arguments['value'] as String;
                AuthSessionGuard.invalidate();
                await PrefsService.instance.remove(key);
              } else if (call.method == 'delete') {
                store.remove(key);
              }
              return null;
            });

        await AuthService.migrateCredentials();

        expect(store, isEmpty);
        expect(PrefsService.instance.getKeys(), isEmpty);
      },
    );
  }, skip: !Platform.isMacOS);
}
