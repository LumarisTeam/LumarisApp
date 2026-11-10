import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/services/warehouse_repo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('iOS bundled catalog has a script for every listed adapter', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final service = WarehouseRepoService.instance;
    final registry = await service.refresh();
    expect(registry.adapterCount, greaterThan(0));
    for (final school in registry.schools) {
      for (final adapter in school.adapters) {
        expect(
          await service.loadScript(adapter),
          isNotEmpty,
          reason: '${school.id}: ${adapter.adapterId}',
        );
      }
    }
  });
}
