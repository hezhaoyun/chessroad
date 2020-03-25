import 'dart:io';

import 'package:chessroad/cchess/cc-base.dart';
import 'package:chessroad/cchess/phase.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'engine.dart';

class NativeEngine extends AiEngine {
  //
  static const platform = const MethodChannel('cn.apppk.chessroad/engine');

  Future<void> startup() async {
    //
    try {
      await platform.invokeMethod('startup');
    } catch (e) {
      print('Native startup Error: $e');
    }

    await setBookFile();

    await waitResponse(['ucciok'], sleep: 1, times: 30);
  }

  Future<void> send(String command) async {
    //
    try {
      await platform.invokeMethod('send', command);
    } catch (e) {
      print('Native sendCommand Error: $e');
    }
  }

  Future<String> read() async {
    //
    try {
      return await platform.invokeMethod('read');
    } catch (e) {
      print('Native readResponse Error: $e');
    }

    return null;
  }

  Future<void> shutdown() async {
    //
    try {
      await platform.invokeMethod('shutdown');
    } catch (e) {
      print('Native shutdown Error: $e');
    }
  }

  Future<bool> isReady() async {
    //
    try {
      return await platform.invokeMethod('isReady');
    } catch (e) {
      print('Native readResponse Error: $e');
    }

    return null;
  }

  Future<bool> isThinking() async {
    //
    try {
      return await platform.invokeMethod('isThinking');
    } catch (e) {
      print('Native readResponse Error: $e');
    }

    return null;
  }

  Future setBookFile() async {
    //
    final docDir = await getApplicationDocumentsDirectory();
    final bookFile = File('${docDir.path}/book.dat');

    try {
      if (!await bookFile.exists()) {
        await bookFile.create(recursive: true);
        final bytes = await rootBundle.load("assets/book.dat");
        await bookFile.writeAsBytes(bytes.buffer.asUint8List());
      }
    } catch (e) {
      print(e);
    }

    await send("setoption bookfiles ${bookFile.path}");
  }

  @override
  Future<EngineResponse> search(Phase phase, {bool byUser = true}) async {
    //
    if (await isThinking()) await stopSearching();

    send(buildPositionCommand(phase));
    send('go time 5000');

    final response = await waitResponse(['bestmove', 'nobestmove']);

    if (response.startsWith('bestmove')) {
      //
      var step = response.substring('bestmove'.length + 1);

      final pos = step.indexOf(' ');
      if (pos > -1) step = step.substring(0, pos);

      return EngineResponse('move', value: Move.fromEngineStep(step));
    }

    if (response.startsWith('nobestmove')) {
      return EngineResponse('nobestmove');
    }

    return EngineResponse('timeout');
  }

  Future<String> waitResponse(List<String> prefixes, {sleep = 100, times = 100}) async {
    //
    if (times <= 0) return '';

    final response = await read();

    if (response != null) {
      for (var prefix in prefixes) {
        if (response.startsWith(prefix)) return response;
      }
    }

    return Future<String>.delayed(
      Duration(milliseconds: sleep),
      () => waitResponse(prefixes, times: times - 1),
    );
  }

  Future<void> stopSearching() async {
    await send('stop');
  }

  String buildPositionCommand(Phase phase) {
    //
    final startPhase = phase.lastCapturedPhase;
    final moves = phase.movesSinceLastCaptured();

    if (moves.isEmpty) return 'position fen $startPhase';

    return 'position fen $startPhase moves $moves';
  }
}
