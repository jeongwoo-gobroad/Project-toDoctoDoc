import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import 'package:to_doc/controllers/graph_controller.dart';
import 'package:to_doc/screens/graph/tag_list.dart';

class TagGraphBoard extends StatefulWidget {
  

  @override
  State<TagGraphBoard> createState() => _TagGraphBoardState();
}

class _TagGraphBoardState extends State<TagGraphBoard> {
  final TagGraphController graphController = Get.put(TagGraphController());
   final TransformationController _transformationController = TransformationController();
  final double minScale = 0.5;
  final double maxScale = 2.5;
  @override
  void initState() {
    super.initState();
    graphController.getGraph();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerView();
    });
  }
  void _centerView() { //중심원 기준으로 center잡기기
    final Matrix4 matrix = Matrix4.identity()
      ..translate(-MediaQuery.of(context).size.width,
                 -MediaQuery.of(context).size.height);
    _transformationController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Obx(() {
        final positions = HexagonalLayout(
          Size(MediaQuery.of(context).size.width * 3,MediaQuery.of(context).size.height * 3),
          //MediaQuery.of(context).size,
          graphController.tagList,
        );

         return InteractiveViewer(
          transformationController: _transformationController,
          minScale: minScale,
          maxScale: maxScale,
          boundaryMargin: EdgeInsets.all(500),
          constrained: false, 
          child: Stack(
            children: [
              
              Container(
                width: MediaQuery.of(context).size.width * 3,
                height: MediaQuery.of(context).size.height * 3,
                color: Colors.white,
              ),
              //edge, 원들 생성성
              ..._buildConnections(positions, graphController.tagGraph),
              ..._buildNodes(positions, graphController.tagList),
            ],
          ),
        );
      }),
    );
  }

  Map<String, Offset> HexagonalLayout(
    Size size,
    Map<String, int> tagList,
  ) {
    Map<String, Offset> positions = {};
    final center = Offset(size.width / 2, size.height / 2);

    final sortedTags = tagList.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Center node
    if (sortedTags.isNotEmpty) {
      positions[sortedTags.first.key] = center;
    }

    int currentIndex = 1;
    int ringNumber = 1;
    double baseRadius = 120.0;

    while (currentIndex < sortedTags.length) {
      for (int i = 0; i < 6 && currentIndex < sortedTags.length; i++) {
        double angle = (i * 60 + 30) * (pi / 180);
        double radius = baseRadius * ringNumber;

        Offset position = Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        );

        positions[sortedTags[currentIndex].key] = position;
        currentIndex++;
      }
      ringNumber++;
    }

    return positions;
  }

  List<Widget> _buildConnections(
    Map<String, Offset> positions,
    List<List<String>> tagGraph,
  ) {
    List<Widget> connectionWidgets = [];
    for (var connection in tagGraph) {
      if (connection.length < 2) continue;

      final tag1 = connection[0];
      final tag2 = connection[1];

      if (positions.containsKey(tag1) && positions.containsKey(tag2)) {
        final start = positions[tag1]!;
        final end = positions[tag2]!;

        connectionWidgets.add(
          Positioned.fill(
            child: CustomPaint(
              painter: ConnectionPainter(start: start, end: end),
            ),
          ),
        );
      }
    }
    return connectionWidgets;
  }

  List<Widget> _buildNodes(
    Map<String, Offset> positions,
    Map<String, int> tagList,
  ) {
    return positions.entries.map((entry) {
      final tag = entry.key;
      final position = entry.value;
      final radius = tagList[tag]! * 10;

      return Positioned(
        left: position.dx - radius,
        top: position.dy - radius,
        child: GestureDetector(
          onTap: () => _searchTagDetails(tag, tagList[tag]!),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(

                  shape: BoxShape.circle,
                  color: Colors.blue,

                ),
                
              ),
              SizedBox(height: 4),
              Text(
                tag,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: tagList[tag] ==
                          tagList.values.reduce((a, b) => max(a, b))
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _searchTagDetails(String tag, int count) {
    //print('$tag');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tag),
        content: Text('해당 tag를 가진 게시물로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(()=> TagList(tag: tag));
            },
            child: Text('예'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
            },
            child: Text('아니오'),
          ),
        ],
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  ConnectionPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
