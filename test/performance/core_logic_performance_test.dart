@Tags(['performance'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';

void main() {
  group('Core Logic Performance', () {
    test('reorder_tile_should_finish_within_regression_budget', () {
      final tiles = List<TileConfiguration>.generate(
        1000,
        (index) =>
            TileConfiguration(id: 'tile_$index', order: index, isVisible: true),
      );
      var config = TileConfigurationList(
        configurations: tiles,
        lastModified: DateTime.now(),
      );

      final random = Random(2026);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 400; i++) {
        final oldIndex = random.nextInt(1000);
        final newIndex = random.nextInt(1000);
        final tileId = config.getVisibleTiles()[oldIndex].id;
        config = config.reorderTile(tileId, oldIndex, newIndex);
      }
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(2500));
      expect(config.getVisibleTiles().length, 1000);
    });

    test('toggle_and_normalize_should_finish_within_regression_budget', () {
      final tiles = List<TileConfiguration>.generate(
        250,
        (index) =>
            TileConfiguration(id: 'tile_$index', order: index, isVisible: true),
      );
      var config = TileConfigurationList(
        configurations: tiles,
        lastModified: DateTime.now(),
      );

      final sw = Stopwatch()..start();
      for (var i = 0; i < 150; i++) {
        final tileId = 'tile_${(i % 249) + 1}';
        config = config.toggleVisibility(tileId);
        config = config.toggleVisibility(tileId);
        config = config.normalizeOrders();
      }
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(2000));
      final visible = config.getVisibleTiles();
      for (var i = 0; i < visible.length; i++) {
        expect(visible[i].order, i);
      }
    });

    test('payment_data_from_json_large_payload_should_finish_within_budget',
        () {
      final records = List.generate(
          10000,
          (index) => {
                'turnoverType': index.isEven ? '消费' : '充值',
                'datetimeStr': '2023-01-01 12:00:00',
                'resume': '交易$index',
                'tranamt': index,
              });

      final payload = <String, dynamic>{
        'records': records,
        'balance': 49995000.0,
      };

      final sw = Stopwatch()..start();
      final data = PaymentData.fromJson(payload);
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(2000));
      expect(data.payments.length, 10000);
    });
  });
}
