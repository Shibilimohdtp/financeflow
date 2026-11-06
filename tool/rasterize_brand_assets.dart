import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rasterize FinanceFlow Brand Assets from Canonical Master Geometry', () async {
    final rootDir = Directory.current.path;

    Future<void> savePng(
      String relativePath,
      int width,
      int height, {
      required void Function(ui.Canvas canvas, ui.Size size) draw,
    }) async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
      draw(canvas, ui.Size(width.toDouble(), height.toDouble()));
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw StateError('Failed to encode PNG for $relativePath');

      final file = File('$rootDir/$relativePath');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(byteData.buffer.asUint8List());
    }

    // ── Drawer: Full App Icon (Squircle plate + Stillwater Ripple) ──
    void drawAppIcon(ui.Canvas canvas, ui.Size size, {bool isRound = false}) {
      final w = size.width;
      final h = size.height;

      // 1. Canvas Background Plate
      final bgPaint = Paint()..color = const Color(0xFFF3F2EC);
      if (isRound) {
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);
      } else {
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h),
          Radius.circular(w * 0.22),
        );
        canvas.drawRRect(r, bgPaint);
      }

      // 2. Centered Stillwater Ripple Mark
      final s = (w * 0.70) / 512.0;
      final dx = (w - (512.0 * s)) / 2.0;
      final dy = (h - (512.0 * s)) / 2.0;

      canvas.save();
      canvas.translate(dx, dy);
      _paintRipple(canvas, s, const Color(0xFF1B1D17), const Color(0xFFCBE94C));
      canvas.restore();
    }

    // ── Drawer: Bare Stillwater Mark ──
    void drawBareMark(ui.Canvas canvas, ui.Size size) {
      final s = size.width / 512.0;
      _paintRipple(canvas, s, const Color(0xFF1B1D17), const Color(0xFFCBE94C));
    }

    // ── Drawer: Adaptive Foreground (Scaled to 66dp within 108dp canvas) ──
    void drawAdaptiveForeground(ui.Canvas canvas, ui.Size size) {
      final w = size.width;
      final s = (w * (66.0 / 108.0) * 0.88) / 312.0;
      final dx = (w - (512.0 * s)) / 2.0;
      final dy = (w - (512.0 * s)) / 2.0;

      canvas.save();
      canvas.translate(dx, dy);
      _paintRipple(canvas, s, const Color(0xFF1B1D17), const Color(0xFFCBE94C));
      canvas.restore();
    }

    // ── Drawer: Notification Icon (Alpha Mask / Pure White on Transparent) ──
    void drawNotificationIcon(ui.Canvas canvas, ui.Size size) {
      final w = size.width;
      final s = w / 24.0;

      final pOuter = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      final pInner = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      final pathOuter = Path()
        ..moveTo(9.18 * s, 5.62 * s)
        ..cubicTo(6.75 * s, 6.65 * s, 5.44 * s, 9.0 * s, 5.44 * s, 12.0 * s)
        ..cubicTo(5.44 * s, 16.5 * s, 7.87 * s, 18.94 * s, 12.0 * s, 18.94 * s)
        ..cubicTo(16.12 * s, 18.94 * s, 18.56 * s, 16.5 * s, 18.56 * s, 12.0 * s)
        ..cubicTo(18.56 * s, 7.5 * s, 16.12 * s, 5.06 * s, 12.0 * s, 5.06 * s);
      canvas.drawPath(pathOuter, pOuter);

      final pathInner = Path()
        ..moveTo(13.68 * s, 8.44 * s)
        ..cubicTo(14.81 * s, 9.19 * s, 15.38 * s, 10.31 * s, 15.38 * s, 12.0 * s)
        ..cubicTo(15.38 * s, 14.81 * s, 14.06 * s, 16.12 * s, 12.0 * s, 16.12 * s)
        ..cubicTo(9.94 * s, 16.12 * s, 8.62 * s, 14.81 * s, 8.62 * s, 12.0 * s)
        ..cubicTo(8.62 * s, 9.19 * s, 9.94 * s, 7.88 * s, 12.0 * s, 7.88 * s);
      canvas.drawPath(pathInner, pInner);

      final spark = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(Offset(12.0 * s, 12.0 * s), 1.5 * s, spark);
    }

    // ── Generate All Multi-Density Bitmaps ──

    // 1. Android Legacy & Round Launcher
    const densities = [
      ('mipmap-mdpi', 48),
      ('mipmap-hdpi', 72),
      ('mipmap-xhdpi', 96),
      ('mipmap-xxhdpi', 144),
      ('mipmap-xxxhdpi', 192),
    ];
    for (final (d, sz) in densities) {
      await savePng('android/app/src/main/res/$d/ic_launcher.png', sz, sz, draw: (c, s) => drawAppIcon(c, s));
      await savePng('android/app/src/main/res/$d/ic_launcher_round.png', sz, sz, draw: (c, s) => drawAppIcon(c, s, isRound: true));
    }

    // 2. Android Adaptive Foreground PNGs
    const fgDensities = [
      ('drawable-mdpi', 108),
      ('drawable-hdpi', 162),
      ('drawable-xhdpi', 216),
      ('drawable-xxhdpi', 324),
      ('drawable-xxxhdpi', 432),
    ];
    for (final (d, sz) in fgDensities) {
      await savePng('android/app/src/main/res/$d/ic_launcher_foreground.png', sz, sz, draw: drawAdaptiveForeground);
    }

    // 3. Android Notification PNGs
    const notifDensities = [
      ('drawable-mdpi', 24),
      ('drawable-hdpi', 36),
      ('drawable-xhdpi', 48),
      ('drawable-xxhdpi', 72),
      ('drawable-xxxhdpi', 96),
    ];
    for (final (d, sz) in notifDensities) {
      await savePng('android/app/src/main/res/$d/ic_notification.png', sz, sz, draw: drawNotificationIcon);
    }

    // 4. Native Splash Logo
    await savePng('android/app/src/main/res/drawable/splash_logo.png', 192, 192, draw: drawBareMark);

    // 5. Assets / Branding Bitmaps
    await savePng('assets/branding/financeflow_mark.png', 512, 512, draw: drawBareMark);
    await savePng('assets/branding/financeflow_app_icon.png', 1024, 1024, draw: drawAppIcon);

    // 6. Web & macOS Icons
    await savePng('web/favicon.png', 32, 32, draw: drawBareMark);
    await savePng('web/icons/Icon-192.png', 192, 192, draw: drawAppIcon);
    await savePng('web/icons/Icon-512.png', 512, 512, draw: drawAppIcon);
    await savePng('web/icons/Icon-maskable-192.png', 192, 192, draw: drawAppIcon);
    await savePng('web/icons/Icon-maskable-512.png', 512, 512, draw: drawAppIcon);

    // 7. iOS Icons
    const iosIcons = [
      ('Icon-App-20x20@1x.png', 20),
      ('Icon-App-20x20@2x.png', 40),
      ('Icon-App-20x20@3x.png', 60),
      ('Icon-App-29x29@1x.png', 29),
      ('Icon-App-29x29@2x.png', 58),
      ('Icon-App-29x29@3x.png', 87),
      ('Icon-App-40x40@1x.png', 40),
      ('Icon-App-40x40@2x.png', 80),
      ('Icon-App-40x40@3x.png', 120),
      ('Icon-App-60x60@2x.png', 120),
      ('Icon-App-60x60@3x.png', 180),
      ('Icon-App-76x76@1x.png', 76),
      ('Icon-App-76x76@2x.png', 152),
      ('Icon-App-83.5x83.5@2x.png', 167),
      ('Icon-App-1024x1024@1x.png', 1024),
    ];
    for (final (fn, sz) in iosIcons) {
      await savePng('ios/Runner/Assets.xcassets/AppIcon.appiconset/$fn', sz, sz, draw: drawAppIcon);
    }
  });
}

void _paintRipple(ui.Canvas canvas, double s, Color strokeColor, Color sparkColor) {
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

  // Center Radiant Lime Spark
  final sparkPaint = Paint()
    ..color = sparkColor
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  canvas.drawCircle(Offset(256 * s, 256 * s), 24 * s, sparkPaint);
}
