import 'package:sql_charter_server/analyzer.dart';
import 'package:sql_charter_server/pgqueryexecutor.dart';
import 'package:sql_charter_server/worktrail_config.dart';

int main() {
  print("hello.");
  openPgQueryExecutor('postgres://herbert:@localhost:5432/worktrail').then((executor) {
    print('connected.');
    new Analyzer()
      .analyzeConfigs(executor, workTrailConfig)
      .whenComplete(() {
        executor.close();
      });
  });
  return 0;
}