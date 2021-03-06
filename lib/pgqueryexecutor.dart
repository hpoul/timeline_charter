library pgqueryexecutor;

import 'package:timeline_charter/analyzer.dart';
import 'package:postgresql/postgresql.dart';
import 'package:logging/logging.dart';
import 'dart:async';


Logger _logger = new Logger('timeline_charter.pgqueryexecutor');

Future<PgQueryExecutor> openPgQueryExecutor(String uri) {
  var completer = new Completer<PgQueryExecutor>();
  connect(uri).then((conn) {
    completer.complete(new PgQueryExecutor._(conn));
  });
  return completer.future;
}

class PgQueryExecutor extends QueryExecutor {
  Connection conn;
  
  /**
   * don't forget to call
   */
  PgQueryExecutor._(this.conn) {
  }
  
  Future<Iterable<AnalyzerResult>> execute(AnalyzerContext context, AnalyzerConfig config, DateTime start, DateTime end) {
    _logger.finest("executing ${config.sql} for between ${start} and ${end}");
    Completer<Iterable<AnalyzerResult>> completer = new Completer<Iterable<AnalyzerResult>>();
    conn.query(config.sql, { 'startTime': start, 'endTime': end})
      .toList().then((result) {
        Iterable<AnalyzerResult> analyzeResult = null;
        if (config.keys == null) {
          analyzeResult = config.resultTransformer(result);
        } else {
          var row = result.length < 1 ? config.keys.map((v)=>0).toList() : result[0];
          _logger.finest('result: ${row}');
          List analyzeResultTmp = new List();
          for (int i = 0 ; i < config.keys.length ; i++) {
            analyzeResultTmp.add(new AnalyzerResult(key: config.keys[i], label: config.labels[i], value: row[i]));
          }
          analyzeResult = analyzeResultTmp;
        }
        assert(analyzeResult != null);
        completer.complete(analyzeResult);
      });
    return completer.future;
  }
  
  void close() {
    conn.close();
  }
}