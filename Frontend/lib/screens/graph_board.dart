
import 'package:flutter/material.dart';
import 'package:to_doc/controllers/graph_controller.dart';
import 'package:get/get.dart';

class GraphBoard extends StatelessWidget {

  GraphBoard({super.key});
  TagGraphController tagGraphController = Get.put(TagGraphController());

  Future<void> _graph() async {

    await tagGraphController.getGraph();
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _graph,
           child: Text('누르세요'),
        ),
      ),

    );
  }
}