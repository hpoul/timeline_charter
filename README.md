A simple application/framework based on dart to create time based charts 
based on simple SQL queries. It currently has a very limited featureset, but
great potential ;)

# Example

See the example project for a sample usage:

* Web: http://hpoul.github.io/timeline_charter_example/
* Code: https://github.com/hpoul/timeline_charter_example/

This is how it (should) look:

![Sample Image](https://raw.github.com/hpoul/timeline_charter/master/docs/timeline_charter_screenshot.png)

# Status

This is still a very experimental state, and it is quite hard to actually use
it. In addition it currently only supports one chart format:

* 1 Year duration, 7 day intervals.

Seems quite limited, and it actually is. But the config is generic enough
to improve the implementation and the charts.

# Why?

I wanted a simple way to analyze usage statistics from my database. But 
configuring zabbix & co is a bit annoying, slow and you get no historical
data. If you know a better tool for the job, which you can configure by
simply a one-liner SQL statement, let me know!

# Implementation

There are two parts:

1. Analyzer: Dart application which runs the analysis and simply stores 
   key/value pairs to a given timestamp. **This has to be run from a cronjob
   or similar**.
2. Web Component: Dart polymer component (which interally uses 
   https://github.com/shutterstock/rickshaw to display the charts)

# Usage

## Create a new dart project and add polymer and timeline_charter as dependency

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

    <!DOCTYPE html>

    <html>
      <head>
	<title>Analytics</title>
	<link rel="import" href="packages/timeline_charter/tapo_graph.html" />
      </head>
     
      <body>   
	Action Log Count:<br />
	
	<tapo-graph prefix="dummy" loadjson="latestdata.json"></tapo-graph>
	<br /><br />
	<script type='application/dart'>export 'package:polymer/init.dart';
	</script>
	<script src="packages/browser/dart.js"></script>
      </body>
    </html>

## Build app with pub

    pub build

## Run analyzer

    dart bin/runanalyzer.dart

## Copy latestdata.json into build/ directory

    cp latestdata.json build/

## Open build/index.html

(If you are hosting on file://, make sure to open it in Firefox, because 
chrome won't allow http requests to file:// protocol.)





[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/hpoul/timeline_charter/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
