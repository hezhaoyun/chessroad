import 'package:chessroad/services/audios.dart';

import '../cchess/cc-rules.dart';
import '../cchess/cc-base.dart';
import '../cchess/phase.dart';

class Battle {
  //
  static Battle _instance;

  Phase _phase;
  int _focusIndex, _blurIndex;

  static get shared {
    _instance ??= Battle();
    return _instance;
  }

  init() {
    _phase = Phase.defaultPhase();
    _focusIndex = _blurIndex = Move.InvalidIndex;
  }

  newGame() {
    Battle.shared.phase.initDefaultPhase();
    _focusIndex = _blurIndex = Move.InvalidIndex;
  }

  select(int pos) {
    _focusIndex = pos;
    _blurIndex = Move.InvalidIndex;
    Audios.playTone('click.mp3');
  }

  bool move(int from, int to) {
    //
    final captured = _phase.move(from, to);

    if (captured == null) {
      Audios.playTone('invalid.mp3');
      return false;
    }

    _blurIndex = from;
    _focusIndex = to;

    if (ChessRules.checked(_phase)) {
      Audios.playTone('check.mp3');
    } else {
      Audios.playTone(captured != Piece.Empty ? 'capture.mp3' : 'move.mp3');
    }

    return true;
  }

  bool regret({steps = 2}) {
    //
    // 轮到自己走棋的时候，才能悔棋
    if (_phase.side != Side.Red) {
      Audios.playTone('invalid.mp3');
      return false;
    }

    var regreted = false;

    /// 悔棋一回合（两步），才能撤回自己上一次的动棋

    for (var i = 0; i < steps; i++) {
      //
      if (!_phase.regret()) break;

      final lastMove = _phase.lastMove;

      if (lastMove != null) {
        //
        _blurIndex = lastMove.from;
        _focusIndex = lastMove.to;
        //
      } else {
        //
        _blurIndex = _focusIndex = Move.InvalidIndex;
      }

      regreted = true;
    }

    if (regreted) {
      Audios.playTone('regret.mp3');
      return true;
    }

    Audios.playTone('invalid.mp3');
    return false;
  }

  clear() {
    _blurIndex = _focusIndex = Move.InvalidIndex;
  }

  BattleResult scanBattleResult() {
    //
    final forPerson = (_phase.side == Side.Red);

    if (scanLongCatch()) {
      // born 'repeat' phase by oppo
      return forPerson ? BattleResult.Win : BattleResult.Lose;
    }

    if (ChessRules.beKilled(_phase)) {
      return forPerson ? BattleResult.Lose : BattleResult.Win;
    }

    return (_phase.halfMove > 120) ? BattleResult.Draw : BattleResult.Pending;
  }

  scanLongCatch() {
    // todo:
    return false;
  }

  get phase => _phase;

  get focusIndex => _focusIndex;

  get blurIndex => _blurIndex;
}
