// http://stackoverflow.com/a/646643/109219
if (typeof String.prototype.startsWith != 'function') {
  String.prototype.startsWith = function (str){
    return this.slice(0, str.length) == str;
  };
}

d3.json('latestdata.json', function(error, json){
  var dataByKey = json.dataByKey;
  
  var palette = new Rickshaw.Color.Palette();
  
  var series = [];
  for(var key in json.keyLabelMapping) {
    if (key.startsWith('worktrail.actionlog.count.group')) {
      series.push({
        color: palette.color(),
        name: json.keyLabelMapping[key],
        data: dataByKey[key]
      });
      console.log('key: ' + key + ' has: ' + dataByKey[key].length);
    }
  }
  
  var graph = new Rickshaw.Graph( {
    //renderer: 'line',
    renderer: 'stack',
    element: document.querySelector('#chart'),
    width: 800,
    height: 300,
    series: series
  });
  var axes = new Rickshaw.Graph.Axis.Time( { graph: graph } );
  var y_axis = new Rickshaw.Graph.Axis.Y( {
        graph: graph,
        orientation: 'left',
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        element: document.getElementById('y_axis'),
} );
var hoverDetail = new Rickshaw.Graph.HoverDetail( {
    graph: graph
} );

  graph.render();
});
