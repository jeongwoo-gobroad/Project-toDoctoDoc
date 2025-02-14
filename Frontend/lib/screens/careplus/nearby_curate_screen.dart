import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:to_doc/controllers/hospital/hospital_information_controller.dart';
import 'package:to_doc/screens/hospital/hospital_detail_view.dart';


class NearbyCurateScreen extends StatefulWidget {
  const NearbyCurateScreen({super.key});

  @override
  _NearbyCurateScreenState createState() => _NearbyCurateScreenState();
}

class _NearbyCurateScreenState extends State<NearbyCurateScreen> {
  final CurateListController curateListController =
      Get.put(CurateListController());
  double fastWeight = 0.33;
  double distWeight = 0.33;
  double starWeight = 0.34;

  void _updateWeights(double newFast, double newDist) {
    setState(() {
      fastWeight = newFast;
      distWeight = newDist;
      starWeight = (1 - newFast - newDist).clamp(0.0, 1.0);
    });
  }

  void _showHospitalDialog() {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return HospitalPopupDialog();
    //   },
    // );

    //애니메이션 효과과
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "HospitalDialog",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: HospitalPopupDialog(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      },
    );
  }

  void _getHospital() async {
    await curateListController.nearbyCurating(
        fastWeight, distWeight, starWeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '내 맞춤 병원 찾기',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff5f7fa), Color.fromARGB(255, 225, 234, 205)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _WeightIndicator(
                          label: '시간 빠른 순',
                          value: fastWeight,
                          color: Color(0xFFAEC6CF),
                        ),
                        const SizedBox(height: 16),
                        _WeightIndicator(
                          label: '거리순',
                          value: distWeight,
                          color: Color(0xFF98FB98),
                        ),
                        const SizedBox(height: 16),
                        _WeightIndicator(
                          label: '평점 높은 순',
                          value: starWeight,
                          color: Color(0xFFFFDAB9),
                        ),
                        const SizedBox(height: 24),
                        _InteractiveSlider(
                          fast: fastWeight,
                          dist: distWeight,
                          onChanged: _updateWeights,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _PercentageLabel(value: fastWeight, label: '시간'),
                            _PercentageLabel(value: distWeight, label: '거리'),
                            _PercentageLabel(value: starWeight, label: '평점'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () {
                    print(
                        '가중치// 시간: ${fastWeight}, 거리: ${distWeight}, 평점: ${starWeight}');
                    _getHospital();
                    _showHospitalDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 113, 190, 115),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '적용하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveSlider extends StatefulWidget {
  final double fast;
  final double dist;
  final Function(double, double) onChanged;

  const _InteractiveSlider({
    required this.fast,
    required this.dist,
    required this.onChanged,
  });

  @override
  __InteractiveSliderState createState() => __InteractiveSliderState();
}

class __InteractiveSliderState extends State<_InteractiveSlider> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _updatePositionFromWeights();
  }

  void _updatePositionFromWeights() {
    final y = 200 * (1 - widget.fast);
    final x = 100 * widget.fast + 200 * widget.dist;
    _position = Offset(x.clamp(0.0, 200.0), y.clamp(0.0, 200.0));
  }

  void _updateWeightsFromPosition(Offset pos) {
    double x = pos.dx.clamp(0.0, 200.0);
    double y = pos.dy.clamp(0.0, 200.0);

    double a = 1 - y / 200;
    double b = (y + 200 - 2 * x) / 400;
    double c = (2 * x + y - 200) / 400;

    a = a.clamp(0.0, 1.0);
    b = b.clamp(0.0, 1.0);
    c = c.clamp(0.0, 1.0);

    double sum = a + b + c;
    if (sum > 0) {
      a /= sum;
      b /= sum;
    } else {
      a = 1.0;
      b = 0.0;
    }

    final newY = 200 * (1 - a);
    final newX = 100 * a + 200 * (1 - a - b);

    setState(() {
      _position = Offset(newX, newY);
    });

    widget.onChanged(a, b);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPos = renderBox.globalToLocal(details.globalPosition);
        _updateWeightsFromPosition(localPos);
      },
      child: SizedBox(
        width: 200,
        height: 200,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrianglePainter(offsetY: 5.0),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  left: _position.dx - 16,
                  top: _position.dy - 16,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: w / 2 - 12,
                  top: -5,
                  child: Text(
                    '시간',
                    style: TextStyle(color: Color.fromARGB(255, 16, 103, 134), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: h - 13,
                  child: Text(
                    '거리',
                    style: TextStyle(color: Color.fromARGB(255, 56, 209, 56), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  left: w - 24,
                  top: h - 13,
                  child: Text(
                    '평점',
                    style: TextStyle(color: Color.fromARGB(255, 238, 147, 67), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PercentageLabel extends StatelessWidget {
  final double value;
  final String label;

  const _PercentageLabel({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${(value * 100).toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[800]),
        ),
      ],
    );
  }
}

class _WeightIndicator extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _WeightIndicator(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey[300],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 220 * value,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HospitalPopupDialog extends StatefulWidget {
  @override
  State<HospitalPopupDialog> createState() => _HospitalPopupDialogState();
}

class _HospitalPopupDialogState extends State<HospitalPopupDialog> {
  final CurateListController curateListController =
      Get.find<CurateListController>();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '추천 병원 리스트',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (curateListController.nearbyLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (curateListController.curatedList.isEmpty) {
                  return const Center(child: Text("추천 병원이 없습니다."));
                }

                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                          HapticFeedback.lightImpact();
                        },
                        itemCount: curateListController.curatedList.length,
                        itemBuilder: (context, index) {
                          final hospital = curateListController.curatedList[index];
                          print(hospital.myProfileImage);
                          return HospitalCard(
                            name: hospital.name,
                            hospitalName: hospital.myPsyID.name,
                            pid: hospital.myPsyID.id,
                            rating: hospital.myPsyID.stars,
                            address: hospital.myPsyID.address.address,
                            detailAddress: hospital.myPsyID.address.detailAddress,
                            extraAddress: hospital.myPsyID.address.extraAddress,
                            isPremiumPsy: hospital.myPsyID.isPremiumPsy,
                            myProfileImage: hospital.myProfileImage,
                            longitude : hospital.myPsyID.address.longitude,
                            latitude : hospital.myPsyID.address.latitude,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        curateListController.curatedList.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: _currentPage == index ? 12.0 : 8.0,
                          height: _currentPage == index ? 12.0 : 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalCard extends StatefulWidget {
  final String name;
  final String hospitalName;
  final String pid;
  final double rating;
  final String address;
  final String detailAddress;
  final String extraAddress;
  final bool isPremiumPsy;
  final String? myProfileImage;
  final double longitude;
  final double latitude;

  const HospitalCard({
    super.key,
    required this.name,
    required this.hospitalName,
    required this.pid,
    required this.rating,
    required this.address,
    required this.detailAddress,
    required this.extraAddress,
    required this.isPremiumPsy,
    required this.myProfileImage,
    required this.longitude,
    required this.latitude,

  });

  @override
  State<HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<HospitalCard> with TickerProviderStateMixin {
  bool _showMap = false;
  Set<Marker> markers = {};
  late KakaoMapController kakaoMapController;
  bool _showDetailAddress = false;
  HospitalInformationController hospitalInformationController = Get.put(HospitalInformationController());
  openHospitalDetailView(BuildContext context, Map<String, dynamic> hospital) {
    showModalBottomSheet(
      //shape : ,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      elevation: 0,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          snap: true,
          snapSizes: [0.2, 1.0],
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(height: 2000, child: HospitalDetailView(hospital: hospital))
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.myProfileImage != "" 
                  ? NetworkImage(widget.myProfileImage!) 
                  : null,
              child: widget.myProfileImage == "" 
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '의사 ${widget.name}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.isPremiumPsy) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '프리미엄',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.hospitalName,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 12),
            _buildStarRating(widget.rating),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.address,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _showMap ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                height: _showMap ? 90 : 0,
                child: _showMap
                    ? KakaoMap(
                        onMapCreated: (controller) async {
                                              markers.add(Marker(
                            markerId: UniqueKey().toString(),
                            latLng: LatLng(widget.latitude, widget.longitude),
                          ));
                          setState(() { });

                        },
                        markers: markers.toList(),
                        center: LatLng(widget.latitude, widget.longitude),
                        
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            //TODO 카카오맵 누르면 좀 큰화면에서 볼수있도록록
             ElevatedButton(
              onPressed: () async {
                if (await hospitalInformationController.getHospitalInformation(widget.pid)) {
                  openHospitalDetailView(context, hospitalInformationController.hospital);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 165, 168, 167),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '자세히 보기',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 225, 234, 205),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  '선택하기',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    final List<Widget> stars = [];

    int fullStars = rating.floor();
    double fraction = rating - fullStars;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber));
    }
    if (fraction >= 0.75) {
      stars.add(const Icon(Icons.star, color: Colors.amber));
    } else if (fraction >= 0.25) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber));
    }
    return Row(children: stars);
  }
}

class _TrianglePainter extends CustomPainter {
  final double offsetY; // 위로 올릴 픽셀 수

  _TrianglePainter({this.offsetY = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Gradient gradient = LinearGradient(
      colors: [Color(0xFFAEC6CF).withOpacity(0.3), Color(0xFFFFDAB9).withOpacity(0.3)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final Paint fillPaint = Paint()..shader = gradient.createShader(rect);
    
    final double side = size.width;
    final double height = (sqrt(3) / 2) * side;
    final double verticalPadding = ((size.height - height) / 2) - offsetY;

    final Path path = Path()
      ..moveTo(size.width / 2, verticalPadding)
      ..lineTo(0, size.height - verticalPadding)
      ..lineTo(size.width, size.height - verticalPadding)
      ..close();

    canvas.drawPath(path, fillPaint);

    final Paint borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}