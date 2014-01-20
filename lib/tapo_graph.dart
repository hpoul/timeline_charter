library tapo_graph;

import 'dart:js';
import 'package:polymer/polymer.dart';

@CustomTag('tapo-graph')
class TapoGraph extends PolymerElement {
  TapoGraph.created() : super.created();
  
  @published String prefix;
  
  void enteredView() {
    super.enteredView();
    //context.callMethod('blubber');
    //context.callMethod('blubber', [getShadowRoot('tapo-graph').querySelector('.testing')]);
    context.callMethod('loadAndDraw', [getShadowRoot('tapo-graph').querySelector('.chartwrapper'), prefix]);
//    context['blubber'];
  }
}