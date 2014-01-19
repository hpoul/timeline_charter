library pgqueryexecutor;

import 'package:sql_charter_server/analyzer.dart';
import 'package:postgresql/postgresql.dart';
import 'dart:async';

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
  
  Future<Iterable<AnalyzerResult>> execute(AnalyzerConfig config, DateTime start, DateTime end) {
    print("executing ${config.sql} for between ${start} and ${end}");
    Completer<Iterable<AnalyzerResult>> completer = new Completer<Iterable<AnalyzerResult>>();
    conn.query(config.sql, { 'startTime': start, 'endTime': end})
      .toList().then((result) {
        Iterable<AnalyzerResult> analyzeResult = null;
        if (config.keys == null) {
          analyzeResult = config.resultTransformer(result);
        } else {
          var row = result[0];
          print('result: ${row}');
          List analyzeResultTmp = new List();
          for (int i = 0 ; i < config.keys.length ; i++) {
            analyzeResultTmp.add(new AnalyzerResult(key: config.keys[i], value: row[i]));
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