library tapo_graph;

import 'dart:js';
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';

@CustomTag('tapo-graph')
class TapoGraph extends PolymerElement {
  TapoGraph.created() : super.created();
  
  @published String prefix;
  @published String loadjson;
  @observable String lastupdatestr;
  
  void enteredView() {
    super.enteredView();
    
    HttpRequest.getString(loadjson).then((v) {
      var obj = JSON.decode(v);
      lastupdatestr = obj['lastupdatestr'];
      context.callMethod('loadAndDraw', 
          [ getShadowRoot('tapo-graph').querySelector('.chartwrapper'),
            prefix,
            new JsObject.jsify(obj)]);
    });
    
    //context.callMethod('blubber');
    //context.callMethod('blubber', [getShadowRoot('tapo-graph').querySelector('.testing')]);
//    context['blubber'];
  }
}