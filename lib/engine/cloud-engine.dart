import '../cchess/cc-base.dart';
import '../cchess/phase.dart';
import 'analysis.dart';
import 'chess-db.dart';
import 'engine.dart';

class CloudEngine extends AiEngine {
  //
  Future<EngineResponse> search(Phase phase, {bool byUser = true}) async {
    //
    final fen = phase.toFen();
    var response = await ChessDB.query(fen);

    if (response == null) return EngineResponse('network-error');

    if (!response.startsWith('move:')) {
      //
      print('ChessDB.query: $response\n');
      //
    } else {
      //
      // move:b2a2,score:-236,rank:0,note:? (00-00),winrate:32.85
      final firstStep = response.split('|')[0];
      print('ChessDB.query: $firstStep');

      final segments = firstStep.split(',');
      if (segments.length < 2) return EngineResponse('data-error');

      final move = segments[0], score = segments[1];

      final scoreSegments = score.split(':');
      if (scoreSegments.length < 2) return EngineResponse('data-error');

      final moveWithScore = int.tryParse(scoreSegments[1]) != null;

      if (moveWithScore) {
        //
        final step = move.substring(5);

        if (Move.validateEngineStep(step)) {
          return EngineResponse(
            'move',
            value: Move.fromEngineStep(step),
          );
        }
      } else {
        //
        if (byUser) {
          response = await ChessDB.requestComputeBackground(fen);
          print('ChessDB.requestComputeBackground: $response\n');
        }

        return Future<EngineResponse>.delayed(
          Duration(seconds: 5),
          () => search(phase, byUser: false),
        );
      }
    }

    return EngineResponse('unknown-error');
  }

  static Future<EngineResponse> analysis(Phase phase) async {
    //
    final fen = phase.toFen();
    var response = await ChessDB.query(fen);

    if (response == null) return EngineResponse('network-error');

    if (response.startsWith('move:')) {
      final items = AnalysisFetcher.fetch(response);
      if (items.isEmpty) return EngineResponse('no-result');
      return EngineResponse('analysis', value: items);
    }

    print('ChessDB.query: $response\n');
    return EngineResponse('unknown-error');
  }
}
