import 'package:sql_charter_server/analyzer.dart';

/*
var ApiKeyMap = {
                 1: 'jquerywebui',
                 2: 'dartwebui',
                 3: 'iosapp',
                 4: '',
};
*/

var workTrailConfig = [
            const AnalyzerConfig(
              sql: 'SELECT COUNT(*) FROM saas_actionlog WHERE time BETWEEN @startTime AND @endTime',
              keys: const ['worktrail.actionlog.count'],
              labels: const ['ActionLog Count']
            ),
            new AnalyzerConfig(
                //sql: 'SELECT apikey_id, k.label, COUNT(*) from saas_actionlog al left join saas_apikey k on k.id = al.apikey_id WHERE time BETWEEN @startTime AND @endTime group by al.apikey_id, k.label;',
                sql: 'select k.id, k.label, count(al.id) from saas_apikey k LEFT JOIN saas_actionlog al on k.id = al.apikey_id AND al.actiontype != \'ping\' AND time BETWEEN @startTime AND @endTime group by k.id, k.label;',
                resultTransformer: (List<dynamic> result) {
                  print('mapping ${result}');
                  return result.map((row) =>
                    new AnalyzerResult(key: 'worktrail.actionlog.count.grouped.${row[0]}', label: row[1], value: row[2]) );
                }
            ),
];
