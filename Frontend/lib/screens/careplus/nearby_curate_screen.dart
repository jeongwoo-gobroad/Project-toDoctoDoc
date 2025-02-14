import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';

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
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _WeightIndicator(
                          label: '거리순',
                          value: distWeight,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _WeightIndicator(
                          label: '평점 높은 순',
                          value: starWeight,
                          color: Colors.orange,
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
                    painter: _TrianglePainter(),
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
                  top: 16,
                  child: Text(
                    '시간',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                Positioned(
                  left: 6,
                  top: h - 16,
                  child: Text(
                    '거리',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                Positioned(
                  left: w - 32,
                  top: h - 16,
                  child: Text(
                    '평점',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
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

class HospitalPopupDialog extends StatelessWidget {
  final CurateListController curateListController =
      Get.find<CurateListController>();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        height: 520,
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

                return PageView.builder(
                  itemCount: curateListController.curatedList.length,
                  itemBuilder: (context, index) {
                    final hospital = curateListController.curatedList[index];
                    return HospitalCard(
                      name : hospital.name,
                      hospitalName: hospital.myPsyID.name,
                      rating: hospital.myPsyID.stars,
                      address: hospital.myPsyID.address.address,
                      detailAddress: hospital.myPsyID.address.detailAddress,
                      extraAddress: hospital.myPsyID.address.extraAddress,
                    
                    );
                  },
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
  final double rating;
  final String address;
  final String detailAddress;
  final String extraAddress;

  const HospitalCard({
    super.key,
    required this.name,
    required this.hospitalName,
    required this.rating,
    required this.address,
    required this.detailAddress,
    required this.extraAddress,
  });

  @override
  State<HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<HospitalCard> {
  bool _showDetailAddress = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hospitalName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
             Text(
              '담당 의사: ${widget.name}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildStarRating(widget.rating),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _showDetailAddress = !_showDetailAddress;
                });
              },
              child: Row(
                children: [


                  Text(
                    '${widget.address}${widget.extraAddress}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Icon(
                    _showDetailAddress
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            if (_showDetailAddress) ...[
              const SizedBox(height: 8),
              Text(
                '상세주소: ${widget.detailAddress}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],

            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  //todo 구현하기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 225, 234, 205),
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
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Gradient gradient = LinearGradient(
      colors: [Colors.blue.shade50, Colors.orange.shade50],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final Paint fillPaint = Paint()..shader = gradient.createShader(rect);
    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, fillPaint);

    final Paint borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
