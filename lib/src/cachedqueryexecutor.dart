part of analyzer;

/**
 * simple cache which simply proxies query executor calls and adds a cache layer.
 */
class CachedQueryExecutor extends QueryExecutor {
  QueryExecutor executor;
  AnalyzerCache cache;
  DateTime now;
  CachedQueryExecutor(this.executor, this.cache) {
    now = new DateTime.now();
  }
  
  

  Future<Iterable<AnalyzerResult>> execute(AnalyzerContext context, AnalyzerConfig config, DateTime start, DateTime end) {
    Completer completer = new Completer<Iterable<AnalyzerResult>>();
    var cacheKey = new AnalyzerCacheKey(config.cacheKey, context.analyzeType, start.millisecondsSinceEpoch);
    
    Future<Map<String, num>> cacheLookup;
    if (end.isAfter(now)) {
      // we are analyzing a time period of the future, so there can't be a cache yet..
      var tmp = new Completer<Map<String, num>>()..complete(null);
      cacheLookup = tmp.future;
    } else {
      cacheLookup = cache.getCache(cacheKey);
    }
    cacheLookup.then((value) {
      if (value != null) {
        List<AnalyzerResult> resultList = new List();
        value.forEach((k, v) {
          resultList.add(new AnalyzerResult(key: k, value: v));
        });
        completer.complete(resultList);
      } else {
        // nothing found in cache..
        executor.execute(context, config, start, end).then((resultList) {
          if (end.isBefore(now)) {
            // only put into cache, if the end is before now.
            Map<String, num> cacheResult = {};
            for(AnalyzerResult result in resultList) {
              cacheResult[result.key] = result.value;
            }
            cache.putCache(cacheKey, cacheResult);
          }
          
          completer.complete(resultList);
        });
      }
      
    });
    return completer.future;
  }
}
