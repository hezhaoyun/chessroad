import '../common/math.ext.dart';
import 'cc-base.dart';
import 'cc-rules.dart';
import 'phase.dart';

class StepValidate {
  //
  static bool validate(Phase phase, Move move) {
    //
    if (Side.of(phase.pieceAt(move.to)) == phase.side) return false;

    final piece = phase.pieceAt(move.from);

    var valid = false;

    if (piece == Piece.RedKing || piece == Piece.BlackKing) {
      valid = validateKingStep(phase, move);
    } else if (piece == Piece.RedAdvisor || piece == Piece.BlackAdvisor) {
      valid = validateAdvisorStep(phase, move);
    } else if (piece == Piece.RedBishop || piece == Piece.BlackBishop) {
      valid = validateBishopStep(phase, move);
    } else if (piece == Piece.RedKnight || piece == Piece.BlackKnight) {
      valid = validateKnightStep(phase, move);
    } else if (piece == Piece.RedRook || piece == Piece.BlackRook) {
      valid = validateRookStep(phase, move);
    } else if (piece == Piece.RedCanon || piece == Piece.BlackCanon) {
      valid = validateCanonStep(phase, move);
    } else if (piece == Piece.RedPawn || piece == Piece.BlackPawn) {
      valid = validatePawnStep(phase, move);
    }

    if (!valid) return false;

    if (ChessRules.willBeChecked(phase, move)) return false;

    if (ChessRules.willKingsMeeting(phase, move)) return false;

    return true;
  }

  static bool validateKingStep(Phase phase, Move move) {
    //
    final adx = abs(move.tx - move.fx), ady = abs(move.ty - move.fy);

    final isUpDownMove = (adx == 0 && ady == 1);
    final isLeftRightMove = (adx == 1 && ady == 0);

    if (!isUpDownMove && !isLeftRightMove) return false;

    final redRange = [66, 67, 68, 75, 76, 77, 84, 85, 86];
    final blackRange = [3, 4, 5, 12, 13, 14, 21, 22, 23];
    final range = (phase.side == Side.Red) ? redRange : blackRange;

    return binarySearch(range, 0, range.length - 1, move.to) >= 0;
  }

  static bool validateAdvisorStep(Phase phase, Move move) {
    //
    final adx = abs(move.tx - move.fx), ady = abs(move.ty - move.fy);

    if (adx != 1 || ady != 1) return false;

    final redRange = [66, 68, 76, 84, 86], blackRange = [3, 5, 13, 21, 23];
    final range = (phase.side == Side.Red) ? redRange : blackRange;

    return binarySearch(range, 0, range.length - 1, move.to) >= 0;
  }

  static bool validateBishopStep(Phase phase, Move move) {
    //
    final adx = abs(move.tx - move.fx), ady = abs(move.ty - move.fy);

    if (adx != 2 || ady != 2) return false;

    final redRange = [47, 51, 63, 67, 71, 83, 87], blackRange = [2, 6, 18, 22, 26, 38, 42];
    final range = (phase.side == Side.Red) ? redRange : blackRange;

    if (binarySearch(range, 0, range.length - 1, move.to) < 0) return false;

    if (move.tx > move.fx) {
      if (move.ty > move.fy) {
        final heart = (move.fy + 1) * 9 + move.fx + 1;
        if (phase.pieceAt(heart) != Piece.Empty) return false;
      } else {
        final heart = (move.fy - 1) * 9 + move.fx + 1;
        if (phase.pieceAt(heart) != Piece.Empty) return false;
      }
    } else {
      if (move.ty > move.fy) {
        final heart = (move.fy + 1) * 9 + move.fx - 1;
        if (phase.pieceAt(heart) != Piece.Empty) return false;
      } else {
        final heart = (move.fy - 1) * 9 + move.fx - 1;
        if (phase.pieceAt(heart) != Piece.Empty) return false;
      }
    }

    return true;
  }

