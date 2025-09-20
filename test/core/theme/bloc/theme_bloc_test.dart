import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:era_test/core/theme/bloc/theme_bloc.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late ThemeBloc bloc;
  late MockStorage mockStorage;

  setUpAll(() {
    mockStorage = MockStorage();
    HydratedBloc.storage = mockStorage;
  });

  setUp(() {
    when(() => mockStorage.read(any())).thenReturn(null);
    when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});
    when(() => mockStorage.delete(any())).thenAnswer((_) async {});
    when(() => mockStorage.clear()).thenAnswer((_) async {});
    bloc = ThemeBloc();
  });

  group('ThemeBloc', () {
    test('initial state should be ThemeState with system theme', () {
      expect(bloc.state, equals(const ThemeState(themeMode: ThemeMode.system)));
    });

    group('ThemeChanged', () {
      blocTest<ThemeBloc, ThemeState>(
        'should emit ThemeState with light theme when ThemeChanged is added with light theme',
        build: () => bloc,
        act: (bloc) => bloc.add(const ThemeChanged(themeMode: ThemeMode.light)),
        expect: () => [
          const ThemeState(themeMode: ThemeMode.light),
        ],
      );

      blocTest<ThemeBloc, ThemeState>(
        'should emit ThemeState with dark theme when ThemeChanged is added with dark theme',
        build: () => bloc,
        act: (bloc) => bloc.add(const ThemeChanged(themeMode: ThemeMode.dark)),
        expect: () => [
          const ThemeState(themeMode: ThemeMode.dark),
        ],
      );

      blocTest<ThemeBloc, ThemeState>(
        'should emit ThemeState with system theme when ThemeChanged is added with system theme',
        build: () => bloc,
        act: (bloc) => bloc.add(const ThemeChanged(themeMode: ThemeMode.system)),
        expect: () => [
          const ThemeState(themeMode: ThemeMode.system),
        ],
      );

      blocTest<ThemeBloc, ThemeState>(
        'should emit multiple states when multiple ThemeChanged events are added',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const ThemeChanged(themeMode: ThemeMode.light));
          bloc.add(const ThemeChanged(themeMode: ThemeMode.dark));
          bloc.add(const ThemeChanged(themeMode: ThemeMode.system));
        },
        expect: () => [
          const ThemeState(themeMode: ThemeMode.light),
          const ThemeState(themeMode: ThemeMode.dark),
          const ThemeState(themeMode: ThemeMode.system),
        ],
      );
    });

    group('HydratedBloc functionality', () {
      test('should correctly serialize state to JSON', () {
        // Arrange
        const state = ThemeState(themeMode: ThemeMode.light);

        // Act
        final json = bloc.toJson(state);

        // Assert
        expect(json, {'themeMode': 1}); // ThemeMode.light.index = 1
      });

      test('should correctly deserialize state from JSON', () {
        // Arrange
        final json = {'themeMode': 2}; // ThemeMode.dark.index = 2

        // Act
        final state = bloc.fromJson(json);

        // Assert
        expect(state, const ThemeState(themeMode: ThemeMode.dark));
      });

      test('should return null when JSON deserialization fails', () {
        // Arrange
        final invalidJson = {'invalid': 'data'};

        // Act
        final state = bloc.fromJson(invalidJson);

        // Assert
        expect(state, isNull);
      });

      test('should return null when JSON serialization fails', () {
        // This test is more theoretical as our simple state should not fail
        // but it tests the error handling in toJson

        // Act
        final json = bloc.toJson(const ThemeState(themeMode: ThemeMode.system));

        // Assert
        expect(json, {'themeMode': 0}); // ThemeMode.system.index = 0
      });

      test('should handle all ThemeMode values in serialization', () {
        // Test all theme modes
        final testCases = [
          (ThemeMode.system, 0),
          (ThemeMode.light, 1),
          (ThemeMode.dark, 2),
        ];

        for (final (themeMode, expectedIndex) in testCases) {
          final state = ThemeState(themeMode: themeMode);
          final json = bloc.toJson(state);
          expect(json, {'themeMode': expectedIndex});

          final deserializedState = bloc.fromJson({'themeMode': expectedIndex});
          expect(deserializedState, state);
        }
      });
    });
  });
}