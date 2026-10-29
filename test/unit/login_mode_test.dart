import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/login_mode.dart';
import 'package:ios_club_app/features/education/services/login_mode_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  setUp(() async {
    await PrefsService.instance.clear();
  });

  group('LoginMode', () {
    test('fromValue should map 1 to graduate and everything else to undergrad', () {
      expect(LoginMode.fromValue(1), LoginMode.graduate);
      expect(LoginMode.fromValue(0), LoginMode.undergraduate);
      expect(LoginMode.fromValue(null), LoginMode.undergraduate);
      expect(LoginMode.fromValue(9), LoginMode.undergraduate);
    });

    test('header values should match the backend contract', () {
      expect(LoginMode.undergraduate.value, 0);
      expect(LoginMode.graduate.value, 1);
    });
  });

  group('LoginModeService', () {
    test('should default to undergraduate when nothing was recorded', () {
      expect(LoginModeService.current, LoginMode.undergraduate);
      expect(LoginModeService.currentHeaderValue, '0');
    });

    test('should persist and read the selected mode', () async {
      await LoginModeService.save(LoginMode.graduate);

      expect(PrefsService.instance.getInt(PrefsKeys.LOGIN_MODE), 1);
      expect(LoginModeService.current, LoginMode.graduate);
      expect(LoginModeService.currentHeaderValue, '1');
    });

    test('should fall back to undergraduate for unknown stored values', () async {
      await PrefsService.instance.setInt(PrefsKeys.LOGIN_MODE, 7);

      expect(LoginModeService.current, LoginMode.undergraduate);
    });
  });
}
