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
  Color color;
  Offset? dragTarget;
  Offset? dragOffset;

  Bubble({
    required this.position,
    this.velocity = Offset.zero,
    required this.radius,
    required this.tag,
    required this.color,
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
  final double gravity = 180.0;
  final double restitution = 0.3;
  final double springStrength = 30.0;
  final double collisionSpringStrength = 300.0;
  final TagGraphController graphController =
      Get.put(TagGraphController(dio: Dio()));

  final double stabilityThreshold = 20.0; //낮을수록 버블이 더 stable해야함
  final int requiredStableFrames = 60; //더 길게 stable 해야함
  int stableFrameCount = 0;
  bool isSystemStable = false;
  double screenWidth = 0;
  double screenHeight = 0;
  final double bottomNavHeight = 80;
  bool showTrashCan = false;
  bool isDragging = false;
  final double trashCanHeight = 100.0;
  bool isTrashHighlighted = false;


  final double screenExitMargin = 300.0; 
  final double throwVelocityThreshold = 400.0;

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
    final tags = graphController.tags;

    final maxTagCount = tags.values
        .map((info) => info.tagCount)
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxViewCount = tags.values
        .map((info) => info.viewCount)
        .fold(0.0, (a, b) => a > b ? a : b);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    const baseHue = 240.0;
    const minLightness = 0.60;
    const maxLightness = 0.90;

    tags.forEach((tag, info) {
      final radius = 20.0 + (info.tagCount / maxTagCount) * 40.0;
      final lightness = maxLightness -
          (info.viewCount / maxViewCount) * (maxLightness - minLightness);
      final hslColor = HSLColor.fromAHSL(
        0.65,
        baseHue,
        0.85,
        lightness.clamp(minLightness, maxLightness),
      );
      final color = hslColor.toColor();

      final position = Offset(
        _random.nextDouble() * (screenWidth - radius * 2) + radius,
        -100 - _random.nextDouble() * 100,
      );

      bubbles.add(Bubble(
        position: position,
        radius: radius,
        tag: tag,
        velocity: Offset(0, 0),
        color: color,
      ));
    });
  }

  void _updatePhysics() {
    final dt = 1 / 60;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    _handleBubbleCollisions(dt);

    for (int i = bubbles.length - 1; i >= 0; i--) {
      final bubble = bubbles[i];

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

    final bool isOverTop = bubble.position.dy + bubble.radius < -screenExitMargin;
    final bool isThrownHard = bubble.velocity.dy < -throwVelocityThreshold;
    
      if (isOverTop && isSystemStable) {
      setState(() {
        bubbles.removeAt(i);
        print('bubble removed');
      });
      continue;
    }
      // if (showTrashCan && bubble.position.dy < trashCanHeight) {
      //   setState(() {
      //     bubbles.removeAt(i);
      //   });
      // }
      if (!isSystemStable) {
        if (_checkSystemStability()) {
          stableFrameCount++;
          if (stableFrameCount >= requiredStableFrames) {
            setState(() {
              isSystemStable = true;
              //showTrashCan = true;
            });
          }
        } else {
          stableFrameCount = 0;
        }
      }

      setState(() {});
    }
    
  }

  bool _checkSystemStability() {
    if (bubbles.isEmpty) return false;

    double totalVelocity = 0;
    for (final bubble in bubbles) {
      totalVelocity += bubble.velocity.distance;
    }

    double averageVelocity = totalVelocity / bubbles.length;
    return averageVelocity < stabilityThreshold;
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
          isDragging = true;
        });
        break;
      }
    }
  }

  void _handlePanUpdate(Offset globalPos) {
  bool overTrash = false;
  for (final bubble in bubbles) {
    if (bubble.dragOffset != null) {
      final newTarget = globalPos - bubble.dragOffset!;
      final currentTopEdge = bubble.position.dy - bubble.radius;
      overTrash = currentTopEdge < trashCanHeight;
      setState(() {
        bubble.dragTarget = newTarget;
      });
      break;
    }
  }
  setState(() {
    isTrashHighlighted = overTrash;
  });
}

  void _handlePanEnd() {
  bool removed = false;
  for (int i = 0; i < bubbles.length; i++) {
    final bubble = bubbles[i];
    if (bubble.dragOffset != null) {
      final topEdge = bubble.position.dy - bubble.radius;
      final isOverTrash = topEdge < trashCanHeight;
      bubble.velocity = bubble.velocity * 1.5;
      if (isOverTrash) {
        setState(() {
          bubbles.removeAt(i);
          graphController.tagBan(bubble.tag);
          removed = true;
        });
      } else {
        setState(() {
          bubble.dragOffset = null;
          bubble.dragTarget = null;
        });
      }
      break;
    }
  }
  setState(() {
    isDragging = false;
    isTrashHighlighted = false;
  });
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
              children: [
                if (isSystemStable && !isDragging)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.1,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '터치해서 게시물을 보거나,\n버블을 걱정과 함께 날려보내세요.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    AnimatedPositioned(
                      duration: Duration(milliseconds: 200),
                      top: isDragging ? 0 : -trashCanHeight,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: trashCanHeight,
                        decoration: BoxDecoration(
                          color: isTrashHighlighted
                              ? Colors.red
                              : Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '태그 차단',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ...bubbles.map((bubble) {
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
                          color: bubble.color,
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
              ],
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
