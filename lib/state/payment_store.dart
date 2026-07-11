import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart' show PrefsKeys;
import 'package:ios_club_app/state/tile_store_providers.dart';
import 'package:ios_club_app/state/user_store.dart';

typedef PaymentDataFetcher = Future<PaymentData> Function(
  String cardNumber,
  String? password,
);
typedef StudentIsLoginReader = bool Function();
typedef PaymentStudentIdReader = Future<String?> Function();
typedef PaymentPasswordReader = Future<String?> Function();
typedef TileVisibilityReader = Future<bool> Function(String tileId);
typedef TileMutator = Future<void> Function(String tileId);
typedef PaymentPasswordWriter = Future<bool> Function(String? password);

final paymentDataFetcherProvider = Provider<PaymentDataFetcher>((ref) {
  return (cardId, password) async {
    final result =
        await ref.read(paymentRepositoryProvider).getPayment(cardId, password);
    if (!result.isSuccess) throw result.error;
    return result.data;
  };
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
    final normalizedPassword =
        password == null || password.trim().isEmpty ? null : password.trim();
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

final paymentStoreProvider =
    NotifierProvider<PaymentStore, PaymentState>(PaymentStore.new);

class PaymentStore extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    if (ref.read(tileStoreAutoLoadProvider)) {
      Future<void>.microtask(loadData);
    }
    return const PaymentState();
  }

  bool get isLoading => state.isLoading;
  String get errorMessage => state.errorMessage;
  List<PaymentModel> get records => List.unmodifiable(state.records);
  double get totalRecharge => state.totalRecharge;
  bool get isShowTile => state.isShowTile;
  String get password => state.password;

  int _loadCount = 0;

  Future<void> loadData() async {
    final currentLoadId = ++_loadCount;
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');

      final studentId = await ref.read(paymentStudentIdReaderProvider)();
      final password = await ref.read(paymentPasswordReaderProvider)();

      if (studentId == null || studentId.isEmpty) {
        if (currentLoadId != _loadCount) return;
        state = state.copyWith(
          errorMessage: 'auth_required',
          password: password ?? '',
        );
        return;
      }

      final recordsResult =
          await ref.read(paymentDataFetcherProvider)(studentId, password);
      final isVisible = await ref.read(tileVisibilityReaderProvider)('饭卡');

      if (currentLoadId != _loadCount) return;

      state = state.copyWith(
        records: recordsResult.payments,
        totalRecharge: recordsResult.balance,
        isShowTile: isVisible,
        hasData: true,
        password: password ?? '',
      );
    } catch (e) {
      if (currentLoadId != _loadCount) return;
      final password = await ref.read(paymentPasswordReaderProvider)();
      state = state.copyWith(
        errorMessage: 'load_failed',
        password: password ?? '',
      );
    } finally {
      if (currentLoadId == _loadCount) {
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

  Future<void> toggleTileShow(bool value) async {
    state = state.copyWith(isShowTile: value);
    if (value) {
      await ref.read(tileAdderProvider)('饭卡');
    } else {
      await ref.read(tileRemoverProvider)('饭卡');
    }

    await ref.read(tileEditControllerProvider.notifier).reload();
  }
}
