import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/graph_controller.dart';
import 'package:to_doc/screens/graph/tag_list.dart';

class Bubble {
  Offset position;
  Offset velocity;
  double radius;
  String tag;
  Offset? dragTarget;
  Offset? dragOffset;

  Bubble({
    required this.position,
    this.velocity = Offset.zero,
    required this.radius,
    required this.tag,
  });
}

class GraphBoard extends StatefulWidget {
  @override
  State<GraphBoard> createState() => _GraphBoardState();
}

class _GraphBoardState extends State<GraphBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<Bubble> bubbles = [];
  final double gravity = 180.0; //떨어지느속도도
  final double restitution = 0.3; //튀는정도 (탄성)
  final double springStrength = 10.0; //드래그 반응속도
  final double collisionSpringStrength = 300.0; //서로 밀어내는 정도
  final TagGraphController graphController =
      Get.put(TagGraphController(dio: Dio()));
  double screenWidth = 0;
  double screenHeight = 0;
  final double bottomNavHeight = 80;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_updatePhysics);

    graphController.getGraph().then((_) {
      _createTagBallsFromServerData();
      _controller.forward();
    });
  }

  void _createTagBallsFromServerData() {
    final sortedTags = graphController.tagList.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedTags.first.value.toDouble();
    final minCount = sortedTags.last.value.toDouble();

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    final double startY = -100;
    final double padding = 10;

    for (final entry in sortedTags) {
      final tag = entry.key;
      final count = entry.value;

      final normalizedSize = (count - minCount) / (maxCount - minCount);
      final radius = 20.0 + (normalizedSize * 20.0);

      final position = Offset(
        _random.nextDouble() * (screenWidth - radius * 2) + radius,
        startY - _random.nextDouble() * 100,
      );

      bubbles.add(Bubble(
        position: position,
        radius: radius,
        tag: tag,
        velocity: Offset(0, 0),
      ));
    }
  }

  void _updatePhysics() {
    final dt = 1 / 60;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    _handleBubbleCollisions(dt);
    for (final bubble in bubbles) {
      if (bubble.dragTarget != null) {
        final toTarget = bubble.dragTarget! - bubble.position;
        bubble.velocity += toTarget * springStrength * dt;
        bubble.velocity *= 0.9;
      } else {
        bubble.velocity += Offset(0, gravity) * dt;
      }

      bubble.position += bubble.velocity * dt;

      final groundY = screenHeight - bottomNavHeight - bubble.radius;
      if (bubble.position.dy > groundY) {
        bubble.position = Offset(bubble.position.dx, groundY);
        bubble.velocity =
            Offset(bubble.velocity.dx, -bubble.velocity.dy * restitution);
      }

      if (bubble.position.dx - bubble.radius < 0) {
        bubble.position = Offset(bubble.radius, bubble.position.dy);
        bubble.velocity =
            Offset(-bubble.velocity.dx * restitution, bubble.velocity.dy);
      } else if (bubble.position.dx + bubble.radius > screenWidth) {
        bubble.position =
            Offset(screenWidth - bubble.radius, bubble.position.dy);
        bubble.velocity =
            Offset(-bubble.velocity.dx * restitution, bubble.velocity.dy);
      }
    }
    setState(() {});
  }

  void _handleBubbleCollisions(double dt) {
    for (int i = 0; i < bubbles.length; i++) {
      for (int j = i + 1; j < bubbles.length; j++) {
        final a = bubbles[i];
        final b = bubbles[j];

        final dx = a.position.dx - b.position.dx;
        final dy = a.position.dy - b.position.dy;
        final distanceSquared = dx * dx + dy * dy;
        final minDistance = a.radius + b.radius;

        if (distanceSquared < minDistance * minDistance &&
            distanceSquared > 0) {
          final distance = sqrt(distanceSquared);
          final overlap = minDistance - distance;
          final direction = Offset(dx, dy) / distance;

          final totalMass = a.radius + b.radius;
          final ratioA = b.radius / totalMass;
          final ratioB = a.radius / totalMass;

          final force = direction * overlap * collisionSpringStrength * dt;

          a.velocity += force * ratioA;
          b.velocity -= force * ratioB;

          final correction = direction * overlap * 0.5;
          a.position += correction * ratioA;
          b.position -= correction * ratioB;
        }
      }
    }
  }

  void _handlePanStart(Offset globalPos) {
    for (final bubble in bubbles) {
      final distance = (globalPos - bubble.position).distance;
      if (distance <= bubble.radius) {
        setState(() {
          bubble.dragOffset = globalPos - bubble.position;
          bubble.dragTarget = bubble.position;
        });
        break;
      }
    }
  }

  void _handlePanUpdate(Offset globalPos) {
    for (final bubble in bubbles) {
      if (bubble.dragOffset != null) {
        setState(() {
          bubble.dragTarget = globalPos - bubble.dragOffset!;
        });
        break;
      }
    }
  }

  void _handlePanEnd() {
    for (final bubble in bubbles) {
      if (bubble.dragOffset != null) {
        setState(() {
          bubble.dragOffset = null;
          bubble.dragTarget = null;
        });
        break;
      }
    }
  }

  void _searchTagDetails(String tag, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tag),
        content: Text('해당 tag를 가진 게시물로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => TagList(tag: tag));
            },
            child: Text('예'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('아니오'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (graphController.isLoading == true) {
          return Center(child: CircularProgressIndicator());
        } else {
          return GestureDetector(
            onPanStart: (d) => _handlePanStart(d.globalPosition),
            onPanUpdate: (d) => _handlePanUpdate(d.globalPosition),
            onPanEnd: (d) => _handlePanEnd(),
            child: Stack(
              children: bubbles.map((bubble) {
                return Positioned(
                  left: bubble.position.dx - bubble.radius,
                  top: bubble.position.dy - bubble.radius,
                  child: GestureDetector(
                    onTap: () => _searchTagDetails(bubble.tag, 1),
                    child: Container(
                      width: bubble.radius * 2,
                      height: bubble.radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.8),
                      ),
                      child: Center(
                        child: Text(
                          bubble.tag,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
