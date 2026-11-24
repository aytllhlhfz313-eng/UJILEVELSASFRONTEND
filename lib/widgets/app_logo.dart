import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Logo Contre Store: tas belanja di atas latar gradien brand.
/// Sumber tunggal untuk logo di dalam aplikasi dan ikon launcher.
///
/// Glyph digambar dengan CustomPainter (bukan font ikon) supaya bentuknya
/// identik di aplikasi maupun saat dirender menjadi ikon launcher.
class AppLogo extends StatelessWidget {
  final double size;
  final double radiusFactor;
  final Color glyphColor;
  final bool gradient;
  final Color? background;

  /// fullBleed: tanpa sudut membulat, untuk ikon maskable.
  final bool fullBleed;

  /// Ukuran glyph relatif terhadap sisi logo.
  final double glyphFactor;

  const AppLogo({
    super.key,
    this.size = 96,
    this.radiusFactor = 0.24,
    this.glyphColor = Colors.white,
    this.gradient = true,
    this.background,
    this.fullBleed = false,
    this.glyphFactor = 0.56,
  });

  @override
  Widget build(BuildContext context) {
    final base = background ?? AppTheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient ? null : base,
          gradient: gradient ? AppTheme.brandGradient : null,
          borderRadius: fullBleed
              ? null
              : BorderRadius.circular(size * radiusFactor),
        ),
        child: Center(
          child: AppLogoMark(
            size: size * glyphFactor,
            color: glyphColor,
          ),
        ),
      ),
    );
  }
}

/// Glyph tas belanja saja, tanpa latar.
class AppLogoMark extends StatelessWidget {
  final double size;
  final Color color;
  const AppLogoMark({super.key, this.size = 40, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BagPainter(color)),
    );
  }
}

class _BagPainter extends CustomPainter {
  final Color color;
  _BagPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final e = math.min(size.width, size.height);
    final dx = (size.width - e) / 2;
    final dy = (size.height - e) / 2;

    // Pegangan: busur setengah lingkaran dengan ujung membulat.
    final handle = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = e * 0.075
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(dx + e * 0.5, dy + e * 0.47),
        radius: e * 0.175,
      ),
      math.pi,
      math.pi,
      false,
      handle,
    );

    // Badan tas: trapesium dengan sudut membulat, sedikit menyempit ke bawah.
    final body = Path()
      ..moveTo(dx + e * 0.17, dy + e * 0.46)
      ..lineTo(dx + e * 0.83, dy + e * 0.46)
      ..lineTo(dx + e * 0.77, dy + e * 0.86)
      ..quadraticBezierTo(
        dx + e * 0.765,
        dy + e * 0.90,
        dx + e * 0.725,
        dy + e * 0.90,
      )
      ..lineTo(dx + e * 0.275, dy + e * 0.90)
      ..quadraticBezierTo(
        dx + e * 0.235,
        dy + e * 0.90,
        dx + e * 0.23,
        dy + e * 0.86,
      )
      ..close();

    canvas.drawPath(body, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BagPainter old) => old.color != color;
}
