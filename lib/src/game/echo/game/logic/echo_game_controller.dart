import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

enum EchoPhase {
  /// Waiting for the player to start
  ready,

  /// The sequence is played back, input is ignored
  playback,

  /// The player repeats the sequence
  input,

  /// A wrong pad was tapped
  gameOver,
}

/// Echo: repeat a sequence of flashing pads that grows by one every round.
///
/// The playback is driven by [tick] (`GameLoop`), so it pauses when the app is in the
/// background and is deterministic in tests.
class EchoGameController extends GameController with RealtimeGameController {
  static const id = 'echo';

  static const padCount = 4;

  /// Pause before the playback starts, also after the last tap of a round
  static const leadIn = Duration(milliseconds: 700);

  /// How long a tapped pad stays lit
  static const pressFlash = Duration(milliseconds: 250);

  /// Time a pad is lit during the playback, shorter for longer sequences
  static Duration onDurationFor(int length) => Duration(milliseconds: max(250, 600 - 25 * (length - 1)));

  /// Time between two pads during the playback, shorter for longer sequences
  static Duration offDurationFor(int length) => Duration(milliseconds: max(100, 250 - 10 * (length - 1)));

  /// Total time of the playback of a sequence of [length], including [leadIn]
  static Duration playbackDurationFor(int length) => leadIn + (onDurationFor(length) + offDurationFor(length)) * length;

  final Random _random;
  final List<int> _sequence = [];
  EchoPhase _phase = EchoPhase.ready;
  Duration _playbackTime = Duration.zero;
  int _inputIndex = 0;
  int _rounds = 0;
  int? _pressedPad;
  Duration _pressRemaining = Duration.zero;
  int? _wrongPad;

  EchoGameController({Random? random}) : _random = random ?? Random(), super(gameId: id);

  EchoPhase get phase => _phase;
  bool get isReady => _phase == EchoPhase.ready;
  bool get isPlayingBack => _phase == EchoPhase.playback;
  bool get isAwaitingInput => _phase == EchoPhase.input;
  bool get isGameOver => _phase == EchoPhase.gameOver;

  /// The sequence to repeat
  List<int> get sequence => List.unmodifiable(_sequence);

  /// Rounds completed, this is the score
  int get rounds => _rounds;
  int get score => _rounds;

  /// Pads of the current sequence the player already repeated
  int get inputIndex => _inputIndex;

  /// The wrong pad that ended the game
  int? get wrongPad => _wrongPad;

  /// The pad that should have been tapped when the game ended
  int? get expectedPad => isGameOver ? _sequence[_inputIndex] : null;

  /// The pad that is lit right now, null when none is
  int? get litPad {
    if (_pressedPad != null) return _pressedPad;
    if (_phase != EchoPhase.playback) return null;
    final time = _playbackTime - leadIn;
    if (time.isNegative) return null;
    final length = _sequence.length;
    final step = onDurationFor(length) + offDurationFor(length);
    final index = time.inMicroseconds ~/ step.inMicroseconds;
    if (index >= length) return null;
    final inStep = time - step * index;
    return inStep < onDurationFor(length) ? _sequence[index] : null;
  }

  @override
  bool get isRunning => _phase == EchoPhase.playback || (_phase == EchoPhase.input && _pressedPad != null);

  /// Starts the first round
  void start() {
    if (_phase != EchoPhase.ready) return;
    startSession();
    _nextRound();
    notifyListeners();
  }

  /// Taps [pad]: starts the game when ready, ignored during the playback
  void tapPad(int pad) {
    assert(pad >= 0 && pad < padCount);
    if (_phase == EchoPhase.ready) return start();
    if (_phase != EchoPhase.input) return;
    registerMove();
    if (pad != _sequence[_inputIndex]) {
      _wrongPad = pad;
      _pressedPad = null;
      _phase = EchoPhase.gameOver;
      finish(GameOutcome.lost, score: _rounds, data: {'rounds': _rounds, 'sequenceLength': _sequence.length});
      notifyListeners();
      return;
    }
    _pressedPad = pad;
    _pressRemaining = pressFlash;
    _inputIndex++;
    if (_inputIndex == _sequence.length) {
      _rounds++;
      _nextRound();
    }
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    final litBefore = litPad;
    final phaseBefore = _phase;
    if (_pressedPad != null) {
      _pressRemaining -= delta;
      if (_pressRemaining <= Duration.zero) _pressedPad = null;
    }
    if (_phase == EchoPhase.playback) {
      _playbackTime += delta;
      if (_playbackTime >= playbackDurationFor(_sequence.length)) {
        _phase = EchoPhase.input;
        _inputIndex = 0;
      }
    }
    if (litBefore != litPad || phaseBefore != _phase) notifyListeners();
  }

  void resetGame() {
    restartSession();
    _sequence.clear();
    _phase = EchoPhase.ready;
    _playbackTime = Duration.zero;
    _inputIndex = 0;
    _rounds = 0;
    _pressedPad = null;
    _wrongPad = null;
    notifyListeners();
  }

  void _nextRound() {
    _sequence.add(_random.nextInt(padCount));
    _phase = EchoPhase.playback;
    _playbackTime = Duration.zero;
    _inputIndex = 0;
  }
}
