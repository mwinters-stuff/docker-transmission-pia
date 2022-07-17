import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';
import 'package:xml/xml.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';

  setUp(() async {
    await TestProcess.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );
  });

  test('Root', () async {
    final response = await get(Uri.parse(host + '/'));
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!\n');
  });

  test('Echo', () async {
    final response = await get(Uri.parse(host + '/echo/hello'));
    expect(response.statusCode, 200);
    expect(response.body, 'hello\n');
  });
  test('404', () async {
    final response = await get(Uri.parse(host + '/foobar'));
    expect(response.statusCode, 404);
  });

  test('xml decode', () async {
    final xml = '''<?xml version="1.0" encoding="UTF-8"?>
      <MediaContainer size="2" allowSync="0" title1="Plex Library">
        <Directory allowSync="1" art="/:/resources/movie-fanart.jpg" composite="/library/sections/2/composite/1657871471" filters="1" refreshing="0" thumb="/:/resources/movie.png" key="2" type="movie" title="Movies" agent="tv.plex.agents.movie" scanner="Plex Movie" language="en-US" uuid="075a684f-f5dc-4468-86d5-235a60fe7718" updatedAt="1656868084" createdAt="1656868084" scannedAt="1657871471" content="1" directory="1" contentChangedAt="4677" hidden="0">
          <Location id="2" path="/data/Movies" />
        </Directory>
        <Directory allowSync="1" art="/:/resources/show-fanart.jpg" composite="/library/sections/1/composite/1657871475" filters="1" refreshing="0" thumb="/:/resources/show.png" key="1" type="show" title="TV Shows" agent="tv.plex.agents.series" scanner="Plex TV Series" language="en-US" uuid="acd29c68-aff3-4c23-8b8d-46066fe06d30" updatedAt="1656868071" createdAt="1656868071" scannedAt="1657871475" content="1" directory="1" contentChangedAt="29002" hidden="0">
          <Location id="1" path="/data/TV" />
        </Directory>
      </MediaContainer>''';

    final document = XmlDocument.parse(xml);

    final directories = document.findAllElements('Directory');
    for (final directory in directories) {
      if (directory.getAttribute("allowSync") == "1" && List.from(["movie", "show"]).contains(directory.getAttribute("type"))) {
        print(directory.getAttribute("key"));
      }
    }
  });
}
