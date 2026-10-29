import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const VSolesApp());
}

class VSolesApp extends StatelessWidget {
  const VSolesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'V SOLES',
      theme: ThemeData(
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F3A37)),
      ),
      home: const LoginPage(),
    );
  }
}

class VSolesHomePage extends StatefulWidget {
  const VSolesHomePage({super.key});

  @override
  State<VSolesHomePage> createState() => _VSolesHomePageState();
}

class _VSolesHomePageState extends State<VSolesHomePage> {
  final List<String> styles = ['Running', 'Training', 'Trail', 'Street'];
  String selectedStyle = 'Running';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              const Text(
                'Find your next pair.',
                style: TextStyle(
                  color: Color(0xFF1E1F20),
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 18),
              _buildSearchBar(),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: styles.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final style = styles[index];
                    final isSelected = style == selectedStyle;
                    return ChoiceChip(
                      label: Text(style, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedStyle = style;
                        });
                      },
                      backgroundColor: const Color(0xFFF7F3ED),
                      selectedColor: const Color(0xFFE8E1D8),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF1E1F20) : const Color(0xFF6E6962),
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF122E28),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SPRING DROP',
                            style: TextStyle(
                              color: Color(0xFFADC8C2),
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Fresh steps for warmer days.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Browse by style',
                            style: TextStyle(
                              color: Color(0xFFDCE8E5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomPaint(
                      painter: ShoePainter(),
                      child: const SizedBox(width: 168, height: 120),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Browse by style',
                style: TextStyle(
                  color: Color(0xFF1E1F20),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                childAspectRatio: 0.82,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _styleCard('Running', Icons.directions_run, const Color(0xFFE9E3D7)),
                  _styleCard('Trail', Icons.terrain, const Color(0xFFE7E4D7)),
                  _styleCard('Design', Icons.sports_baseball, const Color(0xFFE8E1E2)),
                  _styleCard('Aesthetic', Icons.person, const Color(0xFFE8E8E1)),
                ],
              ),
              const Spacer(),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE8DCCA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu, size: 18, color: Color(0xFF1E1F20)),
          ),
          const Spacer(),
          const Text(
            'V SOLES',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF1E1F20),
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(
              2,
              (_) => Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE6DE),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EAE0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Color(0xFF6E6962), size: 18),
                SizedBox(width: 10),
                Text(
                  'Search shoes',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6E6962)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF1D403C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, true),
          _navItem(Icons.search, false),
          _navItem(Icons.shopping_bag, false),
          _navItem(Icons.favorite_border, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isActive) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDDEAE7) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: isActive ? const Color(0xFF123028) : const Color(0xFF6E6962),
      ),
    );
  }

  Widget _styleCard(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1E1F20), size: 24),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E1F20),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ShoePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF2E7D5);
    final outlinePaint = Paint()
      ..color = const Color(0xFFE7D1A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final body = Path()
      ..moveTo(20, 80)
      ..cubicTo(42, 42, 82, 18, 140, 28)
      ..cubicTo(180, 34, 214, 52, 246, 70)
      ..cubicTo(262, 79, 268, 90, 260, 100)
      ..lineTo(36, 100)
      ..cubicTo(20, 100, 12, 90, 20, 80)
      ..close();

    final sole = Path()
      ..moveTo(16, 90)
      ..lineTo(248, 90)
      ..cubicTo(258, 90, 264, 96, 261, 102)
      ..lineTo(246, 113)
      ..cubicTo(237, 121, 227, 122, 210, 122)
      ..lineTo(34, 122)
      ..cubicTo(20, 122, 10, 116, 8, 104)
      ..lineTo(8, 96)
      ..cubicTo(8, 92, 10, 90, 16, 90)
      ..close();

    final shoeBase = Path()
      ..moveTo(90, 26)
      ..cubicTo(125, 16, 150, 24, 170, 44)
      ..cubicTo(186, 58, 186, 70, 162, 70)
      ..cubicTo(126, 70, 96, 66, 72, 56)
      ..cubicTo(58, 50, 66, 34, 90, 26)
      ..close();

    canvas.drawPath(body, paint);
    canvas.drawPath(sole, outlinePaint);
    canvas.drawPath(shoeBase, Paint()..color = const Color(0xFFD9D1C6));
    canvas.drawLine(
      const Offset(82, 76),
      const Offset(198, 76),
      Paint()
        ..color = const Color(0xFF0C2E2A)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
