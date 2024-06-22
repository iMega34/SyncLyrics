
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenIndexState {
  ScreenIndexState({this.index});

  final int? index;

  ScreenIndexState copyWith({int? index}) => ScreenIndexState(index: index);
}

class ScreenIndexNotifier extends StateNotifier<ScreenIndexState> {
  ScreenIndexNotifier() : super(ScreenIndexState(index: 0));

  void setScreenIndex(int index) => state = state.copyWith(index: index);
}

final screenIndexProvider = StateNotifierProvider<ScreenIndexNotifier, ScreenIndexState>(
  (ref) => ScreenIndexNotifier()
);
