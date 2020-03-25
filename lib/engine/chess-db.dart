import 'dart:convert';
import 'dart:io';

class ChessDB {
  //
  static const Host = 'www.chessdb.cn';
  static const Path = '/chessdb.php';

  static Future<String> query(String board) async {
    //
    Uri url = Uri(
      scheme: 'http',
      host: Host,
      path: Path,
      queryParameters: {
        'action': 'queryall',
        'learn': '1',
        'showall': '1',
        'board': board,
      },
    );

    final httpClient = HttpClient();

    try {
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      return await response.transform(utf8.decoder).join();
      //
    } catch (e) {
      print('Error: $e');
    } finally {
      httpClient.close();
    }

    return null;
  }

  static Future<String> requestComputeBackground(String board) async {
    //
    Uri url = Uri(
      scheme: 'http',
      host: Host,
      path: Path,
      queryParameters: {
        'action': 'queue',
        'board': board,
      },
    );

    final httpClient = HttpClient();

    try {
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      return await response.transform(utf8.decoder).join();
      //
    } catch (e) {
      print('Error: $e');
    } finally {
      httpClient.close();
    }

    return null;
  }
}
