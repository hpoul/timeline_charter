import 'dart:io';
import 'package:route/server.dart';
import 'package:logging/logging.dart';

var _logger = new Logger('sql_charter_server.webserver');

dynamic serveData(String filename) {
  var f = new File(filename);
  var extension = filename.substring(filename.lastIndexOf('.')+1);
  var contentType = new ContentType('text', extension);
  _logger.info("Serving ${filename} - extension: ${extension} / contentType: ${contentType}");
  return (HttpRequest request) {
    _logger.finer('serving file ...');
    request.response.headers.contentType = contentType;
    f.openRead().pipe(request.response);
  };
}

main() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
  _logger.info('Initialized logging.');
  HttpServer.bind(InternetAddress.ANY_IP_V4, 8765).then((server) {
    new Router(server)
      ..serve('/').listen(serveData('web/index.html'));
  });
}