import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<ThemeChanged>(_onThemeChanged);
  }

  void _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) {
    emit(ThemeState(themeMode: event.themeMode));
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('themeMode')) return null;
      final themeModeIndex = json['themeMode'] as int?;
      if (themeModeIndex == null) return null;
      if (themeModeIndex < 0 || themeModeIndex >= ThemeMode.values.length) return null;
      final themeMode = ThemeMode.values[themeModeIndex];
      return ThemeState(themeMode: themeMode);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    try {
      return {
        'themeMode': state.themeMode.index,
      };
    } catch (e) {
      return null;
    }
  }
}