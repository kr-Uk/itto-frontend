import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/domain/location/entities/excluded_area.dart';
import 'package:itto/domain/location/entities/h3_grid.dart';
import 'package:itto/domain/location/repositories/location_repository.dart';
import 'package:itto/presentation/location/providers/location_provider.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockLocationRepository mockRepository;
  late LocationProvider provider;

  setUp(() {
    mockRepository = MockLocationRepository();
    provider = LocationProvider(repository: mockRepository);
  });

  group('LocationProvider', () {
    test('initial state', () {
      expect(provider.isMatchingEnabled, isFalse);
      expect(provider.excludedAreas, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.selectedCells, isEmpty);
      expect(provider.gridCells, isEmpty);
      expect(provider.isGridLoading, isFalse);
    });

    group('loadExcludedAreas', () {
      test('success loads excluded areas', () async {
        final areas = [
          const ExcludedArea(
            id: 1,
            name: '집',
            latitude: 37.5,
            longitude: 127.0,
            radius: 200,
          ),
        ];
        when(() => mockRepository.listExcluded())
            .thenAnswer((_) async => areas);

        await provider.loadExcludedAreas();

        expect(provider.excludedAreas, hasLength(1));
        expect(provider.excludedAreas.first.name, equals('집'));
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
      });

      test('ApiException sets error', () async {
        when(() => mockRepository.listExcluded()).thenThrow(
          const ApiException(
            statusCode: 500,
            message: '서버 오류',
            code: 'INTERNAL_ERROR',
          ),
        );

        await provider.loadExcludedAreas();

        expect(provider.error, isNotNull);
        expect(provider.isLoading, isFalse);
      });
    });

    group('addExcludedArea', () {
      test('success adds area and returns true', () async {
        when(() => mockRepository.addExcluded(
              name: any(named: 'name'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radius: any(named: 'radius'),
            )).thenAnswer(
          (_) async => const ExcludedArea(
            id: 1,
            name: '학교',
            latitude: 37.4,
            longitude: 127.2,
            radius: 150,
          ),
        );

        final result = await provider.addExcludedArea(
          name: '학교',
          latitude: 37.4,
          longitude: 127.2,
          radius: 150,
        );

        expect(result, isTrue);
        expect(provider.excludedAreas, hasLength(1));
        expect(provider.excludedAreas.first.name, equals('학교'));
        expect(provider.isLoading, isFalse);
      });

      test('ApiException returns false and sets error', () async {
        when(() => mockRepository.addExcluded(
              name: any(named: 'name'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radius: any(named: 'radius'),
            )).thenThrow(
          const ApiException(
            statusCode: 400,
            message: '제한 초과',
            code: 'EXCLUDED_AREA_LIMIT',
          ),
        );

        final result = await provider.addExcludedArea(
          name: '학교',
          latitude: 37.4,
          longitude: 127.2,
          radius: 150,
        );

        expect(result, isFalse);
        expect(provider.error,
            equals('제외 지역은 최대 3개까지 등록할 수 있어요.'));
      });
    });

    group('deleteExcludedArea', () {
      test('success removes area from list', () async {
        // Pre-populate
        when(() => mockRepository.listExcluded()).thenAnswer(
          (_) async => [
            const ExcludedArea(
              id: 1,
              name: '집',
              latitude: 37.5,
              longitude: 127.0,
              radius: 200,
            ),
            const ExcludedArea(
              id: 2,
              name: '회사',
              latitude: 37.6,
              longitude: 127.1,
              radius: 100,
            ),
          ],
        );
        await provider.loadExcludedAreas();
        expect(provider.excludedAreas, hasLength(2));

        when(() => mockRepository.deleteExcluded(any()))
            .thenAnswer((_) async {});

        final result = await provider.deleteExcludedArea(1);

        expect(result, isTrue);
        expect(provider.excludedAreas, hasLength(1));
        expect(provider.excludedAreas.first.id, equals(2));
      });

      test('ApiException returns false', () async {
        when(() => mockRepository.deleteExcluded(any())).thenThrow(
          const ApiException(
            statusCode: 404,
            message: '없음',
            code: 'EXCLUDED_AREA_NOT_FOUND',
          ),
        );

        final result = await provider.deleteExcludedArea(999);

        expect(result, isFalse);
        expect(provider.error, isNotNull);
      });
    });

    group('loadH3Grid', () {
      test('success loads grid cells and selected indexes', () async {
        when(() => mockRepository.getH3Grid(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              k: any(named: 'k'),
            )).thenAnswer(
          (_) async => const H3Grid(
            cells: [
              H3CellInfo(
                h3Index: 'cell1',
                centerLat: 37.5,
                centerLng: 127.0,
                boundary: [],
              ),
              H3CellInfo(
                h3Index: 'cell2',
                centerLat: 37.6,
                centerLng: 127.1,
                boundary: [],
              ),
            ],
            selectedIndexes: ['cell1'],
          ),
        );

        await provider.loadH3Grid(37.5, 127.0);

        expect(provider.gridCells, hasLength(2));
        expect(provider.selectedCells, equals({'cell1'}));
        expect(provider.isGridLoading, isFalse);
      });

      test('ApiException sets error', () async {
        when(() => mockRepository.getH3Grid(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              k: any(named: 'k'),
            )).thenThrow(
          const ApiException(statusCode: 500, message: '에러'),
        );

        await provider.loadH3Grid(37.5, 127.0);

        expect(provider.error, isNotNull);
        expect(provider.isGridLoading, isFalse);
      });
    });

    group('toggleCell', () {
      test('adds cell when not selected', () {
        final result = provider.toggleCell('cell1');

        expect(result, isTrue);
        expect(provider.selectedCells, contains('cell1'));
      });

      test('removes cell when already selected', () {
        provider.toggleCell('cell1');
        expect(provider.selectedCells, contains('cell1'));

        final result = provider.toggleCell('cell1');

        expect(result, isTrue);
        expect(provider.selectedCells, isNot(contains('cell1')));
      });

      test('returns false when max 20 cells reached', () {
        // Add 20 cells
        for (int i = 0; i < 20; i++) {
          provider.toggleCell('cell_$i');
        }
        expect(provider.selectedCells, hasLength(20));

        final result = provider.toggleCell('cell_extra');

        expect(result, isFalse);
        expect(provider.selectedCells, hasLength(20));
        expect(provider.error,
            equals('제외 셀은 최대 20개까지 선택할 수 있습니다'));
      });
    });

    group('clearSelectedCells', () {
      test('clears all selected cells', () {
        provider.toggleCell('cell1');
        provider.toggleCell('cell2');
        expect(provider.selectedCells, hasLength(2));

        provider.clearSelectedCells();

        expect(provider.selectedCells, isEmpty);
      });
    });

    group('saveExcludedCells', () {
      test('success returns true', () async {
        when(() => mockRepository.saveExcludedCells(any()))
            .thenAnswer((_) async {});

        provider.toggleCell('cell1');
        provider.toggleCell('cell2');

        final result = await provider.saveExcludedCells();

        expect(result, isTrue);
        expect(provider.isLoading, isFalse);
        verify(() => mockRepository.saveExcludedCells(any())).called(1);
      });

      test('ApiException returns false', () async {
        when(() => mockRepository.saveExcludedCells(any())).thenThrow(
          const ApiException(statusCode: 500, message: '저장 실패'),
        );

        final result = await provider.saveExcludedCells();

        expect(result, isFalse);
        expect(provider.error, isNotNull);
        expect(provider.isLoading, isFalse);
      });
    });

    group('clearError', () {
      test('clears error state', () {
        // Trigger an error via toggleCell max
        for (int i = 0; i < 20; i++) {
          provider.toggleCell('c$i');
        }
        provider.toggleCell('extra');
        expect(provider.error, isNotNull);

        provider.clearError();

        expect(provider.error, isNull);
      });
    });
  });
}
