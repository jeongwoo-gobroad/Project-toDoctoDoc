import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:forge2d/forge2d.dart';
import 'dart:math';

import 'package:to_doc/controllers/graph_controller.dart';
import 'package:to_doc/screens/graph/tag_list.dart';

class GraphBoard extends StatefulWidget {
  @override
  State<GraphBoard> createState() => _GraphBoardState();
}

class _GraphBoardState extends State<GraphBoard> with SingleTickerProviderStateMixin {
  late World world;
  late AnimationController _controller;
  List<Body> circleBodies = [];
  final Random _random = Random();
  final double gravityForce = 20;
  late Body groundBody;
  MouseJoint? mouseJoint;
  late Timer _timer;

  final TagGraphController graphController = Get.put(TagGraphController(dio: Dio()));
@override
  void initState() {
    super.initState();
    
    world = World(Vector2(0, 500.0));
    groundBody = world.createBody(BodyDef());
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(() {
        world.stepDt(1 / 60);
        setState(() {});
      });
    
    graphController.getGraph().then((_) {
      _createTagBallsFromServerData();
      _controller.forward();
    });


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createBoundaries();
    
      final bodyDef = BodyDef()..type = BodyType.static;
      groundBody = world.createBody(bodyDef);
      
      
    });
  }
  void _createTagBallsFromServerData() {
  
    final sortedTags = graphController.tagList.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedTags.first.value.toDouble();
    final minCount = sortedTags.last.value.toDouble();
    
    for (final entry in sortedTags) {
      final tag = entry.key;
      final count = entry.value;
      

      final normalizedSize = (count - minCount) / (maxCount - minCount);
      final radius = 20.0 + (normalizedSize * 20.0);
      
      final position = Vector2(
        _random.nextDouble() * (MediaQuery.of(context).size.width - radius * 2) + radius,
        -radius * 2,
      );

      final bodyDef = BodyDef()
        ..type = BodyType.dynamic
        ..position = position;
      final body = world.createBody(bodyDef);

      final shape = CircleShape()..radius = radius;
      final fixtureDef = FixtureDef(shape)
        ..density = 1.0
        ..friction = 0.3
        ..restitution = 0.7;
      body.createFixture(fixtureDef);

      body.userData = tag;

      circleBodies.add(body);
    }
  }
  void _createBoundaries() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomNavHeight = 80;

    final groundBodyDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(0, screenHeight - bottomNavHeight);
    final groundBody = world.createBody(groundBodyDef);
    final groundShape = EdgeShape()
      ..set(Vector2(0, 0), Vector2(screenWidth, 0));
    groundBody.createFixtureFromShape(groundShape)
      ..friction = 0.3
      ..restitution = 0.5;

    //왼쪽 벽
    final leftWallDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(0, 0);
    final leftWall = world.createBody(leftWallDef);
    final leftShape = EdgeShape()
      ..set(Vector2(0, 0), Vector2(0, screenHeight - bottomNavHeight));
    leftWall.createFixtureFromShape(leftShape)
      ..friction = 0.3
      ..restitution = 0.7;

    //오른쪽 벽
    final rightWallDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(screenWidth, 0);
    final rightWall = world.createBody(rightWallDef);
    final rightShape = EdgeShape()
      ..set(Vector2(0, 0), Vector2(0, screenHeight - bottomNavHeight));
    rightWall.createFixtureFromShape(rightShape)
      ..friction = 0.3
      ..restitution = 0.7;
}

  void _createTagBalls() {
    final List<int> tagValues = List.generate(10, (index) => _random.nextInt(50) + 1);

    for (int i = 0; i < tagValues.length; i++) {
      final radius = 20.0 + tagValues[i] * 0.5;
      final position = Vector2(_random.nextDouble() * MediaQuery.of(context).size.width, -radius * 2);

      final bodyDef = BodyDef()
        ..type = BodyType.dynamic
        ..position = position;
      final body = world.createBody(bodyDef);

      final shape = CircleShape()..radius = radius;
      final fixtureDef = FixtureDef(shape)
        ..density = 1.0
        ..friction = 0.3
        ..restitution = 0.7;
      body.createFixture(fixtureDef);

 
      //body.setLinearVelocity(Vector2(0, 15.0));


      body.userData = "Tag $i";

      circleBodies.add(body);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Obx(() {
    if (graphController.isLoading == true) {
      return Center(child: CircularProgressIndicator(),);
    } else {
      return Stack(
        children: [
          for (var body in circleBodies)
            Positioned(
              left: body.position.x - (body.fixtures.first.shape as CircleShape).radius,
              top: body.position.y - (body.fixtures.first.shape as CircleShape).radius,
              child: GestureDetector(
                onTap: () => _searchTagDetails(body.userData.toString(), 1),
                  onPanStart: (details) {
                    final dx = details.localPosition.dx;
                    final dy = details.localPosition.dy;
                    
                    final mouseJointDef = MouseJointDef()
                    
                      ..bodyA = groundBody
                      ..bodyB = body
                      ..target.setFrom(body.position)
                      ..maxForce = 3000 * body.mass
                      ..collideConnected = true;
                    
                    mouseJoint = world.createJoint(MouseJoint(mouseJointDef)) as MouseJoint;
                  },
                  onPanUpdate: (details) {
                    
                    if (mouseJoint == null) return;
                    
                    final screenWidth = MediaQuery.of(context).size.width;
                    final screenHeight = MediaQuery.of(context).size.height;
                    final radius = (body.fixtures.first.shape as CircleShape).radius;
                    
                    final dx = details.globalPosition.dx.clamp(radius, screenWidth - radius);
                    final dy = details.globalPosition.dy.clamp(radius, screenHeight - radius);
                    
                    mouseJoint?.setTarget(Vector2(dx, dy));
                    
                    
                  },
                  onPanEnd: (details) {
                   
                    if (mouseJoint != null) {
                      world.destroyJoint(mouseJoint!);
                      mouseJoint = null;
                    }
                  },
                  child: Container(
                    width: (body.fixtures.first.shape as CircleShape).radius * 2,
                    height: (body.fixtures.first.shape as CircleShape).radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.8),
                    ),
                    child: Center(
                      child: Text(
                        body.userData?.toString() ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ),
          ],
        );
      }
    }),
    );

  


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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
