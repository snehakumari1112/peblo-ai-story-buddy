import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

const sampleStoryText =
    'Once upon a time, a clever little robot named Pip lost his shiny blue gear '
    'in the Whispering Woods...';

class TtsServiceException implements Exception {
  const TtsServiceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'TtsServiceException: $message';
    return 'TtsServiceException: $message ($cause)';
  }
}

class TtsService {
  TtsService({FlutterTts? flutterTts}) : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> initialize({
    VoidCallback? onComplete,
    ValueChanged<String>? onError,
  }) async {
    try {
      _flutterTts.setCompletionHandler(() {
        onComplete?.call();
      });

      _flutterTts.setErrorHandler((message) {
        onError?.call(message);
      });

      await _runTtsCommand(
        _flutterTts.setLanguage('en-US'),
        failureMessage: 'Unable to set the speech language.',
      );

      await _runTtsCommand(
        _flutterTts.setSpeechRate(0.45),
        failureMessage: 'Unable to set the speech rate.',
      );

      await _runTtsCommand(
        _flutterTts.setPitch(1.05),
        failureMessage: 'Unable to set the speech pitch.',
      );

      await _runTtsCommand(
        _flutterTts.setVolume(1.0),
        failureMessage: 'Unable to set the speech volume.',
      );

      _isInitialized = true;
    } catch (error) {
      if (error is TtsServiceException) rethrow;
      throw TtsServiceException('Failed to initialize text to speech.', error);
    }
  }

  Future<void> speak(String text) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      throw const TtsServiceException('Cannot speak empty story text.');
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _runTtsCommand(
        _flutterTts.speak(trimmedText),
        failureMessage: 'Unable to start reading the story.',
      );
    } catch (error) {
      if (error is TtsServiceException) rethrow;
      throw TtsServiceException('Failed to speak the story text.', error);
    }
  }

  Future<void> speakSampleStory() {
    return speak(sampleStoryText);
  }

  Future<void> stop() async {
    try {
      await _runTtsCommand(
        _flutterTts.stop(),
        failureMessage: 'Unable to stop the current speech.',
      );
    } catch (error) {
      if (error is TtsServiceException) rethrow;
      throw TtsServiceException('Failed to stop text to speech.', error);
    }
  }

  Future<void> dispose() async {
    try {
      await stop();
    } catch (_) {
      return;
    }
  }

  Future<void> _runTtsCommand(
    Future<dynamic> command, {
    required String failureMessage,
  }) async {
    final result = await command;

    if (result == 0 || result == '0' || result == false) {
      throw TtsServiceException(failureMessage);
    }
  }
}