  static bool validateKnightStep(Phase phase, Move move) {
    //
    final dx = move.tx - move.fx, dy = move.ty - move.fy;
    final adx = abs(dx), ady = abs(dy);

    if (!(adx == 1 && ady == 2) && !(adx == 2 && ady == 1)) return false;

    if (adx > ady) {
      if (dx > 0) {
        final foot = move.fy * 9 + move.fx + 1;
        if (phase.pieceAt(foot) != Piece.Empty) return false;
      } else {
        final foot = move.fy * 9 + move.fx - 1;
        if (phase.pieceAt(foot) != Piece.Empty) return false;
      }
    } else {
      if (dy > 0) {
        final foot = (move.fy + 1) * 9 + move.fx;
        if (phase.pieceAt(foot) != Piece.Empty) return false;
      } else {
        final foot = (move.fy - 1) * 9 + move.fx;
        if (phase.pieceAt(foot) != Piece.Empty) return false;
      }
    }

    return true;
  }

  static bool validateRookStep(Phase phase, Move move) {
    //
    final dx = move.tx - move.fx, dy = move.ty - move.fy;

    if (dx != 0 && dy != 0) return false;

    if (dy == 0) {
      if (dx < 0) {
        for (int i = move.fx - 1; i > move.tx; i--) {
          if (phase.pieceAt(move.fy * 9 + i) != Piece.Empty) return false;
        }
      } else {
        for (int i = move.fx + 1; i < move.tx; i++) {
          if (phase.pieceAt(move.fy * 9 + i) != Piece.Empty) return false;
        }
      }
    } else {
      if (dy < 0) {
        for (int i = move.fy - 1; i > move.ty; i--) {
          if (phase.pieceAt(i * 9 + move.fx) != Piece.Empty) return false;
        }
      } else {
        for (int i = move.fy + 1; i < move.ty; i++) {
          if (phase.pieceAt(i * 9 + move.fx) != Piece.Empty) return false;
        }
      }
    }

    return true;
  }

  static bool validateCanonStep(Phase phase, Move move) {
    //
    final dx = move.tx - move.fx, dy = move.ty - move.fy;

    if (dx != 0 && dy != 0) return false;

    if (dy == 0) {
      //
      if (dx < 0) {
        //
        var overPiece = false;

        for (int i = move.fx - 1; i > move.tx; i--) {
          //
          if (phase.pieceAt(move.fy * 9 + i) != Piece.Empty) {
            //
            if (overPiece) return false;

            if (phase.pieceAt(move.to) == Piece.Empty) return false;
            overPiece = true;
          }
        }

        if (!overPiece && phase.pieceAt(move.to) != Piece.Empty) return false;
        //
      } else {
        //
        var overPiece = false;

        for (int i = move.fx + 1; i < move.tx; i++) {
          //
          if (phase.pieceAt(move.fy * 9 + i) != Piece.Empty) {
            //
            if (overPiece) return false;

            if (phase.pieceAt(move.to) == Piece.Empty) return false;
            overPiece = true;
          }
        }

        if (!overPiece && phase.pieceAt(move.to) != Piece.Empty) return false;
      }
    } else {
      //
      if (dy < 0) {
        //
        var overPiece = false;

        for (int i = move.fy - 1; i > move.ty; i--) {
          //
          if (phase.pieceAt(i * 9 + move.fx) != Piece.Empty) {
            //
            if (overPiece) return false;

            if (phase.pieceAt(move.to) == Piece.Empty) return false;
            overPiece = true;
          }
        }

        if (!overPiece && phase.pieceAt(move.to) != Piece.Empty) return false;
        //
      } else {
        //
        var overPiece = false;

        for (int i = move.fy + 1; i < move.ty; i++) {
          //
          if (phase.pieceAt(i * 9 + move.fx) != Piece.Empty) {
            //
            if (overPiece) return false;

            if (phase.pieceAt(move.to) == Piece.Empty) return false;
            overPiece = true;
          }
        }

        if (!overPiece && phase.pieceAt(move.to) != Piece.Empty) return false;
      }
    }

    return true;
  }

  static bool validatePawnStep(Phase phase, Move move) {
    //
    final dy = move.ty - move.fy;
    final adx = abs(move.tx - move.fx), ady = abs(move.ty - move.fy);

    if (adx > 1 || ady > 1 || (adx + ady) > 1) return false;

    if (phase.side == Side.Red) {
      //
      if (move.fy > 4 && adx != 0) return false;
      if (dy > 0) return false;
      //
    } else {
      //
      if (move.fy < 5 && adx != 0) return false;
      if (dy < 0) return false;
    }

    return true;
  }
}
