import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/data/location/datasources/location_remote_datasource.dart';
import 'package:itto/data/location/models/excluded_area_model.dart';
import 'package:itto/data/location/models/h3_grid_model.dart';
import 'package:itto/data/location/models/location_toggle_model.dart';
import 'package:itto/data/location/repositories/location_repository_impl.dart';

class MockLocationRemoteDataSource extends Mock
    implements LocationRemoteDataSource {}

void main() {
  late MockLocationRemoteDataSource mockRemoteDataSource;
  late LocationRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockLocationRemoteDataSource();
    repository =
        LocationRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('LocationRepositoryImpl', () {
    group('sendLocation', () {
      test('delegates to remote data source with correct parameters', () async {
        when(() => mockRemoteDataSource.sendLocation(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              accuracy: any(named: 'accuracy'),
              timestamp: any(named: 'timestamp'),
            )).thenAnswer((_) async {});

        await repository.sendLocation(
          latitude: 37.5665,
          longitude: 126.978,
          accuracy: 10.0,
          timestamp: '2026-03-17T10:00:00',
        );

        verify(() => mockRemoteDataSource.sendLocation(
              latitude: 37.5665,
              longitude: 126.978,
              accuracy: 10.0,
              timestamp: '2026-03-17T10:00:00',
            )).called(1);
      });
    });

    group('toggle', () {
      test('returns entity from remote data source', () async {
        when(() => mockRemoteDataSource.toggle(any())).thenAnswer(
          (_) async => const LocationToggleModel(
            enabled: true,
            message: '활성화',
          ),
        );

        final result = await repository.toggle(true);

        expect(result.enabled, isTrue);
        expect(result.message, equals('활성화'));
        verify(() => mockRemoteDataSource.toggle(true)).called(1);
      });
    });

    group('listExcluded', () {
      test('returns list of ExcludedArea entities', () async {
        final models = [
          const ExcludedAreaModel(
            id: 1,
            name: '집',
            latitude: 37.5,
            longitude: 127.0,
            radius: 200,
          ),
          const ExcludedAreaModel(
            id: 2,
            name: '회사',
            latitude: 37.6,
            longitude: 127.1,
            radius: 100,
          ),
        ];
        when(() => mockRemoteDataSource.listExcluded())
            .thenAnswer((_) async => models);

        final result = await repository.listExcluded();

        expect(result, hasLength(2));
        expect(result[0].name, equals('집'));
        expect(result[1].name, equals('회사'));
      });

      test('returns empty list when no excluded areas', () async {
        when(() => mockRemoteDataSource.listExcluded())
            .thenAnswer((_) async => []);

        final result = await repository.listExcluded();

        expect(result, isEmpty);
      });
    });

    group('addExcluded', () {
      test('returns entity from remote data source', () async {
        when(() => mockRemoteDataSource.addExcluded(
              name: any(named: 'name'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radius: any(named: 'radius'),
            )).thenAnswer(
          (_) async => const ExcludedAreaModel(
            id: 3,
            name: '학교',
            latitude: 37.4,
            longitude: 127.2,
            radius: 150,
          ),
        );

        final result = await repository.addExcluded(
          name: '학교',
          latitude: 37.4,
          longitude: 127.2,
          radius: 150,
        );

        expect(result.id, equals(3));
        expect(result.name, equals('학교'));
      });
    });

    group('deleteExcluded', () {
      test('delegates to remote data source', () async {
        when(() => mockRemoteDataSource.deleteExcluded(any()))
            .thenAnswer((_) async {});

        await repository.deleteExcluded(1);

        verify(() => mockRemoteDataSource.deleteExcluded(1)).called(1);
      });
    });

    group('getH3Grid', () {
      test('returns entity from remote data source', () async {
        when(() => mockRemoteDataSource.getH3Grid(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              k: any(named: 'k'),
            )).thenAnswer(
          (_) async => const H3GridModel(
            cells: [
              H3CellInfoModel(
                h3Index: 'abc',
                centerLat: 37.5,
                centerLng: 127.0,
                boundary: [],
              ),
            ],
            selectedIndexes: ['abc'],
          ),
        );

        final result = await repository.getH3Grid(
          latitude: 37.5,
          longitude: 127.0,
        );

        expect(result.cells, hasLength(1));
        expect(result.selectedIndexes, equals(['abc']));
      });
    });

    group('saveExcludedCells', () {
      test('delegates to remote data source', () async {
        when(() => mockRemoteDataSource.saveExcludedCells(any()))
            .thenAnswer((_) async {});

        await repository.saveExcludedCells(['cell1', 'cell2']);

        verify(() => mockRemoteDataSource.saveExcludedCells(['cell1', 'cell2']))
            .called(1);
      });
    });
  });
}
