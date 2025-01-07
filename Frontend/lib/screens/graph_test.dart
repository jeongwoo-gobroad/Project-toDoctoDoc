import 'package:flutter/material.dart';
import 'dart:math' as math;



class TagNode {
  final String tag;
  final int count;
  Offset position;

  TagNode(this.tag, this.count) : position = Offset.zero;
}

class TagEdge {
  final String tag1;
  final String tag2;

  TagEdge(this.tag1, this.tag2);
}

class TagGraphBoard extends StatefulWidget {
  const TagGraphBoard({Key? key}) : super(key: key);

  @override
  State<TagGraphBoard> createState() => _TagGraphBoardState();
}

class _TagGraphBoardState extends State<TagGraphBoard> {
  
  //같은 형식의의 샘플데이터
  final Map<String, int> _tagList = {
    'Flutter': 100,
    'Dart': 80,
    'Mobile': 60,
    'Web': 45,
    'iOS': 40,
    'Android': 35,
    'React': 30,
    'JavaScript': 25,
    'UI': 20,
    'Design': 15,
  };

  final List<TagEdge> _tagGraph = [
    TagEdge('Flutter', 'Dart'),
    TagEdge('Flutter', 'Mobile'),
    TagEdge('Flutter', 'Web'),
    TagEdge('Mobile', 'iOS'),
    TagEdge('Mobile', 'Android'),
    TagEdge('Web', 'JavaScript'),
    TagEdge('Web', 'React'),
  ];
  late List<TagNode> nodes;

  @override
  void initState() {
    super.initState();
    _initializeNodes();
  }

  void _initializeNodes() {
    nodes = _tagList.entries
        .map((e) => TagNode(e.key, e.value))
        .toList();
    
    //노드들을 원형으로 배치치
    final centerX = 400.0;
    final centerY = 300.0;
    final radius = 200.0;
    
    for (var i = 0; i < nodes.length; i++) {
      final angle = (2 * math.pi * i) / nodes.length;
      nodes[i].position = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      height: 600,
      child: CustomPaint(
        painter: TagGraphPainter(nodes, _tagGraph),
      ),
    );
  }
}

class TagGraphPainter extends CustomPainter { //taggraph는 node간 연결정의의
  final List<TagNode> nodes;
  final List<TagEdge> edges;

  TagGraphPainter(this.nodes, this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    final linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    
     //edge 그리기기
    for (var edge in edges) {
      final node1 = nodes.firstWhere((n) => n.tag == edge.tag1);
      final node2 = nodes.firstWhere((n) => n.tag == edge.tag2);
      canvas.drawLine(node1.position, node2.position, linePaint);
    }

    //노드는 int값 클수록 큰모형나타내게 구현
    for (var node in nodes) {
      final radius = 20 + (node.count / 10);
      canvas.drawCircle(node.position, radius, paint);

      //tag 이름
      final textSpan = TextSpan(
        text: node.tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        node.position.translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}