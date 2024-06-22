
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenIndexState {
  /// State that holds the current screen index.
  /// 
  /// Parameters:
  /// - [index] is the index of the current screen
  ScreenIndexState({this.index});

  // Class attributes
  final int? index;

  /// Copies the current state with a new index.
  /// 
  /// Parameters:
  /// - [index] is the index of the current screen
  ScreenIndexState copyWith({int? index}) => ScreenIndexState(index: index ?? this.index);
}

class ScreenIndexNotifier extends StateNotifier<ScreenIndexState> {
  /// Provider of the current screen index.
  /// 
  /// The initial state is a `ScreenIndexState` with index 0, that is, the home screen.
  ScreenIndexNotifier() : super(ScreenIndexState(index: 0));

  /// Sets the current screen index.
  /// 
  /// Parameters:
  /// - [index] is the index of the current screen
  void setScreenIndex(int index) => state = state.copyWith(index: index);
}

/// Provider of the current screen index.
/// 
/// The initial state is a `ScreenIndexState` with index 0, that is, the home screen.
final screenIndexProvider = StateNotifierProvider<ScreenIndexNotifier, ScreenIndexState>(
  (ref) => ScreenIndexNotifier()
);
