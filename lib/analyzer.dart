library analyzer;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

part 'src/cachedqueryexecutor.dart';
part 'src/simplefilecache.dart';

abstract class QueryExecutor {
  Future<Iterable<AnalyzerResult>> execute(AnalyzerContext context, AnalyzerConfig config, DateTime start, DateTime end);
  
  /// should be called when this executor is no longer required.
  close() {
    // dummy method..
  }
}

class AnalyzerCacheKey {
  String cacheRegionKey;
  /// analyze type (e.g. weekly)
  String type;
  int timestamp;
  AnalyzerCacheKey(this.cacheRegionKey, this.type, this.timestamp);
  
  String asStringKey() => '${cacheRegionKey}:${type}:${timestamp}';
}

abstract class AnalyzerCache {
  void putCache(AnalyzerCacheKey cacheKey, Map<String, num> value);
  Future<Map<String, num>> getCache(AnalyzerCacheKey cacheKey);
  
  void persistKeyLabelMapping(Map<String, String> keyLabelMapping);
  Future<Map<String, String>> loadKeyLabelMapping();
  
  Future<dynamic> close();
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
  /// key used for caching - if this is left empty we simply use the first entry in keys.
  final String _cacheKey;
  
  AnalyzerConfig({this.sql, this.keys, this.labels, this.resultTransformer, String cacheKey}) 
      : _cacheKey = cacheKey {
    if (this.keys == null && this._cacheKey == null) {
      throw new Exception('either keys or cacheKey must not be null!');
    }
  }
  
  String get cacheKey => _cacheKey == null ? keys[0] : _cacheKey;
}

class AnalyzerContext {
  String analyzeType;
  AnalyzerContext(this.analyzeType);
}


class Analyzer {
  Analyzer();
  
  Map<String, String> _keyLabelMapping;
  
  Future analyzeConfigs(QueryExecutor executor, List<AnalyzerConfig> configs, AnalyzerCache cache) {
    if (cache != null) {
      Completer completer = new Completer();
      cache.loadKeyLabelMapping().then((keyLabelMapping) {
        executor = new CachedQueryExecutor(executor, cache);
        _analyzeConfigs(executor, configs, cache, keyLabelMapping: keyLabelMapping).then((v){
          cache.persistKeyLabelMapping(_keyLabelMapping);
          completer.complete(v);
        });
      });
      return completer.future;
    } else {
      return _analyzeConfigs(executor, configs, cache);
    }
  }

  Future _analyzeConfigs(QueryExecutor executor, List<AnalyzerConfig> configs, AnalyzerCache cache,
                         { Map<String, String> keyLabelMapping }) {
    Map<String, List<Map<String, num>>> dataByKey = {};
    List<Future> futures = [];
    _keyLabelMapping = keyLabelMapping;
    if (_keyLabelMapping == null) {
      _keyLabelMapping = {};
    }

    var weeklyContext = new AnalyzerContext('weekly');
    for (AnalyzerConfig config in configs) {
      // Run weekly analyzes..
      DateTime date = new DateTime.now();
      DateTime today = new DateTime(date.year, date.month, date.day);
      
      
      // go to a monday ..
      if (today.weekday != DateTime.MONDAY) {
        today = today.add(new Duration(days: 8 - today.weekday));
      } else {
        // no matter what, always go 1 week into the future..
        today = today.add(new Duration(days: 7));
      }
      DateTime start = new DateTime(today.year-1, today.month, today.day);
      Duration week = const Duration(days: 7);
      while (start.isBefore(today)) {
        DateTime next = today.subtract(week);
        var tmp = executor.execute(weeklyContext, config, next, today).then((data) {
          data.forEach((result) {
            var dataList = dataByKey[result.key];
            if (dataList == null) {
              dataList = dataByKey[result.key] = new List();
            }
            if (result.label != null && !_keyLabelMapping.containsKey(result.key)) {
              _keyLabelMapping[result.key]= result.label;
            }
            dataList.add({'x': next.millisecondsSinceEpoch ~/ 1000, 'y': result.value});
          });
        });
        futures.add(tmp);
        today = next;
      }
    }
    Completer completer = new Completer();
    Future.wait(futures).then((empty){
      // sort everything by x value.
      dataByKey.forEach((k, v){
        v.sort((a, b) => a['x'] - b['x']);
      });
      var store = { 'lastupdate': new DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    'lastupdatestr': new DateFormat('yyyy-MM-dd HH:mm').format(new DateTime.now()),
                    'dataByKey': dataByKey,
                    'keyLabelMapping': _keyLabelMapping };
      new File('latestdata.json').openWrite(encoding: Encoding.getByName('UTF-8')).write(JSON.encode(store));

      completer.complete();
    });
    return completer.future;
  }
}