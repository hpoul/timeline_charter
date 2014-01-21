A simple application to create time based charts based on simple SQL queries.

# Usage

## Create a new project and add polymer and timeline_charter as dependency

## Create a bin/runanalyzer.dart file to configure and run the analyzer

Example configuration objects:

Imagine you want statistics of the user activity for your app and have a database table
called 'actionlog' with a timestamp column. This is how a configuration would look like:

    var analyzerConfigs = [
            new AnalyzerConfig(
              sql: 'SELECT COUNT(*) FROM actionlog WHERE time BETWEEN @startTime AND @endTime',
              keys: const ['myapp.actionlog.count'],
              labels: const ['ActionLog Count']
            )
        ]

now we just need to use that config and run our analyzer:

    import 'package:timeline_charter/analyzer.dart';
    import 'package:timeline_charter/pgqueryexecutor.dart';
    import 'package:timeline_charter/worktrail_config.dart';
    import 'dart:io';
    import 'dart:async';
    
    int main() {
      print("hello.");
      var sqlurl = Platform.environment['WT_PGSQL'];
      if (sqlurl == null) {
        sqlurl = 'postgres://herbert:@localhost:5432/worktrail';
      }
      
      // open connection to postgresql database and open file cache ...
      var pgFuture = openPgQueryExecutor(sqlurl);
      var cacheFuture = SimpleFileCache.createSimpleFileCache(new Directory('cache'));
      Future.wait([pgFuture, cacheFuture]).then((valueList) {
        PgQueryExecutor executor = valueList[0];
        SimpleFileCache cache = valueList[1];
        // now that everything is set up, we can launch the analyzer.
        
        new Analyzer()
          .analyzeConfigs(executor, analyzerConfigs, cache)
          .whenComplete(() {
            executor.close();
            Future.wait([cache.close()]);
          });
      });
      return 0;
    }


## Create web/index.html to display the result

## Build app with pub

    pub build

## Run analyzer

    dart bin/runanalyzer.dart

## Copy latestdata.json into build/ directory

    cp latestdata.json build/

## Open build/index.html

(If you are hosting on file://, make sure to open it in Firefox, because 
chrome won't allow http requests to file:// protocol.)
