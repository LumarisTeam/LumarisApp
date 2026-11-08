import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/prefs_keys.dart' show PrefsKeys;

import '../core/services/prefs_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/utils/stale_request_guard.dart';
import '../features/education/apis/payment_api.dart';
import '../features/education/models/payment_model.dart';
import '../features/education/models/payment_qr_code.dart';
import '../features/education/services/payment_service.dart';
import '../features/system/tile_service.dart';
import 'app_states.dart';
import 'tile_edit_notifier.dart';
import 'tile_store_providers.dart';
import 'user_store.dart';

typedef PaymentDataFetcher =
    Future<PaymentData> Function(String cardNumber, String? password);
typedef StudentIsLoginReader = bool Function();
typedef PaymentStudentIdReader = Future<String?> Function();
typedef PaymentPasswordReader = Future<String?> Function();
typedef TileVisibilityReader = Future<bool> Function(String tileId);
typedef TileMutator = Future<void> Function(String tileId);
typedef PaymentPasswordWriter = Future<bool> Function(String? password);

typedef PaymentQrFetcher =
    Future<PaymentQrCode> Function(String cardNumber, String? password);

final paymentDataFetcherProvider = Provider<PaymentDataFetcher>((ref) {
  return PaymentService.fetchData;
});

final paymentQrFetcherProvider = Provider<PaymentQrFetcher>((ref) {
  return PaymentApi.getPaymentQrCodePayload;
});

final studentIsLoginReaderProvider = Provider<StudentIsLoginReader>((ref) {
  return () => ref.read(userStoreProvider).isLogin;
});

final paymentStudentIdReaderProvider = Provider<PaymentStudentIdReader>((ref) {
  return () async {
    final secureStorage = SecureStorageService.instance;
    final prefs = PrefsService.instance;
    return await secureStorage.read(key: PrefsKeys.USERNAME) ??
        prefs.getString(PrefsKeys.USERNAME);
  };
});

final paymentPasswordReaderProvider = Provider<PaymentPasswordReader>((ref) {
  return () async {
    final secureStorage = SecureStorageService.instance;
    final prefs = PrefsService.instance;
    return await secureStorage.read(key: PrefsKeys.PAYMENT_PASSWORD) ??
        prefs.getString(PrefsKeys.PAYMENT_PASSWORD);
  };
});

final paymentPasswordWriterProvider = Provider<PaymentPasswordWriter>((ref) {
  return (password) async {
    final secureStorage = SecureStorageService.instance;
    final normalizedPassword = password == null || password.trim().isEmpty
        ? null
        : password.trim();
    final writeSuccess = await secureStorage.write(
      key: PrefsKeys.PAYMENT_PASSWORD,
      value: normalizedPassword,
    );
    final prefs = PrefsService.instance;
    if (normalizedPassword == null) {
      await prefs.remove(PrefsKeys.PAYMENT_PASSWORD);
    } else {
      await prefs.setString(PrefsKeys.PAYMENT_PASSWORD, normalizedPassword);
    }
    return writeSuccess;
  };
});

final tileVisibilityReaderProvider = Provider<TileVisibilityReader>((ref) {
  return TileService.isTileVisible;
});

final tileAdderProvider = Provider<TileMutator>((ref) {
  return TileService.addTile;
});

final tileRemoverProvider = Provider<TileMutator>((ref) {
  return TileService.removeTile;
});

final paymentStoreProvider = NotifierProvider<PaymentStore, PaymentState>(
  PaymentStore.new,
);

class PaymentStore extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    if (ref.read(tileStoreAutoLoadProvider)) {
      Future<void>.microtask(loadData);
    }
    return PaymentState(
      openQrCodeFromTile:
          PrefsService.instance.getBool(PrefsKeys.PAYMENT_TILE_OPEN_QR_CODE) ??
          false,
    );
  }

  bool get isLoading => state.isLoading;
  String get errorMessage => state.errorMessage;
  List<PaymentModel> get records => List.unmodifiable(state.records);
  double get totalRecharge => state.totalRecharge;
  bool get isShowTile => state.isShowTile;
  String get password => state.password;

  final _loadGuard = StaleRequestGuard();
  int _tileVisibilityRevision = 0;
  bool _isUpdatingTileVisibility = false;

  Future<void> loadData() async {
    final requestId = _loadGuard.beginRequest();
    final tileVisibilityRevision = _tileVisibilityRevision;
    final shouldUpdateTileVisibility = !_isUpdatingTileVisibility;
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');

      // 磁贴设置独立于余额请求，未登录或请求失败时也应正确显示。
      final isVisible = await ref.read(tileVisibilityReaderProvider)('饭卡');
      if (!_loadGuard.isCurrent(requestId)) return;
      if (shouldUpdateTileVisibility &&
          tileVisibilityRevision == _tileVisibilityRevision) {
        state = state.copyWith(isShowTile: isVisible);
      }

      final studentId = await ref.read(paymentStudentIdReaderProvider)();
      final password = await ref.read(paymentPasswordReaderProvider)();

      if (studentId == null || studentId.isEmpty) {
        if (!_loadGuard.isCurrent(requestId)) return;
        state = state.copyWith(
          errorMessage: 'auth_required',
          password: password ?? '',
        );
        return;
      }

      final recordsResult = await ref.read(paymentDataFetcherProvider)(
        studentId,
        password,
      );

      if (!_loadGuard.isCurrent(requestId)) return;

      state = state.copyWith(
        records: recordsResult.payments,
        totalRecharge: recordsResult.balance,
        hasData: true,
        password: password ?? '',
      );
    } catch (e) {
      if (!_loadGuard.isCurrent(requestId)) return;
      final password = await ref.read(paymentPasswordReaderProvider)();
      state = state.copyWith(
        errorMessage: 'load_failed',
        password: password ?? '',
      );
    } finally {
      if (_loadGuard.isCurrent(requestId)) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<bool> savePassword(String password) async {
    final normalizedPassword = password.trim();
    final success = await ref.read(paymentPasswordWriterProvider)(
      normalizedPassword.isEmpty ? null : normalizedPassword,
    );
    state = state.copyWith(password: normalizedPassword);
    return success;
  }

  Future<void> setOpenQrCodeFromTile(bool value) async {
    await PrefsService.instance.setBool(
      PrefsKeys.PAYMENT_TILE_OPEN_QR_CODE,
      value,
    );
    state = state.copyWith(openQrCodeFromTile: value);
  }

  Future<void> toggleTileShow(bool value) async {
    _tileVisibilityRevision++;
    _isUpdatingTileVisibility = true;
    state = state.copyWith(isShowTile: value);
    try {
      if (value) {
        await ref.read(tileAdderProvider)('饭卡');
      } else {
        await ref.read(tileRemoverProvider)('饭卡');
      }

      await ref.read(tileEditControllerProvider.notifier).reload();
    } finally {
      _isUpdatingTileVisibility = false;
    }
  }
}
