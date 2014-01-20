part of analyzer;

class SimpleFileCache extends AnalyzerCache {
  File jsonFile;
  Map values;
  Map keyLabelMapping;
  
  SimpleFileCache._(this.jsonFile, this.values, this.keyLabelMapping) {
  }
  
  static Future<SimpleFileCache> createSimpleFileCache(Directory basePath) {
    Completer<SimpleFileCache> completer = new Completer<SimpleFileCache>();
    basePath.create(recursive: true).then((dir){
      File jsonFile = new File('${dir.path}/cache.json');
      if (jsonFile.existsSync()) {
        jsonFile.readAsString(encoding: Encoding.getByName('UTF-8')).then((content) {
          Map tmp = JSON.decode(content);
          completer.complete(new SimpleFileCache._(jsonFile, tmp['values'], tmp['keyLabelMapping']));
        });
      } else {
        jsonFile.createSync();
        completer.complete(new SimpleFileCache._(jsonFile, {}, {}));
      }
    });
    return completer.future;
  }
  
  Future<Map<String, num>> getCache(AnalyzerCacheKey cacheKey) {
    var completer = new Completer<Map<String, num>>();
    completer.complete(values[cacheKey.asStringKey()]);
    return completer.future;
  }

  void putCache(AnalyzerCacheKey cacheKey, Map<String, num> value) {
    values[cacheKey.asStringKey()] = value;
  }

  Future<dynamic> close() {
    return jsonFile.writeAsString(JSON.encode({'values': values, 'keyLabelMapping': keyLabelMapping}));
  }

  Future<Map<String, String>> loadKeyLabelMapping() {
    var completer = new Completer<Map<String,String>>();
    completer.complete(keyLabelMapping);
    return completer.future;
  }

  void persistKeyLabelMapping(Map<String, String> keyLabelMapping) {
    this.keyLabelMapping = keyLabelMapping;
  }
}