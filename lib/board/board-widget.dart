import 'package:chessroad/game/battle.dart';
import 'package:flutter/material.dart';
import '../common/color-consts.dart';
import 'board-painter.dart';
import 'pieces-painter.dart';
import 'words-on-board.dart';

class BoardWidget extends StatelessWidget {
  //
  static const Padding = 5.0, DigitsHeight = 20.0;

  final double width, height;
  final Function(BuildContext, int) onBoardTap;

  BoardWidget({@required this.width, @required this.onBoardTap})
      : height = (width - Padding * 2) / 9 * 10 + (Padding + DigitsHeight) * 2;

  @override
  Widget build(BuildContext context) {
    //
    final boardContainer = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConsts.BoardBackground,
      ),
      child: CustomPaint(
        painter: BoardPainter(width: width),
        foregroundPainter: PiecesPainter(
          width: width,
          phase: Battle.shared.phase,
          focusIndex: Battle.shared.focusIndex,
          blurIndex: Battle.shared.blurIndex,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: Padding,
            horizontal: (width - Padding * 2) / 9 / 2 +
            	Padding - WordsOnBoard.DigitsFontSize / 2,
          ),
          child: WordsOnBoard(),
        ),
      ),
    );

    return GestureDetector(
      child: boardContainer,
      onTapUp: (d) {
        //
        final gridWidth = (width - Padding * 2) * 8 / 9;
        final squareSide = gridWidth / 8;

        final dx = d.localPosition.dx, dy = d.localPosition.dy;
        final row = (dy - Padding - DigitsHeight) ~/ squareSide;
        final column = (dx - Padding) ~/ squareSide;

        if (row < 0 || row > 9) return;
        if (column < 0 || column > 8) return;

        onBoardTap(context, row * 9 + column);
      },
    );
  }
}
