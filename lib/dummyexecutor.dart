library dummyexecutor;

import 'package:timeline_charter/analyzer.dart';
import 'dart:async';
import 'dart:math';

class DummyExecutor extends QueryExecutor {
  
  Random _random;
  
  DummyExecutor() {
    _random = new Random();
  }
  
  Future<Iterable<AnalyzerResult>> execute(AnalyzerContext context, AnalyzerConfig config, DateTime start, DateTime end) {
    var completer = new Completer<Iterable<AnalyzerResult>>();
    var result = [
                  new AnalyzerResult(
                      key: 'dummy.example1',
                      label: 'Example 1',
                      value: _random.nextInt(1000)
                      ),
                  new AnalyzerResult(
                      key: 'dummy.example2',
                      label: 'Example 2',
                      value: _random.nextInt(1000)
                  ),
                      ];
    completer.complete(result);
    return completer.future;
  }
}
