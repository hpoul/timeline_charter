import 'package:timeline_charter/analyzer.dart';
import 'package:timeline_charter/pgqueryexecutor.dart';
import 'package:timeline_charter/worktrail_config.dart';
import 'dart:io';
import 'dart:async';

int main() {
  print("hello.");
  
  var pgFuture = openPgQueryExecutor('postgres://herbert:@localhost:5432/worktrail');
  var cacheFuture = SimpleFileCache.createSimpleFileCache(new Directory('cache'));
  Future.wait([pgFuture, cacheFuture]).then((valueList) {
    PgQueryExecutor executor = valueList[0];
    SimpleFileCache cache = valueList[1];
    print('connected.');
    
    //var cachedExecutor = new CachedQueryExecutor(executor, cache);
    new Analyzer()
      .analyzeConfigs(executor, workTrailConfig, cache)
      .whenComplete(() {
        executor.close();
        Future.wait([cache.close()]);
      });
  });
  return 0;
}