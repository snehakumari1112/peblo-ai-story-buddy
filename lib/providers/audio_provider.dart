import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tts_service.dart';

enum AudioStatus {
  idle,
  loading,
  playing,
  completed,
  error,
}

class AudioState {
  const AudioState({
    this.status = AudioStatus.idle,
    this.errorMessage,
  });

  final AudioStatus status;
  final String? errorMessage;

  bool get isIdle => status == AudioStatus.idle;
  bool get isLoading => status == AudioStatus.loading;
  bool get isPlaying => status == AudioStatus.playing;
  bool get isCompleted => status == AudioStatus.completed;
  bool get hasError => status == AudioStatus.error;

  AudioState copyWith({
    AudioStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AudioState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AudioState &&
            runtimeType == other.runtimeType &&
            status == other.status &&
            errorMessage == other.errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, errorMessage);
}

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier() : super(const AudioState());

  void setLoading() {
    state = const AudioState(status: AudioStatus.loading);
  }

  void setPlaying() {
    state = const AudioState(status: AudioStatus.playing);
  }

  void setCompleted() {
    state = const AudioState(status: AudioStatus.completed);
  }

  void setError(String message) {
    state = AudioState(
      status: AudioStatus.error,
      errorMessage: message,
    );
  }

  void reset() {
    state = const AudioState();
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>(
  (ref) => AudioNotifier(),
);

final audioStatusProvider = Provider<AudioStatus>(
  (ref) => ref.watch(audioProvider.select((state) => state.status)),
);

final audioErrorMessageProvider = Provider<String?>(
  (ref) => ref.watch(audioProvider.select((state) => state.errorMessage)),
);

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
