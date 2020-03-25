import 'cc-base.dart';
import 'phase.dart';
import '../common/math.ext.dart';

class StepName {
  //
  static const RedColNames = '九八七六五四三二一';
  static const BlackColNames = '１２３４５６７８９';

  static const RedDigits = '零一二三四五六七八九';
  static const BlackDigits = '０１２３４５６７８９';

  static translate(Phase phase, Move step) {
    //
    final colNames = [RedColNames, BlackColNames];
    final digits = [RedDigits, BlackDigits];

    final side = Side.of(phase.pieceAt(step.from));
    final sideIndex = (side == Side.Red) ? 0 : 1;

    final chessName = nameOf(phase, step);

    String result = chessName;

    if (step.ty == step.fy) {
      //
      result += '平${colNames[sideIndex][step.tx]}';
      //
    } else {
      //
      final direction = (side == Side.Red) ? -1 : 1;
      final dir = ((step.ty - step.fy) * direction > 0) ? '进' : '退';

      final piece = phase.pieceAt(step.from);

      final specialPieces = [
        Piece.RedKnight,
        Piece.BlackKnight,
        Piece.RedBishop,
        Piece.BlackBishop,
        Piece.RedAdvisor,
        Piece.BlackAdvisor,
      ];

      String targetPos;

      if (specialPieces.contains(piece)) {
        targetPos = '${colNames[sideIndex][step.tx]}';
      } else {
        targetPos = '${digits[sideIndex][abs(step.ty - step.fy)]}';
      }

      result += '$dir$targetPos';
    }

    return step.stepName = result;
  }

  static nameOf(Phase phase, Move step) {
    //
    final colNames = [RedColNames, BlackColNames];
    final digits = [RedDigits, BlackDigits];

    final side = Side.of(phase.pieceAt(step.from));
    final sideIndex = (side == Side.Red) ? 0 : 1;

    final piece = phase.pieceAt(step.from);
    final chessName = Piece.Names[piece];

    // 士相由于行动行动路径有限，不会出现同一列两个士相都可以进或退的情况
    // 所以一般不说「前士、前相」之类的，根据「进、退」动作即可判断是前一个还是后一个
    if (piece == Piece.RedAdvisor ||
        piece == Piece.RedBishop ||
        piece == Piece.BlackAdvisor ||
        piece == Piece.BlackBishop) {
      //
      return '$chessName${colNames[sideIndex][step.fx]}';
    }

    // 此 Map 的 Key 为「列」， Value 为此列上出现所查寻棋子的 y 坐标（row）列表
    // 返回结果中进行了过滤，如果某一列包含所查寻棋子的数量 < 2，此列不包含在返回结果中
    final Map<int, List<int>> cols = findPieceSameCol(phase, piece);
    final fyIndexes = cols[step.fx];

    // 正在动棋的这一列不包含多个同类棋子
    if (fyIndexes == null) {
      return '$chessName${colNames[sideIndex][step.fx]}';
    }

    // 只有正在动棋的这一列包含多个同类棋子
    if (cols.length == 1) {
      //
      var order = fyIndexes.indexOf(step.fy);
      if (side == Side.Black) order = fyIndexes.length - 1 - order;

      if (fyIndexes.length == 2) {
        return '${'前后'[order]}$chessName';
      }

      if (fyIndexes.length == 3) {
        return '${'前中后'[order]}$chessName';
      }

      return '${digits[sideIndex][order]}$chessName';
    }

    // 这种情况表示有两列都有两个或以上正在查寻的棋子
    // 这种情况下，从右列开始为棋子指定序数（从前到后），然后再左列
    if (cols.length == 2) {
      //
      final fxIndexes = cols.keys.toList();
      fxIndexes.sort((a, b) => a - b);

      // 已经按列的 x 坐标排序，当前动子列是否是在右边的列
      final currentColStart = (step.fx == fxIndexes[1 - sideIndex]);

      if (currentColStart) {
        //
        var order = fyIndexes.indexOf(step.fy);
        if (side == Side.Black) order = fyIndexes.length - 1 - order;

        return '${digits[sideIndex][order]}$chessName';
        //
      } else {
        // 当前列表在左边，后计序数
        final fxOtherCol = fxIndexes[sideIndex];

        var order = fyIndexes.indexOf(step.fy);
        if (side == Side.Black) order = fyIndexes.length - 1 - order;

        return '${digits[sideIndex][cols[fxOtherCol].length + order]}$chessName';
      }
    }

    return '错误招法';
  }

  static findPieceSameCol(Phase phase, String piece) {
    //
    final map = Map<int, List<int>>();

    for (var row = 0; row < 10; row++) {
      for (var col = 0; col < 9; col++) {
        //
        if (phase.pieceAt(row * 9 + col) == piece) {
          //
          var fyIndexes = map[col] ?? [];
          fyIndexes.add(row);
          map[col] = fyIndexes;
        }
      }
    }

    final Map<int, List<int>> result = {};

    map.forEach((k, v) {
      if (v.length > 1) result[k] = v;
    });

    return result;
  }
}
