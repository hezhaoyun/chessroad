import 'cc-base.dart';
import 'phase.dart';
import 'step-enum.dart';
import 'steps-validate.dart';

class ChessRules {
  //
  static checked(Phase phase) {
    //
    final myKingPos = findKingPos(phase);

    final oppoPhase = Phase.clone(phase);
    oppoPhase.trunSide();

    final oppoSteps = StepsEnumerator.enumSteps(oppoPhase);

    for (var step in oppoSteps) {
      if (step.to == myKingPos) return true;
    }

    return false;
  }

  static willBeChecked(Phase phase, Move move) {
    //
    final tempPhase = Phase.clone(phase);
    tempPhase.moveTest(move);

    return checked(tempPhase);
  }

  static willKingsMeeting(Phase phase, Move move) {
    //
    final tempPhase = Phase.clone(phase);
    tempPhase.moveTest(move);

    for (var col = 3; col < 6; col++) {
      //
      var foundKingAlready = false;

      for (var row = 0; row < 10; row++) {
        //
        final piece = tempPhase.pieceAt(row * 9 + col);

        if (!foundKingAlready) {
          if (piece == Piece.RedKing || piece == Piece.BlackKing) foundKingAlready = true;
          if (row > 2) break;
        } else {
          if (piece == Piece.RedKing || piece == Piece.BlackKing) return true;
          if (piece != Piece.Empty) break;
        }
      }
    }

    return false;
  }

  static bool beKilled(Phase phase) {
    //
    List<Move> steps = StepsEnumerator.enumSteps(phase);

    for (var step in steps) {
      if (StepValidate.validate(phase, step)) return false;
    }

    return true;
  }

  static int findKingPos(Phase phase) {
    //
    for (var i = 0; i < 90; i++) {
      //
      final piece = phase.pieceAt(i);

      if (piece == Piece.RedKing || piece == Piece.BlackKing) {
        if (phase.side == Side.of(piece)) return i;
      }
    }

    return -1;
  }
}
