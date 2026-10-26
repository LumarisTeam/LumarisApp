import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createContainer(List<Override> overrides) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  setUp(() async {
    await PrefsService.instance.clear();
  });

  group('BusPageNotifier', () {
    test('should_build_campus_options_from_departure_station', () async {
      final container = createContainer([
        busPageAutoLoadProvider.overrideWithValue(false),
        busPageFetcherProvider.overrideWithValue(
          ({String? dayDate, bool forceRefresh = false}) async => BusModel(
            total: 3,
            records: [
              BusItem(
                lineName: '任意线路1',
                description: '',
                departureStation: '雁塔',
                arrivalStation: '草堂',
                runTime: '08:00:00',
                arrivalStationTime: '01:00',
              ),
              BusItem(
                lineName: '任意线路2',
                description: '',
                departureStation: '草堂',
                arrivalStation: '雁塔',
                runTime: '09:00:00',
                arrivalStationTime: '01:00',
              ),
              BusItem(
                lineName: '任意线路3',
                description: '',
                departureStation: '雁塔',
                arrivalStation: '临潼',
                runTime: '10:00:00',
                arrivalStationTime: '01:00',
              ),
            ],
          ),
        ),
      ]);

      await container.read(busControllerProvider.notifier).selectDateByIndex(0);

      final state = container.read(busControllerProvider);
      expect(state.campusOptions, ['雁塔', '草堂']);
      expect(state.selectedCampus, '雁塔');
      expect(state.busData, hasLength(2));
      expect(
        state.busData.every((item) => item.departureStation == '雁塔'),
        isTrue,
      );
    });

    test(
      'should_keep_original_campus_value_when_station_contains_suffix',
      () async {
        final container = createContainer([
          busPageAutoLoadProvider.overrideWithValue(false),
          busPageFetcherProvider.overrideWithValue(
            ({String? dayDate, bool forceRefresh = false}) async => BusModel(
              total: 2,
              records: [
                BusItem(
                  lineName: '任意线路1',
                  description: '',
                  departureStation: '雁塔校区',
                  arrivalStation: '草堂校区',
                  runTime: '08:00:00',
                  arrivalStationTime: '01:00',
                ),
                BusItem(
                  lineName: '任意线路2',
                  description: '',
                  departureStation: '草堂校区',
                  arrivalStation: '雁塔校区',
                  runTime: '09:00:00',
                  arrivalStationTime: '01:00',
                ),
              ],
            ),
          ),
        ]);

        await container
            .read(busControllerProvider.notifier)
            .selectDateByIndex(0);

        final state = container.read(busControllerProvider);
        expect(state.campusOptions, ['雁塔校区', '草堂校区']);
        expect(state.selectedCampus, '雁塔校区');
        expect(state.busData.single.departureStation, '雁塔校区');
      },
    );

    test(
      'should_keep_selected_campus_when_available_after_date_switch',
      () async {
        var fetchCount = 0;
        final container = createContainer([
          busPageAutoLoadProvider.overrideWithValue(false),
          busPageFetcherProvider.overrideWithValue(({
            String? dayDate,
            bool forceRefresh = false,
          }) async {
            fetchCount++;
            if (fetchCount == 2) {
              return BusModel(
                total: 2,
                records: [
                  BusItem(
                    lineName: '次日线路1',
                    description: '',
                    departureStation: '草堂',
                    arrivalStation: '雁塔',
                    runTime: '08:00:00',
                    arrivalStationTime: '01:00',
                  ),
                  BusItem(
                    lineName: '次日线路2',
                    description: '',
                    departureStation: '雁塔',
                    arrivalStation: '草堂',
                    runTime: '09:00:00',
                    arrivalStationTime: '01:00',
                  ),
                ],
              );
            }
            return BusModel(
              total: 2,
              records: [
                BusItem(
                  lineName: '当日线路1',
                  description: '',
                  departureStation: '雁塔',
                  arrivalStation: '草堂',
                  runTime: '08:00:00',
                  arrivalStationTime: '01:00',
                ),
                BusItem(
                  lineName: '当日线路2',
                  description: '',
                  departureStation: '草堂',
                  arrivalStation: '雁塔',
                  runTime: '09:00:00',
                  arrivalStationTime: '01:00',
                ),
              ],
            );
          }),
        ]);

        final notifier = container.read(busControllerProvider.notifier);
        await notifier.selectDateByIndex(0);
        notifier.selectCampus('草堂');
        await notifier.selectDateByIndex(1);

        final state = container.read(busControllerProvider);
        expect(state.selectedCampus, '草堂');
        expect(state.campusOptions, ['草堂', '雁塔']);
        expect(state.busData, hasLength(1));
        expect(state.busData.single.departureStation, '草堂');
      },
    );

    test('should_use_tile_configuration_for_show_bus_setting', () async {
      await PrefsService.instance.setStringList(PrefsKeys.TILES, [
        '电费',
        '校车',
        '饭卡',
      ]);
      await TileService.saveTileConfigurations(
        TileConfigurationList(
          configurations: const [
            TileConfiguration(id: '电费', order: 0, isVisible: true),
            TileConfiguration(id: '校车', order: 1, isVisible: false),
            TileConfiguration(id: '饭卡', order: 2, isVisible: true),
          ],
          lastModified: DateTime.now(),
        ),
      );

      final container = createContainer([
        busPageFetcherProvider.overrideWithValue(
          ({String? dayDate, bool forceRefresh = false}) async =>
              BusModel(total: 0, records: []),
        ),
      ]);

      container.read(busControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(busControllerProvider);
      expect(state.isShowBus, isFalse);
      expect(state.tiles, isNot(contains('校车')));
    });

    test('should_update_tile_configuration_when_toggling_show_bus', () async {
      await TileService.saveTileConfigurations(
        TileConfigurationList(
          configurations: const [
            TileConfiguration(id: '电费', order: 0, isVisible: true),
            TileConfiguration(id: '校车', order: 1, isVisible: false),
            TileConfiguration(id: '饭卡', order: 2, isVisible: true),
          ],
          lastModified: DateTime.now(),
        ),
      );

      final container = createContainer([
        busPageAutoLoadProvider.overrideWithValue(false),
      ]);
      final notifier = container.read(busControllerProvider.notifier);

      await notifier.toggleShowBus(true);

      var state = container.read(busControllerProvider);
      expect(await TileService.isTileVisible('校车'), isTrue);
      expect(state.isShowBus, isTrue);
      expect(state.tiles, contains('校车'));

      await notifier.toggleShowBus(false);

      state = container.read(busControllerProvider);
      expect(await TileService.isTileVisible('校车'), isFalse);
      expect(state.isShowBus, isFalse);
      expect(state.tiles, isNot(contains('校车')));
    });

    test('should_reload_home_tiles_when_toggling_show_bus', () async {
      await TileService.saveTileConfigurations(
        TileConfigurationList(
          configurations: const [
            TileConfiguration(id: '电费', order: 0, isVisible: true),
            TileConfiguration(id: '校车', order: 1, isVisible: false),
            TileConfiguration(id: '饭卡', order: 2, isVisible: true),
          ],
          lastModified: DateTime.now(),
        ),
      );

      final container = createContainer([
        busPageAutoLoadProvider.overrideWithValue(false),
      ]);

      container.read(tileEditControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        container
            .read(tileEditControllerProvider)
            .config
            .getVisibleTiles()
            .any((tile) => tile.id == '校车'),
        isFalse,
      );

      await container.read(busControllerProvider.notifier).toggleShowBus(true);

      expect(
        container
            .read(tileEditControllerProvider)
            .config
            .getVisibleTiles()
            .any((tile) => tile.id == '校车'),
        isTrue,
      );
    });
  });
}
