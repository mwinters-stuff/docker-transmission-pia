import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;
import 'package:http/io_client.dart';
import 'package:xml/xml.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/error', _errorHandler)
  ..get('/torrent-done/<torrent_name>', _torrentDoneHandler)
  ..get('/refresh-plex', _refreshPlex);

Response _errorHandler(_) {
  return Response.notFound('no');
}

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Response _torrentDoneHandler(Request request) {
  final torrentName = Uri.decodeComponent(request.params['torrent_name'].toString());
  final torrentDir = Platform.environment['TORRENT_DIR'] ?? '/downloads';
  final scriptsDir = Platform.environment['SCRIPTS_DIR'] ?? '/scripts';
  print('Running mnamer on $torrentName');

  final result = Process.runSync('mnamer', ['--config-path=${p.join(scriptsDir, "mnamer.json")}', '-b', '--verbose', '--no-style', p.join(torrentDir, 'complete', torrentName)]);

  print(result.stdout.toString());
  print(result.stderr.toString());

  File(p.join(torrentDir, 'mnamer.log')).writeAsStringSync(result.stdout.toString(), mode: FileMode.append);

  if (result.exitCode > 0) {
    return Response.notFound(result.stdout);
  }
  _updatePlex();
  return Response.ok('$torrentName\n');
}

Response _refreshPlex(_) {
  _updatePlex();
  return Response.ok('ok\n');
}

void _updatePlex() async {
  final plexServerAddress = Platform.environment['PLEX_SERVER_ADDRESS'];
  final plexToken = Platform.environment['PLEX_TOKEN'];

  if (plexServerAddress == null || plexToken == null || plexServerAddress.isEmpty || plexToken.isEmpty) {
    print("Plex env not set not updating plex");
    return;
  }

  final httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  // var client = http.Client();
  final ioClient = IOClient(httpClient);
  try {
    var url = Uri.https(plexServerAddress, '/library/sections/', {'X-Plex-Token': plexToken});

    final response = await ioClient.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    final document = XmlDocument.parse(utf8.decode(response.bodyBytes));

    final directories = document.findAllElements('Directory');
    for (final directory in directories) {
      if (directory.getAttribute("allowSync") == "1" && List.from(["movie", "show"]).contains(directory.getAttribute("type"))) {
        final key = directory.getAttribute("key");
        print("Updating library ${directory.getAttribute("title")}");
        var urlUpdate = Uri.https(plexServerAddress, '/library/sections/$key/refresh', {'X-Plex-Token': plexToken});
        final response2 = await ioClient.get(urlUpdate);
        print('Response status: ${response2.statusCode}');
        print('Response body: ${response2.body}');
      }
    }
  } finally {
    ioClient.close();
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
