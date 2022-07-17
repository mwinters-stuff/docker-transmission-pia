import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/torrent-done/<torrent_id>/<torrent_name>', _torrentDoneHandler);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Response _torrentDoneHandler(Request request) {
  final torrentID = request.params['torrent_id'];
  final torrentName = request.params['torrent_name'];
  final torrentDir = Platform.environment['TORRENT_DIR'] ?? '/downloads/complete';
  final scriptsDir = Platform.environment['SCRIPTS_DIR'] ?? '/scripts';
  print('Running mnamer on torrent $torrentName $torrentName');

  final result = Process.runSync('mnamer', ['--config-path=${p.join(scriptsDir, "mnamer.json")}', '-b', '--verbose', '--no-style', p.join(torrentDir, torrentName)]);

  File(p.join(torrentDir, 'mnamer.log')).writeAsStringSync(result.stdout.toString(), mode: FileMode.append);

  if (result.exitCode > 0) {
    return Response.notFound(result.stdout);
  }
  _updatePlex();
  return Response.ok('$torrentID\n$torrentName\n$torrentDir\n');
}

void _updatePlex() {
  final plexServerAddress = Platform.environment['PLEX_SERVER_ADDRESS'];
  final plexToken = Platform.environment['PLEX_TOKEN'];

  if (plexServerAddress == null || plexToken == null) {
    print("Plex env not set not updating plex");
    return;
  }

  var client = http.Client();
  try {
    var url = Uri.https(plexServerAddress, '/library/sections/', {'X-Plex-Token': plexToken});
    client.get(url).then((response) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final document = XmlDocument.parse(utf8.decode(response.bodyBytes));

      final directories = document.findAllElements('Directory');
      for (final directory in directories) {
        if (directory.getAttribute("allowSync") == "1" && List.from(["movie", "show"]).contains(directory.getAttribute("type"))) {
          final key = directory.getAttribute("key");
          print("Updating library ${directory.getAttribute("title")}");
          var urlUpdate = Uri.https(plexServerAddress, '/library/sections/$key/refresh', {'X-Plex-Token': plexToken});
          client.get(urlUpdate).then((response) {
            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');
          });
        }
      }
    });
  } finally {
    client.close();
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(_handler, ip, port);
  print('Server listening on port ${server.port}');
}
