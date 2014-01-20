


d3.json('latestdata.json', function(error, json){
  var dataByKey = json.dataByKey;
  drawChart(document.querySelector('#chartwrapper'), json.keyLabelMapping, json.dataByKey, 'worktrail.actionlog.count.group');
  drawChart(document.querySelector('#chartwrapper2'), json.keyLabelMapping, json.dataByKey, 'worktrail.company.creation');
  document.querySelector('#lastupdated').innerHTML = 'Last updated ' + json.lastupdatestr;
  
});
