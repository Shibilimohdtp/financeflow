import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test/helpers/app_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testWidgets('Generate DS-B19a Logo Directions Contact Sheet', (
    WidgetTester tester,
  ) async {
    // 3 columns (one for each direction), wide high-res contact sheet
    tester.view.physicalSize = const Size(1400, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: const Scaffold(
          backgroundColor: Color(0xFF131510),
          body: _ContactSheetContent(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify golden match and write out
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/b19a_contact_sheet.png'),
    );
  });
}

class _ContactSheetContent extends StatelessWidget {
  const _ContactSheetContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'FinanceFlow · Brand Identity Redesign (DS-B19a)',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF3F2EC),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Master Vector Exploration: 3 Distinct Directions across Scales, Palettes & Launcher Masks',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 15,
                      color: Color(0xFFA3A69A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBE94C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBE94C), width: 1.2),
                ),
                child: const Text(
                  'Recommendation: Direction 1',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCBE94C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 3 Columns comparing directions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _DirectionColumn(
                  directionNumber: 1,
                  title: 'The Stillwater Ripple',
                  subtitle: 'Concentric squircle currents cradling the focal lime spark',
                  painterBuilder: _drawRipple,
                  isRecommended: true,
                ),
              ),
              SizedBox(width: 32),
              Expanded(
                child: _DirectionColumn(
                  directionNumber: 2,
                  title: 'The Ledger Ribbon',
                  subtitle: 'Continuous architectural F-monogram looping with spark terminal',
                  painterBuilder: _drawRibbon,
                  isRecommended: false,
                ),
              ),
              SizedBox(width: 32),
              Expanded(
                child: _DirectionColumn(
                  directionNumber: 3,
                  title: 'The Still Horizon',
                  subtitle: 'Minimalist curved water basin & dawn spark droplet',
                  painterBuilder: _drawHorizon,
                  isRecommended: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

typedef PathPainter = void Function(Canvas canvas, Size size, Color strokeColor, Color sparkColor);

class _DirectionColumn extends StatelessWidget {
  final int directionNumber;
  final String title;
  final String subtitle;
  final PathPainter painterBuilder;
  final bool isRecommended;

  const _DirectionColumn({
    required this.directionNumber,
    required this.title,
    required this.subtitle,
    required this.painterBuilder,
    required this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D17),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended ? const Color(0xFFCBE94C) : const Color(0xFF323629),
          width: isRecommended ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Direction Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DIRECTION $directionNumber',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isRecommended ? const Color(0xFFCBE94C) : const Color(0xFFA3A69A),
                ),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBE94C),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'CHOICE',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B1D17),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF3F2EC),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 12,
              color: Color(0xFF858979),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),

          // ── Section 1: Hero Large Display (192 px) ──
          const _SubSectionTitle('Hero Master · 192 px'),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2EC),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(192, 192),
                  painter: _GenericMarkPainter(
                    strokeColor: const Color(0xFF1B1D17),
                    sparkColor: const Color(0xFFCBE94C),
                    painterFunc: painterBuilder,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Section 2: Scale Ladder (96, 48, 24 px) ──
          const _SubSectionTitle('Optical Scalability: 96, 48, 24 px'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF24271F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ScaleItem(
                  size: 96,
                  child: CustomPaint(
                    size: const Size(96, 96),
                    painter: _GenericMarkPainter(
                      strokeColor: const Color(0xFFF3F2EC),
                      sparkColor: const Color(0xFFD5F057),
                      painterFunc: painterBuilder,
                    ),
                  ),
                ),
                _ScaleItem(
                  size: 48,
                  child: CustomPaint(
                    size: const Size(48, 48),
                    painter: _GenericMarkPainter(
                      strokeColor: const Color(0xFFF3F2EC),
                      sparkColor: const Color(0xFFD5F057),
                      painterFunc: painterBuilder,
                    ),
                  ),
                ),
                _ScaleItem(
                  size: 24,
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: _GenericMarkPainter(
                      strokeColor: const Color(0xFFF3F2EC),
                      sparkColor: const Color(0xFFD5F057),
                      painterFunc: painterBuilder,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Section 3: Palettes (Daylight, Deep Water, 1-Color Silhouette) ──
          const _SubSectionTitle('Palettes & Monochrome Silhouette'),
          const SizedBox(height: 12),
          Row(
            children: [
              // Daylight
              Expanded(
                child: _PaletteBox(
                  label: 'Daylight',
                  bgColor: const Color(0xFFF3F2EC),
                  child: CustomPaint(
                    size: const Size(52, 52),
                    painter: _GenericMarkPainter(
                      strokeColor: const Color(0xFF1B1D17),
                      sparkColor: const Color(0xFFCBE94C),
                      painterFunc: painterBuilder,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Deep Water
              Expanded(
                child: _PaletteBox(
                  label: 'Deep Water',
                  bgColor: const Color(0xFF10120E),
                  child: CustomPaint(
                    size: const Size(52, 52),
                    painter: _GenericMarkPainter(
                      strokeColor: const Color(0xFFE4E4DC),
                      sparkColor: const Color(0xFFD5F057),
                      painterFunc: painterBuilder,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 1-Color Silhouette
              Expanded(
                child: _PaletteBox(
                  label: 'Silhouette',
                  bgColor: const Color(0xFF2C3024),
                  child: CustomPaint(
                    size: const Size(52, 52),
                    painter: _GenericMarkPainter(
                      strokeColor: Colors.white,
                      sparkColor: Colors.white,
                      painterFunc: painterBuilder,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Section 4: Android Launcher Masks ──
          const _SubSectionTitle('Adaptive Launcher Masks (66dp in 108dp)'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MaskItem(
                shape: BoxShape.circle,
                label: 'Circle',
                painterFunc: painterBuilder,
              ),
              _MaskItem(
                borderRadius: BorderRadius.circular(20),
                label: 'Squircle',
                painterFunc: painterBuilder,
              ),
              _MaskItem(
                borderRadius: BorderRadius.circular(14),
                label: 'Rounded Sq',
                painterFunc: painterBuilder,
              ),
              _MaskItem(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(6),
                ),
                label: 'Teardrop',
                painterFunc: painterBuilder,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Section 5: Android Themed Monochrome Icon ──
          const _SubSectionTitle('Android 13+ Themed Icon (Monet)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF24271F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Themed icon container (dynamic tonal surface)
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF33382B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(32, 32),
                      painter: _GenericMarkPainter(
                        strokeColor: const Color(0xFFD5F057),
                        sparkColor: const Color(0xFFD5F057),
                        painterFunc: painterBuilder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '<monochrome> layer',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF3F2EC),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pure alpha vector tinted by OS dynamic accent colors.',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 11,
                          color: Color(0xFF858979),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubSectionTitle extends StatelessWidget {
  final String title;
  const _SubSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Geist',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFFA3A69A),
      ),
    );
  }
}

class _ScaleItem extends StatelessWidget {
  final double size;
  final Widget child;

  const _ScaleItem({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        child,
        const SizedBox(height: 8),
        Text(
          '${size.toInt()}px',
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 11,
            color: Color(0xFF858979),
          ),
        ),
      ],
    );
  }
}

class _PaletteBox extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Widget child;

  const _PaletteBox({
    required this.label,
    required this.bgColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF383D2F), width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: bgColor.computeLuminance() > 0.5 ? const Color(0xFF1B1D17) : const Color(0xFFE4E4DC),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaskItem extends StatelessWidget {
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final String label;
  final PathPainter painterFunc;

  const _MaskItem({
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    required this.label,
    required this.painterFunc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2EC),
            shape: shape,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(34, 34),
              painter: _GenericMarkPainter(
                strokeColor: const Color(0xFF1B1D17),
                sparkColor: const Color(0xFFCBE94C),
                painterFunc: painterFunc,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 10,
            color: Color(0xFF858979),
          ),
        ),
      ],
    );
  }
}

class _GenericMarkPainter extends CustomPainter {
  final Color strokeColor;
  final Color sparkColor;
  final PathPainter painterFunc;

  _GenericMarkPainter({
    required this.strokeColor,
    required this.sparkColor,
    required this.painterFunc,
  });

  @override
  void paint(Canvas canvas, Size size) {
    painterFunc(canvas, size, strokeColor, sparkColor);
  }

  @override
  bool shouldRepaint(covariant _GenericMarkPainter oldDelegate) =>
      strokeColor != oldDelegate.strokeColor || sparkColor != oldDelegate.sparkColor;
}

// ── Path Drawers ──

void _drawRipple(Canvas canvas, Size size, Color strokeColor, Color sparkColor) {
  final s = size.width / 512.0;

  final strokePaint1 = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 34 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  final strokePaint2 = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 28 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  // Outer Squircle Current
  final pOuter = Path()
    ..moveTo(196 * s, 120 * s)
    ..cubicTo(144 * s, 142 * s, 116 * s, 192 * s, 116 * s, 256 * s)
    ..cubicTo(116 * s, 352 * s, 168 * s, 404 * s, 256 * s, 404 * s)
    ..cubicTo(344 * s, 404 * s, 396 * s, 352 * s, 396 * s, 256 * s)
    ..cubicTo(396 * s, 160 * s, 344 * s, 108 * s, 256 * s, 108 * s);
  canvas.drawPath(pOuter, strokePaint1);

  // Inner Squircle Current
  final pInner = Path()
    ..moveTo(292 * s, 180 * s)
    ..cubicTo(316 * s, 196 * s, 328 * s, 220 * s, 328 * s, 256 * s)
    ..cubicTo(328 * s, 316 * s, 300 * s, 344 * s, 256 * s, 344 * s)
    ..cubicTo(212 * s, 344 * s, 184 * s, 316 * s, 184 * s, 256 * s)
    ..cubicTo(184 * s, 196 * s, 212 * s, 168 * s, 256 * s, 168 * s);
  canvas.drawPath(pInner, strokePaint2);

  // Center Lime Spark
  final sparkPaint = Paint()
    ..color = sparkColor
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  canvas.drawCircle(Offset(256 * s, 256 * s), 24 * s, sparkPaint);
}

void _drawRibbon(Canvas canvas, Size size, Color strokeColor, Color sparkColor) {
  final s = size.width / 512.0;

  final strokePaint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 38 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  // Flowing F stem and top bar
  final pStem = Path()
    ..moveTo(172 * s, 392 * s)
    ..lineTo(172 * s, 156 * s)
    ..cubicTo(172 * s, 126 * s, 198 * s, 116 * s, 236 * s, 116 * s)
    ..lineTo(340 * s, 116 * s);
  canvas.drawPath(pStem, strokePaint);

  // Crossbar
  final pCross = Path()
    ..moveTo(172 * s, 256 * s)
    ..lineTo(296 * s, 256 * s);
  canvas.drawPath(pCross, strokePaint);

  // Lime terminal
  final sparkPaint = Paint()
    ..color = sparkColor
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  canvas.drawCircle(Offset(348 * s, 256 * s), 22 * s, sparkPaint);
}

void _drawHorizon(Canvas canvas, Size size, Color strokeColor, Color sparkColor) {
  final s = size.width / 512.0;

  final cradlePaint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 36 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  final wavePaint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 32 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  // Basin Cradle
  final pCradle = Path()
    ..moveTo(136 * s, 256 * s)
    ..cubicTo(136 * s, 348 * s, 184 * s, 396 * s, 256 * s, 396 * s)
    ..cubicTo(328 * s, 396 * s, 376 * s, 348 * s, 376 * s, 256 * s);
  canvas.drawPath(pCradle, cradlePaint);

  // Horizon line
  final pWave = Path()
    ..moveTo(160 * s, 256 * s)
    ..lineTo(352 * s, 256 * s);
  canvas.drawPath(pWave, wavePaint);

  // Buoyant spark
  final sparkPaint = Paint()
    ..color = sparkColor
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  canvas.drawCircle(Offset(256 * s, 168 * s), 28 * s, sparkPaint);
}
