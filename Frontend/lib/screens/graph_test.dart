import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
class GraphController extends GetxController {
  var tagList = <String, int>{}.obs;
  var tagGraph = <String, String>{}.obs;
}

class GraphBoardTest extends StatelessWidget {
  GraphBoardTest({super.key});
  final GraphController graphController = Get.put(GraphController());

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터 초기화
    graphController.tagList.value = {
      'Tag1': 10,
      'Tag2': 5,
      'Tag3': 8,
      'Tag4': 3,
    };

    graphController.tagGraph.value = {
      'Tag1': 'Tag2',
      'Tag2': 'Tag3',
      'Tag3': 'Tag4',
      'Tag4': 'Tag1',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Graph Board'),
      ),
      body: Center(
        child: Obx(() {
          if (graphController.tagList.isEmpty || graphController.tagGraph.isEmpty) {
            return Text('데이터가 없습니다.');
          }

          return CustomPaint(
            size: Size(400, 400),
            painter: GraphPainter(
              tagList: graphController.tagList,
              tagGraph: graphController.tagGraph,
            ),
          );
        }),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final Map<String, int> tagList;
  final Map<String, String> tagGraph;

  GraphPainter({required this.tagList, required this.tagGraph});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final radius = 20.0;
    final center = Offset(size.width / 2, size.height / 2);

    final positions = <String, Offset>{};

    // 태그위치계산
    final angleStep = 2 * 3.14 / tagList.length;
    var angle = 0.0;
    tagList.forEach((tag, count) {
      final x = center.dx + (size.width / 3) * cos(angle);
      final y = center.dy + (size.height / 3) * sin(angle);
      positions[tag] = Offset(x, y);
      angle += angleStep;
    });

    // 태그 edge
    tagGraph.forEach((tag1, tag2) {
      final pos1 = positions[tag1]!;
      final pos2 = positions[tag2]!;
      canvas.drawLine(pos1, pos2, paint..color = Colors.grey);
    });

    // 태그원 그리기
    tagList.forEach((tag, count) {
      final pos = positions[tag]!;
      canvas.drawCircle(pos, radius, paint..color = Colors.blue);

      // 태그텍스트 
      textPainter.text = TextSpan(
        text: tag,
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}