library analyzer;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract class QueryExecutor {
  Future<Iterable<AnalyzerResult>> execute(AnalyzerConfig config, DateTime start, DateTime end);
}

class AnalyzerResult {
  final String key;
  final String label;
  final num value;
  AnalyzerResult({this.key, this.label, this.value});
}

typedef Iterable<AnalyzerResult> ResultTransformer(List<dynamic> result);

class AnalyzerConfig {
  final String sql;
  /// list of the keys under which the sql results should be stored.
  final List<String> keys;
  /// user friendly names for the keys above.
  final List<String> labels;
  final ResultTransformer resultTransformer;
  
  const AnalyzerConfig({this.sql, this.keys, this.labels, this.resultTransformer});
}

class Analyzer {
  Analyzer();
  
  void analyzeConfigs(QueryExecutor executor, List<AnalyzerConfig> configs) {
    Map<String, List<Map<String, num>>> dataByKey = {};
    Map<String, String> keyLabelMapping = {};
    List<Future> futures = [];
    for (AnalyzerConfig config in configs) {
      // Run weekly analyzes..
      DateTime date = new DateTime.now();
      DateTime today = new DateTime(date.year, date.month, date.day);
      
      
      // go to a monday ..
      if (today.weekday != DateTime.MONDAY) {
        today = today.add(new Duration(days: 8 - today.weekday));
      }
      DateTime start = new DateTime(today.year-1, today.month, today.day);
      Duration week = const Duration(days: 7);
      while (start.isBefore(today)) {
        DateTime next = today.subtract(week);
        var tmp = executor.execute(config, next, today).then((data) {
          data.forEach((result) {
            var dataList = dataByKey[result.key];
            if (dataList == null) {
              dataList = dataByKey[result.key] = new List();
            }
            if (!keyLabelMapping.containsKey(result.key) && result.label != null) {
              keyLabelMapping[result.key]= result.label; 
            }
            dataList.add({'x': next.millisecondsSinceEpoch ~/ 1000, 'y': result.value});
          });
        });
        futures.add(tmp);
        today = next;
      }
    }
    Future.wait(futures).then((empty){
      // sort everything by x value.
      dataByKey.forEach((k, v){
        v.sort((a, b) => a['x'] - b['x']);
      });
      var store = { 'dataByKey': dataByKey, 'keyLabelMapping': keyLabelMapping };
      new File('latestdata.json').openWrite(encoding: Encoding.getByName('UTF-8')).write(JSON.encode(store));
      print(JSON.encode(store));
    });
    
  }
}