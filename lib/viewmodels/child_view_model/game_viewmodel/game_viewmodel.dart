import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child/game_repository.dart';
import '../../../services/child/game_service.dart';


final gameServiceProvider = Provider((ref) => GameService());

final gameRepositoryProvider = Provider((ref) {
  final service = ref.watch(gameServiceProvider);
  return GameRepository(service);
});

class GameState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  GameState({this.isLoading = false, this.error, this.isSuccess = false});

  GameState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return GameState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class GameViewModel extends StateNotifier<GameState> {
  final GameRepository _repository;

  GameViewModel(this._repository) : super(GameState());

  Future<void> saveProgress({
    required String childId,
    required String gameId,
    required String gameName, // Added parameter
    required String rawJson,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.saveGameResult(
        childId: childId,
        gameId: gameId,
        gameName: gameName, // Passed to repo
        rawJson: rawJson,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final gameViewModelProvider = StateNotifierProvider<GameViewModel, GameState>((ref) {
  final repo = ref.watch(gameRepositoryProvider);
  return GameViewModel(repo);
});